package media

import (
	"bytes"
	"context"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/Mathatter10/daycare-app/backend-go/internal/push"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
	"github.com/Mathatter10/daycare-app/backend-go/internal/storage"
	"github.com/Mathatter10/daycare-app/backend-go/internal/worker"
)

const (
	// ViewURLTTL is how long a signed media URL stays valid.
	ViewURLTTL = time.Hour
	// UploadURLTTL is how long a client has to start a video upload.
	UploadURLTTL = 15 * time.Minute
)

// Service stores media objects and processes photos in the background.
type Service struct {
	store *storage.Store // nil when storage is not configured
	q     *repository.Queries
	pool  *worker.Pool
	push  *push.Dispatcher
	msgs  push.Messages
}

func NewService(db *pgxpool.Pool, store *storage.Store, pool *worker.Pool, dispatcher *push.Dispatcher, msgs push.Messages) *Service {
	return &Service{store: store, q: repository.New(db), pool: pool, push: dispatcher, msgs: msgs}
}

// Enabled reports whether object storage is configured.
func (s *Service) Enabled() bool { return s.store != nil }

func (s *Service) Store() *storage.Store { return s.store }

// Object keys are derived from ids, never from client file names.
func PhotoKeys(childID, mediaID uuid.UUID) (full, thumb string) {
	base := "children/" + childID.String() + "/" + mediaID.String()
	return base + ".jpg", base + "_thumb.jpg"
}

func VideoKey(childID, mediaID uuid.UUID, contentType string) string {
	ext := ".mp4"
	if contentType == "video/quicktime" {
		ext = ".mov"
	}
	return "children/" + childID.String() + "/" + mediaID.String() + ext
}

// EnqueuePhoto processes and stores a photo in the background. data must
// not alias request memory. Returns false if the queue is full.
func (s *Service) EnqueuePhoto(m repository.Medium, data []byte, notify bool) bool {
	return s.pool.TrySubmit(func(ctx context.Context) {
		log := slog.With("media_id", m.ID)
		photo, err := ProcessPhoto(data)
		if err != nil {
			log.Warn("photo processing failed", "err", err)
			s.markFailed(ctx, m.ID)
			return
		}
		fullKey, thumbKey := PhotoKeys(m.ChildID, m.ID)
		if err := s.store.Put(ctx, fullKey, "image/jpeg", bytes.NewReader(photo.Full), int64(len(photo.Full))); err != nil {
			log.Error("photo upload failed", "err", err)
			s.markFailed(ctx, m.ID)
			return
		}
		if err := s.store.Put(ctx, thumbKey, "image/jpeg", bytes.NewReader(photo.Thumb), int64(len(photo.Thumb))); err != nil {
			log.Error("thumbnail upload failed", "err", err)
			s.markFailed(ctx, m.ID)
			return
		}
		if err := s.q.MarkPhotoReady(ctx, repository.MarkPhotoReadyParams{
			ID:        m.ID,
			ThumbKey:  pgtype.Text{String: thumbKey, Valid: true},
			SizeBytes: pgtype.Int8{Int64: int64(len(photo.Full)), Valid: true},
			Width:     pgtype.Int4{Int32: int32(photo.Width), Valid: true},
			Height:    pgtype.Int4{Int32: int32(photo.Height), Valid: true},
		}); err != nil {
			log.Error("mark photo ready failed", "err", err)
			return
		}
		log.Info("photo ready", "bytes", len(photo.Full), "width", photo.Width, "height", photo.Height)
		if notify {
			s.push.NotifyParents(m.ChildID, s.msgs.MediaReady(m.ChildID, m.ID, repository.MediaKindPhoto))
		}
	})
}

// DeleteObjects removes a media item's files in the background.
func (s *Service) DeleteObjects(m repository.Medium) {
	if s.store == nil {
		return
	}
	s.pool.TrySubmit(func(ctx context.Context) {
		if err := s.store.Delete(ctx, m.StorageKey, m.ThumbKey.String); err != nil {
			slog.Error("delete media objects", "media_id", m.ID, "err", err)
		}
	})
}

// SignedURLs returns view URLs for a ready media item.
func (s *Service) SignedURLs(ctx context.Context, m repository.Medium) (url, thumbURL string, expires time.Time, err error) {
	expires = time.Now().Add(ViewURLTTL)
	if url, err = s.store.PresignGet(ctx, m.StorageKey, ViewURLTTL); err != nil {
		return "", "", time.Time{}, err
	}
	if m.ThumbKey.Valid {
		if thumbURL, err = s.store.PresignGet(ctx, m.ThumbKey.String, ViewURLTTL); err != nil {
			return "", "", time.Time{}, err
		}
	}
	return url, thumbURL, expires, nil
}

func (s *Service) markFailed(ctx context.Context, id uuid.UUID) {
	if err := s.q.MarkMediaFailed(ctx, id); err != nil {
		slog.Error("mark media failed", "media_id", id, "err", err)
	}
}
