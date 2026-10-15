package handlers

import (
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"

	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
	"github.com/Mathatter10/daycare-app/backend-go/internal/models"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

const (
	syncPageSize = 500
	// syncWindow limits how far back a fresh device pulls; older history is
	// read online through the timeline endpoint.
	syncWindow = 14 * 24 * time.Hour
	// syncOverlap re-sends the last few seconds of changes on every pull, so
	// a row whose transaction committed slightly after its updated_at was
	// stamped is never skipped. Clients upsert by id, so repeats are harmless.
	syncOverlap = 30 * time.Second
)

// syncCursor marks the last (updated_at, id) a client has received.
type syncCursor struct {
	At time.Time
	ID uuid.UUID
}

func parseCursor(s string) (syncCursor, error) {
	if s == "" {
		return syncCursor{At: time.Unix(0, 0)}, nil
	}
	nanos, idStr, ok := strings.Cut(s, "_")
	n, err := strconv.ParseInt(nanos, 10, 64)
	if !ok || err != nil {
		return syncCursor{}, fmt.Errorf("invalid cursor")
	}
	id, err := uuid.Parse(idStr)
	if err != nil {
		return syncCursor{}, fmt.Errorf("invalid cursor")
	}
	return syncCursor{At: time.Unix(0, n), ID: id}, nil
}

func (c syncCursor) String() string {
	return strconv.FormatInt(c.At.UnixNano(), 10) + "_" + c.ID.String()
}

// nextCursor returns the cursor for the next pull. A full page continues
// right after its last row; otherwise the cursor is pulled back to
// now-syncOverlap at most.
func nextCursor(prev syncCursor, lastAt *time.Time, lastID uuid.UUID, full bool) syncCursor {
	next := prev
	if lastAt != nil {
		next = syncCursor{At: *lastAt, ID: lastID}
	}
	if full {
		return next
	}
	if limit := time.Now().Add(-syncOverlap); next.At.After(limit) {
		return syncCursor{At: limit, ID: uuid.Nil}
	}
	return next
}

type syncPage[T any] struct {
	Items      []T    `json:"items"`
	NextCursor string `json:"next_cursor"`
	HasMore    bool   `json:"has_more"`
}

// Sync returns everything an offline-first client needs to update its
// local database:
//   - children: the complete list the user may currently see. Delete local
//     children (and their records) that are not in it.
//   - activities / attendance: rows changed since the given cursors,
//     including soft-deleted activities (deleted_at set). Upsert by id.
//
// Call again with the returned next_cursor values while has_more is true.
// GET /api/v1/sync?activities_cursor=&attendance_cursor=
func (h *MobileHandler) Sync(c fiber.Ctx) error {
	actCur, err := parseCursor(c.Query("activities_cursor"))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid activities_cursor")
	}
	attCur, err := parseCursor(c.Query("attendance_cursor"))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid attendance_cursor")
	}

	ctx := c.Context()
	serverTime := time.Now()
	childRows, err := h.accessibleChildren(ctx, middleware.CurrentUser(c))
	if err != nil {
		return err
	}
	children := make([]models.ChildResponse, len(childRows))
	childIDs := make([]uuid.UUID, len(childRows))
	for i, r := range childRows {
		children[i] = models.NewChildResponse(r)
		childIDs[i] = r.ID
	}
	windowStart := h.dayOf(serverTime.Add(-syncWindow))

	actRows, err := h.Q.SyncActivities(ctx, repository.SyncActivitiesParams{
		ChildIds:    childIDs,
		WindowStart: windowStart,
		AfterTime:   actCur.At,
		AfterID:     actCur.ID,
		MaxRows:     syncPageSize,
	})
	if err != nil {
		return err
	}
	activities := syncPage[models.ActivityResponse]{Items: make([]models.ActivityResponse, len(actRows))}
	var lastAct *time.Time
	var lastActID uuid.UUID
	for i, r := range actRows {
		activities.Items[i] = models.NewActivityResponse(repository.GetActivityViewRow(r))
		lastAct, lastActID = &r.UpdatedAt, r.ID
	}
	activities.HasMore = len(actRows) == syncPageSize
	activities.NextCursor = nextCursor(actCur, lastAct, lastActID, activities.HasMore).String()

	attRows, err := h.Q.SyncAttendance(ctx, repository.SyncAttendanceParams{
		ChildIds:    childIDs,
		WindowStart: dateOnly(windowStart),
		AfterTime:   attCur.At,
		AfterID:     attCur.ID,
		MaxRows:     syncPageSize,
	})
	if err != nil {
		return err
	}
	attendance := syncPage[models.AttendanceResponse]{Items: make([]models.AttendanceResponse, len(attRows))}
	var lastAtt *time.Time
	var lastAttID uuid.UUID
	for i, r := range attRows {
		attendance.Items[i] = models.NewAttendanceResponse(r)
		lastAtt, lastAttID = &r.UpdatedAt, r.ID
	}
	attendance.HasMore = len(attRows) == syncPageSize
	attendance.NextCursor = nextCursor(attCur, lastAtt, lastAttID, attendance.HasMore).String()

	return c.JSON(fiber.Map{
		"server_time": serverTime.UTC(),
		"children":    children,
		"activities":  activities,
		"attendance":  attendance,
	})
}
