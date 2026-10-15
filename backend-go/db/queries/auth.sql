-- Mobile refresh tokens ------------------------------------------------------

-- name: CreateRefreshToken :exec
INSERT INTO refresh_tokens (user_id, token_hash, expires_at)
VALUES ($1, $2, $3);

-- name: GetRefreshToken :one
SELECT * FROM refresh_tokens
WHERE token_hash = $1;

-- Revokes the token only if it is still active; zero rows means it was
-- already used, which signals a replayed (possibly stolen) token.
-- name: RevokeRefreshToken :execrows
UPDATE refresh_tokens
SET revoked_at = now()
WHERE id = $1 AND revoked_at IS NULL;

-- name: RevokeAllRefreshTokensForUser :exec
UPDATE refresh_tokens
SET revoked_at = now()
WHERE user_id = $1 AND revoked_at IS NULL;

-- name: DeleteExpiredRefreshTokens :exec
DELETE FROM refresh_tokens
WHERE expires_at < now() - interval '7 days';

-- Admin web sessions ---------------------------------------------------------

-- name: CreateWebSession :exec
INSERT INTO web_sessions (user_id, token_hash, expires_at)
VALUES ($1, $2, $3);

-- name: GetActiveSessionUser :one
SELECT u.*
FROM web_sessions s
JOIN users u ON u.id = s.user_id
WHERE s.token_hash = $1
  AND s.expires_at > now()
  AND u.is_active;

-- name: DeleteWebSession :exec
DELETE FROM web_sessions
WHERE token_hash = $1;

-- name: DeleteExpiredWebSessions :exec
DELETE FROM web_sessions
WHERE expires_at < now();

-- name: DeleteWebSessionsForUser :exec
DELETE FROM web_sessions
WHERE user_id = $1;
