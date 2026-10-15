package auth

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

var (
	ErrInvalidCredentials = errors.New("invalid email or password")
	ErrInvalidToken       = errors.New("invalid or expired token")
	ErrInactiveUser       = errors.New("user is inactive")
)

type Service struct {
	pool       *pgxpool.Pool
	q          *repository.Queries
	jwt        *JWTManager
	refreshTTL time.Duration
	sessionTTL time.Duration
}

func NewService(pool *pgxpool.Pool, jwt *JWTManager, refreshTTL, sessionTTL time.Duration) *Service {
	return &Service{
		pool:       pool,
		q:          repository.New(pool),
		jwt:        jwt,
		refreshTTL: refreshTTL,
		sessionTTL: sessionTTL,
	}
}

func (s *Service) JWT() *JWTManager { return s.jwt }

// Authenticate checks email and password. It returns ErrInvalidCredentials
// for an unknown email, a wrong password or an inactive account, so callers
// cannot tell which one occurred.
func (s *Service) Authenticate(ctx context.Context, email, password string) (repository.User, error) {
	user, err := s.q.GetUserByEmail(ctx, email)
	if errors.Is(err, pgx.ErrNoRows) {
		_, _ = checkPassword(string(dummyHash), password)
		return repository.User{}, ErrInvalidCredentials
	}
	if err != nil {
		return repository.User{}, fmt.Errorf("get user: %w", err)
	}

	ok, err := checkPassword(user.PasswordHash, password)
	if err != nil {
		return repository.User{}, fmt.Errorf("check password: %w", err)
	}
	if !ok || !user.IsActive {
		return repository.User{}, ErrInvalidCredentials
	}
	return user, nil
}

// ActiveUser loads a user by ID and rejects deactivated accounts.
func (s *Service) ActiveUser(ctx context.Context, id uuid.UUID) (repository.User, error) {
	user, err := s.q.GetUserByID(ctx, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return repository.User{}, ErrInvalidToken
	}
	if err != nil {
		return repository.User{}, fmt.Errorf("get user: %w", err)
	}
	if !user.IsActive {
		return repository.User{}, ErrInactiveUser
	}
	return user, nil
}

// --- Mobile: access + refresh tokens ----------------------------------------

type TokenPair struct {
	AccessToken      string    `json:"access_token"`
	TokenType        string    `json:"token_type"`
	ExpiresAt        time.Time `json:"expires_at"`
	RefreshToken     string    `json:"refresh_token"`
	RefreshExpiresAt time.Time `json:"refresh_expires_at"`
}

func (s *Service) IssueTokens(ctx context.Context, user repository.User) (TokenPair, error) {
	return s.issueTokens(ctx, s.q, user)
}

func (s *Service) issueTokens(ctx context.Context, q *repository.Queries, user repository.User) (TokenPair, error) {
	access, accessExp, err := s.jwt.Issue(user.ID, string(user.Role))
	if err != nil {
		return TokenPair{}, err
	}
	raw, hash, err := newOpaqueToken()
	if err != nil {
		return TokenPair{}, err
	}
	refreshExp := time.Now().Add(s.refreshTTL)
	if err := q.CreateRefreshToken(ctx, repository.CreateRefreshTokenParams{
		UserID:    user.ID,
		TokenHash: hash,
		ExpiresAt: refreshExp,
	}); err != nil {
		return TokenPair{}, fmt.Errorf("store refresh token: %w", err)
	}
	return TokenPair{
		AccessToken:      access,
		TokenType:        "Bearer",
		ExpiresAt:        accessExp,
		RefreshToken:     raw,
		RefreshExpiresAt: refreshExp,
	}, nil
}

