package handlers

import (
	"errors"
	"io"
	"net/http"
	"slices"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/Mathatter10/daycare-app/backend-go/internal/media"
	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
	"github.com/Mathatter10/daycare-app/backend-go/internal/models"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
	"github.com/Mathatter10/daycare-app/backend-go/internal/storage"
)

const (
	maxPhotoBytes = 15 << 20
	maxVideoBytes = 100 << 20
)

var (
	photoTypes = []string{"image/jpeg", "image/png", "image/webp"}
	videoTypes = []string{"video/mp4", "video/quicktime"}
)

// PutPhoto uploads a photo (multipart: file, child_id, activity_id?,
// taken_at?) under a client-generated id. The server answers 202 at once
// and processes the photo in the background; poll GET /media/:id or wait
// for it in the timeline. Idempotent for retries.
// PUT /api/v1/media/:id/photo
func (h *MobileHandler) PutPhoto(c fiber.Ctx) error {
	if err := h.requireStorage(); err != nil {
		return err
	}
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	meta, err := h.parseMediaMeta(c, c.FormValue("child_id"), c.FormValue("activity_id"), c.FormValue("taken_at"))
	if err != nil {
		return err
	}

	fh, err := c.FormFile("file")
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "file is required")
	}
	if fh.Size > maxPhotoBytes {
		return fiber.NewError(fiber.StatusRequestEntityTooLarge, "photo must be at most 15 MB")
	}
	f, err := fh.Open()
	if err != nil {
		return err
	}
	defer f.Close()
	// ReadAll copies into a new buffer, so the job does not alias request
	// memory that Fiber reuses after the handler returns.
	data, err := io.ReadAll(io.LimitReader(f, maxPhotoBytes+1))
	if err != nil {
		return err
	}
	if len(data) > maxPhotoBytes {
		return fiber.NewError(fiber.StatusRequestEntityTooLarge, "photo must be at most 15 MB")
	}
	if ct := http.DetectContentType(data); !slices.Contains(photoTypes, ct) {
		return fiber.NewError(fiber.StatusUnsupportedMediaType, "photo must be JPEG, PNG or WebP")
	}

	ctx := c.Context()
	fullKey, _ := media.PhotoKeys(meta.childID, id)
	m, created, err := h.createMedia(c, id, meta, repository.MediaKindPhoto, fullKey, "image/jpeg", int64(len(data)))
	if err != nil {
		return err
	}
	if !created && m.Status != repository.MediaStatusFailed {
		// Retry of an upload already accepted: report its current state.
		return h.mediaJSON(c, m)
	}
	if !created {
		if err := h.Q.SetMediaPending(ctx, id); err != nil {
			return err
		}
		m.Status = repository.MediaStatusPending
	}

	if !h.Media.EnqueuePhoto(m, data, isFresh(meta.takenAt)) {
		if created {
			_ = h.Q.DeletePendingMedia(ctx, id)
		} else {
			_ = h.Q.MarkMediaFailed(ctx, id)
		}
		c.Set(fiber.HeaderRetryAfter, "30")
		return fiber.NewError(fiber.StatusServiceUnavailable, "server is busy processing photos, retry shortly")
	}
	c.Status(fiber.StatusAccepted)
	return c.JSON(models.NewMediaResponse(m, "", "", time.Time{}))
}

type videoRequest struct {
	ChildID     string `json:"child_id"`
	ActivityID  string `json:"activity_id"`
	TakenAt     string `json:"taken_at"`
	ContentType string `json:"content_type"`
	SizeBytes   int64  `json:"size_bytes"`
}

