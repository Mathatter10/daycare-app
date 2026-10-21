package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/Mathatter10/daycare-app/backend-go/internal/activity"
	"github.com/Mathatter10/daycare-app/backend-go/internal/media"
	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
	"github.com/Mathatter10/daycare-app/backend-go/internal/models"
	"github.com/Mathatter10/daycare-app/backend-go/internal/push"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

const (
	// maxFutureSkew tolerates phone clocks running slightly ahead.
	maxFutureSkew = 5 * time.Minute
	// maxOfflineAge is how old a queued offline record may be when it
	// finally reaches the server.
	maxOfflineAge = 7 * 24 * time.Hour
)

// MobileHandler serves the caregiver and parent JSON API. All routes run
// behind middleware.RequireJWT; write routes also require the caregiver role.
//
// Every child-scoped request is authorized with CanAccessChild. A child the
// user may not see answers 404, not 403, so IDs cannot be probed.
type MobileHandler struct {
	DB       *pgxpool.Pool
	Q        *repository.Queries
	Location *time.Location // daycare time zone; defines "today"
	Media    *media.Service
	Push     *push.Dispatcher
	Msgs     push.Messages
}

func NewMobileHandler(pool *pgxpool.Pool, loc *time.Location, mediaSvc *media.Service, dispatcher *push.Dispatcher) *MobileHandler {
	return &MobileHandler{
		DB:       pool,
		Q:        repository.New(pool),
		Location: loc,
		Media:    mediaSvc,
		Push:     dispatcher,
		Msgs:     push.Messages{Location: loc},
	}
}

// --- Children -----------------------------------------------------------------

// Children lists the children the user may see, with today's attendance.
// GET /api/v1/children
func (h *MobileHandler) Children(c fiber.Ctx) error {
	rows, err := h.accessibleChildren(c.Context(), middleware.CurrentUser(c))
	if err != nil {
		return err
	}
	out := make([]models.ChildResponse, len(rows))
	for i, r := range rows {
		out[i] = models.NewChildResponse(r)
	}
	return c.JSON(fiber.Map{"children": out})
}

// Timeline returns one day of a child's attendance and activities.
// GET /api/v1/children/:id/timeline?date=YYYY-MM-DD (default: today)
func (h *MobileHandler) Timeline(c fiber.Ctx) error {
	childID, err := paramUUID(c)
	if err != nil {
		return err
	}
	if err := h.authorizeChild(c, childID); err != nil {
		return err
	}

	day := h.today()
	if q := c.Query("date"); q != "" {
		day, err = time.ParseInLocation(models.DateLayout, q, h.Location)
		if err != nil {
			return fiber.NewError(fiber.StatusBadRequest, "date must be YYYY-MM-DD")
		}
	}

	ctx := c.Context()
	rows, err := h.Q.ListChildActivities(ctx, repository.ListChildActivitiesParams{
		ChildID:  childID,
		FromTime: day,
		ToTime:   day.AddDate(0, 0, 1),
	})
	if err != nil {
		return err
	}
	activities := make([]models.ActivityResponse, len(rows))
	for i, r := range rows {
		activities[i] = models.NewActivityResponse(repository.GetActivityViewRow(r))
	}

	var attendance *models.AttendanceResponse
	att, err := h.Q.GetAttendance(ctx, repository.GetAttendanceParams{ChildID: childID, AttendanceDate: dateOnly(day)})
	switch {
	case err == nil:
		resp := models.NewAttendanceResponse(att)
		attendance = &resp
	case !errors.Is(err, pgx.ErrNoRows):
		return err
	}

	mediaItems := []models.MediaResponse{}
	if h.Media != nil && h.Media.Enabled() {
		rows, err := h.Q.ListChildMedia(ctx, repository.ListChildMediaParams{
			ChildID:  childID,
			FromTime: day,
			ToTime:   day.AddDate(0, 0, 1),
		})
		if err != nil {
			return err
		}
		for _, m := range rows {
			item, err := h.mediaResponse(c, m)
			if err != nil {
				return err
			}
			mediaItems = append(mediaItems, item)
		}
	}

	return c.JSON(fiber.Map{
		"date":       day.Format(models.DateLayout),
		"attendance": attendance,
		"activities": activities,
		"media":      mediaItems,
	})
}