// Refresh rotates a refresh token: the old one is revoked and a new pair is
// issued. Presenting an already-revoked token means it was stolen or
// replayed, so every refresh token of that user is revoked.
func (s *Service) Refresh(ctx context.Context, rawRefresh string) (TokenPair, repository.User, error) {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return TokenPair{}, repository.User{}, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)
	q := s.q.WithTx(tx)

	stored, err := q.GetRefreshToken(ctx, hashToken(rawRefresh))
	if errors.Is(err, pgx.ErrNoRows) {
		return TokenPair{}, repository.User{}, ErrInvalidToken
	}
	if err != nil {
		return TokenPair{}, repository.User{}, fmt.Errorf("get refresh token: %w", err)
	}

	revoked, err := q.RevokeRefreshToken(ctx, stored.ID)
	if err != nil {
		return TokenPair{}, repository.User{}, fmt.Errorf("revoke refresh token: %w", err)
	}
	if revoked == 0 {
		// Reuse detected. Commit the family revocation even though we fail.
		if err := q.RevokeAllRefreshTokensForUser(ctx, stored.UserID); err != nil {
			return TokenPair{}, repository.User{}, fmt.Errorf("revoke all tokens: %w", err)
		}
		if err := tx.Commit(ctx); err != nil {
			return TokenPair{}, repository.User{}, fmt.Errorf("commit: %w", err)
		}
		return TokenPair{}, repository.User{}, ErrInvalidToken
	}
	if time.Now().After(stored.ExpiresAt) {
		return TokenPair{}, repository.User{}, ErrInvalidToken
	}

	user, err := q.GetUserByID(ctx, stored.UserID)
	if err != nil {
		return TokenPair{}, repository.User{}, fmt.Errorf("get user: %w", err)
	}
	if !user.IsActive {
		return TokenPair{}, repository.User{}, ErrInvalidToken
	}

	pair, err := s.issueTokens(ctx, q, user)
	if err != nil {
		return TokenPair{}, repository.User{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return TokenPair{}, repository.User{}, fmt.Errorf("commit: %w", err)
	}
	return pair, user, nil
}

// Logout revokes a refresh token. Unknown tokens are ignored.
func (s *Service) Logout(ctx context.Context, rawRefresh string) error {
	stored, err := s.q.GetRefreshToken(ctx, hashToken(rawRefresh))
	if errors.Is(err, pgx.ErrNoRows) {
		return nil
	}
	if err != nil {
		return fmt.Errorf("get refresh token: %w", err)
	}
	_, err = s.q.RevokeRefreshToken(ctx, stored.ID)
	return err
}

// --- Admin web: cookie sessions ---------------------------------------------

// CreateSession returns the raw cookie value and its expiry.
func (s *Service) CreateSession(ctx context.Context, userID uuid.UUID) (string, time.Time, error) {
	raw, hash, err := newOpaqueToken()
	if err != nil {
		return "", time.Time{}, err
	}
	exp := time.Now().Add(s.sessionTTL)
	if err := s.q.CreateWebSession(ctx, repository.CreateWebSessionParams{
		UserID:    userID,
		TokenHash: hash,
		ExpiresAt: exp,
	}); err != nil {
		return "", time.Time{}, fmt.Errorf("store session: %w", err)
	}
	return raw, exp, nil
}

func (s *Service) SessionUser(ctx context.Context, rawSession string) (repository.User, error) {
	user, err := s.q.GetActiveSessionUser(ctx, hashToken(rawSession))
	if errors.Is(err, pgx.ErrNoRows) {
		return repository.User{}, ErrInvalidToken
	}
	if err != nil {
		return repository.User{}, fmt.Errorf("get session: %w", err)
	}
	return user, nil
}

func (s *Service) DeleteSession(ctx context.Context, rawSession string) error {
	return s.q.DeleteWebSession(ctx, hashToken(rawSession))
}

// CleanupExpired removes expired sessions and long-expired refresh tokens.
func (s *Service) CleanupExpired(ctx context.Context) error {
	return errors.Join(
		s.q.DeleteExpiredWebSessions(ctx),
		s.q.DeleteExpiredRefreshTokens(ctx),
	)
}