// PutVideo registers a video and returns a presigned URL; the app PUTs the
// file straight to storage, then calls POST /media/:id/complete.
// PUT /api/v1/media/:id/video
func (h *MobileHandler) PutVideo(c fiber.Ctx) error {
	if err := h.requireStorage(); err != nil {
		return err
	}
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	var req videoRequest
	if err := c.Bind().JSON(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid JSON body")
	}
	if !slices.Contains(videoTypes, req.ContentType) {
		return fiber.NewError(fiber.StatusUnsupportedMediaType, "content_type must be video/mp4 or video/quicktime")
	}
	if req.SizeBytes <= 0 || req.SizeBytes > maxVideoBytes {
		return fiber.NewError(fiber.StatusRequestEntityTooLarge, "size_bytes must be between 1 and 100 MB")
	}
	meta, err := h.parseMediaMeta(c, req.ChildID, req.ActivityID, req.TakenAt)
	if err != nil {
		return err
	}

	key := media.VideoKey(meta.childID, id, req.ContentType)
	m, _, err := h.createMedia(c, id, meta, repository.MediaKindVideo, key, req.ContentType, req.SizeBytes)
	if err != nil {
		return err
	}
	resp := fiber.Map{}
	if m.Status != repository.MediaStatusReady {
		uploadURL, err := h.Media.Store().PresignPut(c.Context(), m.StorageKey, m.MimeType, media.UploadURLTTL)
		if err != nil {
			return err
		}
		resp["upload"] = fiber.Map{
			"url":        uploadURL,
			"method":     http.MethodPut,
			"headers":    fiber.Map{"Content-Type": m.MimeType},
			"expires_at": time.Now().Add(media.UploadURLTTL).UTC(),
		}
	}
	mediaResp, err := h.mediaResponse(c, m)
	if err != nil {
		return err
	}
	resp["media"] = mediaResp
	return c.JSON(resp)
}

// CompleteVideo verifies the uploaded object and marks the video ready.
// POST /api/v1/media/:id/complete
func (h *MobileHandler) CompleteVideo(c fiber.Ctx) error {
	if err := h.requireStorage(); err != nil {
		return err
	}
	m, err := h.loadMedia(c)
	if err != nil {
		return err
	}
	if m.Kind != repository.MediaKindVideo {
		return fiber.NewError(fiber.StatusConflict, "only videos are completed this way")
	}
	if m.Status == repository.MediaStatusReady {
		return h.mediaJSON(c, m)
	}

	ctx := c.Context()
	info, err := h.Media.Store().Stat(ctx, m.StorageKey)
	if errors.Is(err, storage.ErrNotFound) {
		return fiber.NewError(fiber.StatusConflict, "upload not found; PUT the file to upload.url first")
	}
	if err != nil {
		return err
	}
	if info.Size <= 0 || info.Size > maxVideoBytes || info.ContentType != m.MimeType {
		_ = h.Media.Store().Delete(ctx, m.StorageKey)
		_ = h.Q.MarkMediaFailed(ctx, m.ID)
		return fiber.NewError(fiber.StatusUnprocessableEntity, "uploaded file does not match the registered video")
	}
	if err := h.Q.MarkVideoReady(ctx, repository.MarkVideoReadyParams{
		ID:        m.ID,
		SizeBytes: pgtype.Int8{Int64: info.Size, Valid: true},
	}); err != nil {
		return err
	}
	m.Status = repository.MediaStatusReady
	m.SizeBytes = pgtype.Int8{Int64: info.Size, Valid: true}
	if isFresh(m.TakenAt) {
		h.Push.NotifyParents(m.ChildID, h.Msgs.MediaReady(m.ChildID, m.ID, repository.MediaKindVideo))
	}
	return h.mediaJSON(c, m)
}

// GetMedia returns one media item with fresh signed URLs.
// GET /api/v1/media/:id
func (h *MobileHandler) GetMedia(c fiber.Ctx) error {
	if err := h.requireStorage(); err != nil {
		return err
	}
	m, err := h.loadMedia(c)
	if err != nil {
		return err
	}
	return h.mediaJSON(c, m)
}

// DeleteMedia removes a photo or video. Idempotent.
// DELETE /api/v1/media/:id
func (h *MobileHandler) DeleteMedia(c fiber.Ctx) error {
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	m, err := h.Q.GetMedia(c.Context(), id)
	if errors.Is(err, pgx.ErrNoRows) || (err == nil && m.DeletedAt != nil) {
		return c.SendStatus(fiber.StatusNoContent)
	}
	if err != nil {
		return err
	}
	if err := h.authorizeChild(c, m.ChildID); err != nil {
		return err
	}
	if err := h.Q.SoftDeleteMedia(c.Context(), id); err != nil {
		return err
	}
	h.Media.DeleteObjects(m)
	return c.SendStatus(fiber.StatusNoContent)
}

// --- helpers ------------------------------------------------------------------

type mediaMeta struct {
	childID    uuid.UUID
	activityID uuid.NullUUID
	takenAt    time.Time
}