// --- Attendance (caregiver) -----------------------------------------------------

type checkInRequest struct {
	ChildID uuid.UUID  `json:"child_id"`
	At      *time.Time `json:"at"` // optional; offline clients send the original time
}

type checkOutRequest struct {
	ChildID    uuid.UUID  `json:"child_id"`
	At         *time.Time `json:"at"`
	PickedUpBy string     `json:"picked_up_by"`
}

// CheckIn records arrival. Idempotent: resending keeps the earliest time.
// POST /api/v1/attendance/check-in
func (h *MobileHandler) CheckIn(c fiber.Ctx) error {
	var req checkInRequest
	if err := c.Bind().JSON(&req); err != nil || req.ChildID == uuid.Nil {
		return fiber.NewError(fiber.StatusBadRequest, "child_id is required")
	}
	if err := h.authorizeChild(c, req.ChildID); err != nil {
		return err
	}
	at, err := clientTime(req.At)
	if err != nil {
		return err
	}

	row, err := h.Q.CheckIn(c.Context(), repository.CheckInParams{
		ChildID:        req.ChildID,
		AttendanceDate: dateOnly(h.dayOf(at)),
		CheckInAt:      at,
		CheckInBy:      middleware.CurrentUser(c).ID,
	})
	if err != nil {
		return err
	}
	if row.Inserted && isFresh(at) {
		h.Push.NotifyParents(row.ChildID, h.Msgs.CheckIn(row.ChildID, row.ID, at))
	}
	return c.JSON(models.NewAttendanceResponse(repository.Attendance{
		ID:             row.ID,
		ChildID:        row.ChildID,
		AttendanceDate: row.AttendanceDate,
		CheckInAt:      row.CheckInAt,
		CheckInBy:      row.CheckInBy,
		CheckOutAt:     row.CheckOutAt,
		CheckOutBy:     row.CheckOutBy,
		PickedUpBy:     row.PickedUpBy,
		Notes:          row.Notes,
		CreatedAt:      row.CreatedAt,
		UpdatedAt:      row.UpdatedAt,
	}))
}

// CheckOut records pick-up for the day of `at`. Resending overwrites with
// the latest values.
// POST /api/v1/attendance/check-out
func (h *MobileHandler) CheckOut(c fiber.Ctx) error {
	var req checkOutRequest
	if err := c.Bind().JSON(&req); err != nil || req.ChildID == uuid.Nil {
		return fiber.NewError(fiber.StatusBadRequest, "child_id is required")
	}
	req.PickedUpBy = strings.TrimSpace(req.PickedUpBy)
	if utf8.RuneCountInString(req.PickedUpBy) > 100 {
		return fiber.NewError(fiber.StatusUnprocessableEntity, "picked_up_by must be at most 100 characters")
	}
	if err := h.authorizeChild(c, req.ChildID); err != nil {
		return err
	}
	at, err := clientTime(req.At)
	if err != nil {
		return err
	}

	ctx := c.Context()
	day := dateOnly(h.dayOf(at))
	existing, err := h.Q.GetAttendance(ctx, repository.GetAttendanceParams{ChildID: req.ChildID, AttendanceDate: day})
	if errors.Is(err, pgx.ErrNoRows) {
		return fiber.NewError(fiber.StatusConflict, "child is not checked in on this day")
	}
	if err != nil {
		return err
	}
	if at.Before(existing.CheckInAt) {
		return fiber.NewError(fiber.StatusUnprocessableEntity, "check-out time is before check-in time")
	}

	att, err := h.Q.CheckOut(ctx, repository.CheckOutParams{
		ChildID:        req.ChildID,
		AttendanceDate: day,
		CheckOutAt:     &at,
		CheckOutBy:     uuid.NullUUID{UUID: middleware.CurrentUser(c).ID, Valid: true},
		PickedUpBy:     textOrNull(req.PickedUpBy),
	})
	if err != nil {
		return err
	}
	if existing.CheckOutAt == nil && isFresh(at) {
		h.Push.NotifyParents(att.ChildID, h.Msgs.CheckOut(att.ChildID, att.ID, at, req.PickedUpBy))
	}
	return c.JSON(models.NewAttendanceResponse(att))
}

