package handlers

import (
	"log/slog"
	"time"

	"github.com/gofiber/fiber/v3"

	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
	"github.com/Mathatter10/daycare-app/backend-go/internal/push"
	"github.com/Mathatter10/daycare-app/backend-go/internal/views"
)

// deletedActivityWindow is how far back the admin can see and restore
// deleted activities.
const deletedActivityWindow = 30 * 24 * time.Hour

// DeletedActivities lists activities deleted in the last 30 days.
// GET /admin/activities/deleted
func (h *AdminHandler) DeletedActivities(c fiber.Ctx) error {
	rows, err := h.Q.ListDeletedActivities(c.Context(), time.Now().Add(-deletedActivityWindow))
	if err != nil {
		return err
	}
	msgs := push.Messages{Location: h.Location}
	items := make([]views.DeletedActivity, len(rows))
	for i, r := range rows {
		name := r.ChildName
		if r.ChildNickname != "" {
			name = r.ChildNickname
		}
		// The notification text already describes an activity in one line.
		msg := msgs.ActivityLogged(push.ActivityEvent{
			Type: r.Type, StartedAt: r.StartedAt, EndedAt: r.EndedAt,
			Details: r.Details, Notes: r.Notes.String,
		})(name)
		items[i] = views.DeletedActivity{
			ID:            r.ID.String(),
			ChildName:     r.ChildName,
			Title:         msg.Title,
			Description:   msg.Body,
			StartedAt:     r.StartedAt.In(h.Location),
			CaregiverName: r.CaregiverName,
			DeletedAt:     r.DeletedAt.In(h.Location),
			DeletedBy:     r.DeletedByName.String,
		}
	}
	return views.Render(c, views.DeletedActivitiesPage(h.page(c, "Aktivitas terhapus", "deleted"), items))
}

// RestoreActivity undoes a delete. The row's updated_at changes, so the
// activity reappears on phones at their next sync.
// POST /admin/activities/:id/restore
func (h *AdminHandler) RestoreActivity(c fiber.Ctx) error {
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	n, err := h.Q.RestoreActivity(c.Context(), id)
	if err != nil {
		return err
	}
	if n > 0 {
		slog.Info("activity restored", "activity_id", id, "by", middleware.CurrentUser(c).ID)
	}
	// Restored now or by someone else before: either way it leaves the list.
	return views.Render(c, views.RestoredRow())
}