// parseMediaMeta validates child access, the optional activity link (must
// be a live activity of the same child) and the capture time.
func (h *MobileHandler) parseMediaMeta(c fiber.Ctx, childStr, activityStr, takenStr string) (mediaMeta, error) {
	var meta mediaMeta
	childID, err := uuid.Parse(childStr)
	if err != nil {
		return meta, fiber.NewError(fiber.StatusBadRequest, "child_id is required")
	}
	meta.childID = childID

	var takenAt *time.Time
	if takenStr != "" {
		t, err := time.Parse(time.RFC3339, takenStr)
		if err != nil {
			return meta, fiber.NewError(fiber.StatusBadRequest, "taken_at must be RFC 3339")
		}
		takenAt = &t
	}
	if meta.takenAt, err = clientTime(takenAt); err != nil {
		return meta, err
	}

	if err := h.authorizeChild(c, childID); err != nil {
		return meta, err
	}

	if activityStr != "" {
		activityID, err := uuid.Parse(activityStr)
		if err != nil {
			return meta, fiber.NewError(fiber.StatusBadRequest, "activity_id is invalid")
		}
		act, err := h.Q.GetActivity(c.Context(), activityID)
		if errors.Is(err, pgx.ErrNoRows) || (err == nil && (act.ChildID != childID || act.DeletedAt != nil)) {
			return meta, fiber.NewError(fiber.StatusUnprocessableEntity, "activity_id does not belong to this child")
		}
		if err != nil {
			return meta, err
		}
		meta.activityID = uuid.NullUUID{UUID: activityID, Valid: true}
	}
	return meta, nil
}

// createMedia inserts the media row, or returns the existing one for a
// retried request (created=false) after checking it matches.
func (h *MobileHandler) createMedia(c fiber.Ctx, id uuid.UUID, meta mediaMeta, kind repository.MediaKind, key, mime string, size int64) (repository.Medium, bool, error) {
	ctx := c.Context()
	m, err := h.Q.CreateMedia(ctx, repository.CreateMediaParams{
		ID:         id,
		ChildID:    meta.childID,
		ActivityID: meta.activityID,
		UploadedBy: middleware.CurrentUser(c).ID,
		Kind:       kind,
		StorageKey: key,
		MimeType:   mime,
		SizeBytes:  pgtype.Int8{Int64: size, Valid: true},
		TakenAt:    meta.takenAt,
	})
	if err == nil {
		return m, true, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return m, false, err
	}
	m, err = h.Q.GetMedia(ctx, id)
	if err != nil {
		return m, false, err
	}
	if m.ChildID != meta.childID || m.Kind != kind {
		return m, false, fiber.NewError(fiber.StatusConflict, "media id is already used for another upload")
	}
	if m.DeletedAt != nil {
		return m, false, fiber.NewError(fiber.StatusConflict, "media was deleted")
	}
	return m, false, nil
}

// loadMedia reads :id and authorizes access to its child.
func (h *MobileHandler) loadMedia(c fiber.Ctx) (repository.Medium, error) {
	id, err := paramUUID(c)
	if err != nil {
		return repository.Medium{}, err
	}
	m, err := h.Q.GetMedia(c.Context(), id)
	if errors.Is(err, pgx.ErrNoRows) || (err == nil && m.DeletedAt != nil) {
		return repository.Medium{}, fiber.NewError(fiber.StatusNotFound, "media not found")
	}
	if err != nil {
		return repository.Medium{}, err
	}
	if err := h.authorizeChild(c, m.ChildID); err != nil {
		return repository.Medium{}, fiber.NewError(fiber.StatusNotFound, "media not found")
	}
	return m, nil
}

func (h *MobileHandler) mediaResponse(c fiber.Ctx, m repository.Medium) (models.MediaResponse, error) {
	if m.Status != repository.MediaStatusReady {
		return models.NewMediaResponse(m, "", "", time.Time{}), nil
	}
	url, thumb, exp, err := h.Media.SignedURLs(c.Context(), m)
	if err != nil {
		return models.MediaResponse{}, err
	}
	return models.NewMediaResponse(m, url, thumb, exp), nil
}

func (h *MobileHandler) mediaJSON(c fiber.Ctx, m repository.Medium) error {
	resp, err := h.mediaResponse(c, m)
	if err != nil {
		return err
	}
	if m.Status == repository.MediaStatusPending {
		c.Status(fiber.StatusAccepted)
	}
	return c.JSON(resp)
}

func (h *MobileHandler) requireStorage() error {
	if h.Media == nil || !h.Media.Enabled() {
		return fiber.NewError(fiber.StatusServiceUnavailable, "media storage is not configured")
	}
	return nil
}