// --- Activities (caregiver) ----------------------------------------------------

type activityRequest struct {
	ChildID   uuid.UUID       `json:"child_id"`
	Type      string          `json:"type"`
	StartedAt *time.Time      `json:"started_at"`
	EndedAt   *time.Time      `json:"ended_at"`
	Details   json.RawMessage `json:"details"`
	Notes     string          `json:"notes"`
}

// PutActivity creates or updates an activity with a client-generated UUID.
// Idempotent, so an offline queue can resend it safely.
// PUT /api/v1/activities/:id
func (h *MobileHandler) PutActivity(c fiber.Ctx) error {
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	var req activityRequest
	if err := c.Bind().JSON(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid JSON body")
	}
	if req.ChildID == uuid.Nil {
		return fiber.NewError(fiber.StatusBadRequest, "child_id is required")
	}

	typ := repository.ActivityType(req.Type)
	if !activity.ValidType(typ) {
		return fiber.NewError(fiber.StatusUnprocessableEntity, "type must be one of eat, sleep, toilet, play, medical")
	}
	if req.StartedAt == nil {
		return fiber.NewError(fiber.StatusUnprocessableEntity, "started_at is required")
	}
	startedAt, err := clientTime(req.StartedAt)
	if err != nil {
		return err
	}
	if req.EndedAt != nil {
		if !activity.AllowsEndTime(typ) {
			return fiber.NewError(fiber.StatusUnprocessableEntity, "ended_at is only allowed for sleep and play")
		}
		if req.EndedAt.Before(startedAt) {
			return fiber.NewError(fiber.StatusUnprocessableEntity, "ended_at is before started_at")
		}
		if _, err := clientTime(req.EndedAt); err != nil {
			return err
		}
	}
	details, err := activity.NormalizeDetails(typ, req.Details)
	if err != nil {
		return fiber.NewError(fiber.StatusUnprocessableEntity, err.Error())
	}
	req.Notes = strings.TrimSpace(req.Notes)
	if utf8.RuneCountInString(req.Notes) > 1000 {
		return fiber.NewError(fiber.StatusUnprocessableEntity, "notes must be at most 1000 characters")
	}

	if err := h.authorizeChild(c, req.ChildID); err != nil {
		return err
	}

	ctx := c.Context()
	prev, err := h.Q.GetActivity(ctx, id)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return err
	}
	hadEnd := err == nil && prev.EndedAt != nil

	upserted, err := h.Q.UpsertActivity(ctx, repository.UpsertActivityParams{
		ID:          id,
		ChildID:     req.ChildID,
		CaregiverID: middleware.CurrentUser(c).ID,
		Type:        typ,
		StartedAt:   startedAt,
		EndedAt:     req.EndedAt,
		Details:     details,
		Notes:       textOrNull(req.Notes),
	})
	if errors.Is(err, pgx.ErrNoRows) {
		// The id exists but the conditional update was skipped.
		existing, getErr := h.Q.GetActivity(ctx, id)
		if getErr != nil {
			return getErr
		}
		if existing.DeletedAt != nil {
			return fiber.NewError(fiber.StatusConflict, "activity was deleted")
		}
		return fiber.NewError(fiber.StatusConflict, "activity id is already used for another child")
	}
	if err != nil {
		return err
	}

	event := push.ActivityEvent{
		ID: id, ChildID: req.ChildID, Type: typ, StartedAt: startedAt,
		EndedAt: req.EndedAt, Details: details, Notes: req.Notes,
	}
	switch {
	case upserted.Inserted && isFresh(startedAt):
		h.Push.NotifyParents(req.ChildID, h.Msgs.ActivityLogged(event))
	case !upserted.Inserted && typ == repository.ActivityTypeSleep && !hadEnd && req.EndedAt != nil && isFresh(*req.EndedAt):
		h.Push.NotifyParents(req.ChildID, h.Msgs.WokeUp(event))
	}

	row, err := h.Q.GetActivityView(ctx, id)
	if err != nil {
		return err
	}
	return c.JSON(models.NewActivityResponse(row))
}

// DeleteActivity soft-deletes an activity so the deletion syncs to other
// devices. Idempotent: deleting an unknown or already-deleted id is a 204.
// DELETE /api/v1/activities/:id
func (h *MobileHandler) DeleteActivity(c fiber.Ctx) error {
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	existing, err := h.Q.GetActivity(c.Context(), id)
	if errors.Is(err, pgx.ErrNoRows) {
		return c.SendStatus(fiber.StatusNoContent)
	}
	if err != nil {
		return err
	}
	if err := h.authorizeChild(c, existing.ChildID); err != nil {
		return err
	}
	user := middleware.CurrentUser(c)
	n, err := h.Q.SoftDeleteActivity(c.Context(), repository.SoftDeleteActivityParams{
		ID:        id,
		DeletedBy: uuid.NullUUID{UUID: user.ID, Valid: true},
	})
	if err != nil {
		return err
	}
	if n > 0 {
		// Deletes are rare and hard to explain afterwards; keep a trace.
		slog.Info("activity deleted", "activity_id", id, "child_id", existing.ChildID,
			"by", user.ID, "user_agent", c.Get(fiber.HeaderUserAgent))
	}
	return c.SendStatus(fiber.StatusNoContent)
}

// --- helpers ------------------------------------------------------------------

func (h *MobileHandler) accessibleChildren(ctx context.Context, user repository.User) ([]repository.ListAccessibleChildrenRow, error) {
	return h.Q.ListAccessibleChildren(ctx, repository.ListAccessibleChildrenParams{
		Today:  dateOnly(h.today()),
		Role:   user.Role,
		UserID: user.ID,
	})
}

// authorizeChild enforces the RBAC rules of docs/SECURITY.md for one child.
func (h *MobileHandler) authorizeChild(c fiber.Ctx, childID uuid.UUID) error {
	user := middleware.CurrentUser(c)
	ok, err := h.Q.CanAccessChild(c.Context(), repository.CanAccessChildParams{
		ChildID: childID,
		Role:    user.Role,
		UserID:  user.ID,
	})
	if err != nil {
		return err
	}
	if !ok {
		return fiber.NewError(fiber.StatusNotFound, "child not found")
	}
	return nil
}

// today returns midnight of the current day in the daycare time zone.
func (h *MobileHandler) today() time.Time {
	return h.dayOf(time.Now())
}

// dayOf returns midnight of t's calendar day in the daycare time zone.
func (h *MobileHandler) dayOf(t time.Time) time.Time {
	y, m, d := t.In(h.Location).Date()
	return time.Date(y, m, d, 0, 0, 0, 0, h.Location)
}

// dateOnly converts a daycare-local midnight to the UTC midnight of the same
// calendar date, which is how pgx encodes a Postgres DATE parameter.
func dateOnly(day time.Time) time.Time {
	y, m, d := day.Date()
	return time.Date(y, m, d, 0, 0, 0, 0, time.UTC)
}

// isFresh reports whether an event is recent enough to notify parents
// about; records replayed from a long offline queue stay silent.
func isFresh(t time.Time) bool {
	return time.Since(t) < 2*time.Hour
}

// clientTime validates a timestamp sent by a (possibly offline) client;
// nil means "now".
func clientTime(t *time.Time) (time.Time, error) {
	now := time.Now()
	if t == nil {
		return now, nil
	}
	if t.After(now.Add(maxFutureSkew)) {
		return time.Time{}, fiber.NewError(fiber.StatusUnprocessableEntity, "time is in the future; check the device clock")
	}
	if t.Before(now.Add(-maxOfflineAge)) {
		return time.Time{}, fiber.NewError(fiber.StatusUnprocessableEntity, "time is older than 7 days")
	}
	return *t, nil
}
