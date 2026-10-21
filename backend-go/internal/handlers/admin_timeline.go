package handlers

import (
	"errors"
	"fmt"
	"sort"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
	"github.com/Mathatter10/daycare-app/backend-go/internal/push"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
	"github.com/Mathatter10/daycare-app/backend-go/internal/views"
)

// lateEntry is when an activity reaching the server after the time it
// happened is worth pointing out (logged afterwards or sent offline).
const lateEntry = 10 * time.Minute

var eventLabel = map[repository.ActivityEventAction]string{
	repository.ActivityEventActionEdited:   "Diubah",
	repository.ActivityEventActionDeleted:  "DIHAPUS",
	repository.ActivityEventActionRestored: "Dipulihkan",
}

// ChildTimeline shows one day of a child in chronological order, including
// deleted activities and who recorded what, so it can serve as the basis
// of an incident report (printable).
// GET /admin/children/:id/timeline?date=YYYY-MM-DD   (default: today)
func (h *AdminHandler) ChildTimeline(c fiber.Ctx) error {
	childID, err := paramUUID(c)
	if err != nil {
		return err
	}
	today := h.dayOf(time.Now())
	day := today
	if q := c.Query("date"); q != "" {
		if day, err = time.ParseInLocation(dateLayout, q, h.Location); err != nil {
			return fiber.NewError(fiber.StatusBadRequest, "date must be YYYY-MM-DD")
		}
	}

	ctx := c.Context()
	child, err := h.Q.GetChildReportHeader(ctx, childID)
	if errors.Is(err, pgx.ErrNoRows) {
		return fiber.ErrNotFound
	}
	if err != nil {
		return err
	}
	name := child.FullName
	if child.Nickname.Valid && child.Nickname.String != "" {
		name = child.Nickname.String
	}

	r := views.TimelineReport{
		ChildID:      child.ID.String(),
		ChildName:    child.FullName,
		Nickname:     child.Nickname.String,
		ClassName:    child.ClassName,
		DateOfBirth:  child.DateOfBirth,
		Allergies:    child.Allergies.String,
		MedicalNotes: child.MedicalNotes.String,
		ParentName:   child.ParentName,
		ParentPhone:  child.ParentPhone.String,
		Inactive:     !child.IsActive,
		Date:         day,
		PrevDate:     day.AddDate(0, 0, -1).Format(dateLayout),
		Today:        today.Format(dateLayout),
		GeneratedAt:  time.Now().In(h.Location),
		GeneratedBy:  middleware.CurrentUser(c).FullName,
	}
	if day.Before(today) {
		r.NextDate = day.AddDate(0, 0, 1).Format(dateLayout)
	}

	att, err := h.Q.GetAttendanceReport(ctx, repository.GetAttendanceReportParams{ChildID: childID, AttendanceDate: dateOnly(day)})
	switch {
	case err == nil:
		r.Entries = append(r.Entries, views.TimelineEntry{
			At: att.CheckInAt.In(h.Location), Kind: "checkin",
			Title: "✅ Tiba (check-in)", By: att.CheckInByName,
		})
		if att.CheckOutAt != nil {
			desc := ""
			if att.PickedUpBy.Valid {
				desc = "Dijemput " + att.PickedUpBy.String
			}
			r.Entries = append(r.Entries, views.TimelineEntry{
				At: att.CheckOutAt.In(h.Location), Kind: "checkout",
				Title: "👋 Pulang (check-out)", Description: desc, By: att.CheckOutByName.String,
			})
		}
		r.AttendanceNote = att.Notes.String
	case !errors.Is(err, pgx.ErrNoRows):
		return err
	}

	acts, err := h.Q.ListChildDayActivitiesReport(ctx, repository.ListChildDayActivitiesReportParams{
		ChildID: childID, FromTime: day, ToTime: day.AddDate(0, 0, 1),
	})
	if err != nil {
		return err
	}
	events, err := h.Q.ListChildDayActivityEvents(ctx, repository.ListChildDayActivityEventsParams{
		ChildID: childID, FromTime: day, ToTime: day.AddDate(0, 0, 1),
	})
	if err != nil {
		return err
	}
	history := map[uuid.UUID][]string{}
	for _, ev := range events {
		by := "(tidak tercatat)"
		if ev.ActorName.Valid {
			by = ev.ActorName.String
		}
		history[ev.ActivityID] = append(history[ev.ActivityID],
			fmt.Sprintf("%s %s oleh %s", eventLabel[ev.Action], views.DateTimeLabel(ev.At.In(h.Location)), by))
	}

	msgs := push.Messages{Location: h.Location}
	for _, a := range acts {
		msg := msgs.ActivityLogged(push.ActivityEvent{
			Type: a.Type, StartedAt: a.StartedAt, EndedAt: a.EndedAt,
			Details: a.Details, Notes: a.Notes.String,
		})(name)
		e := views.TimelineEntry{
			At: a.StartedAt.In(h.Location), Kind: "activity",
			Title: msg.Title, Description: msg.Body, By: a.CaregiverName,
			Deleted: a.DeletedAt != nil,
		}
		if a.Notes.Valid && a.Notes.String != "" && a.Notes.String != msg.Body {
			e.Description += " · " + a.Notes.String
		}
		if late := a.CreatedAt.Sub(a.StartedAt); late > lateEntry {
			e.Audit = append(e.Audit, fmt.Sprintf("Masuk ke server %s (%s setelah kejadian)", h.clock(a.CreatedAt), lateLabel(late)))
		}
		e.Audit = append(e.Audit, history[a.ID]...)
		if a.DeletedAt != nil {
			r.DeletedCount++
		} else {
			r.ActivityCount++
		}
		r.Entries = append(r.Entries, e)
	}

	if h.Media == nil || !h.Media.Enabled() {
		r.MediaUnavailable = true
	} else {
		media, err := h.Q.ListChildDayMediaReport(ctx, repository.ListChildDayMediaReportParams{
			ChildID: childID, FromTime: day, ToTime: day.AddDate(0, 0, 1),
		})
		if err != nil {
			return err
		}
		for _, m := range media {
			url, thumb, _, err := h.Media.SignedURLs(ctx, m.Medium)
			if err != nil {
				return err
			}
			title := "📷 Foto"
			if m.Medium.Kind == repository.MediaKindVideo {
				title = "🎬 Video"
			}
			r.Entries = append(r.Entries, views.TimelineEntry{
				At: m.Medium.TakenAt.In(h.Location), Kind: "media",
				Title: title, By: m.UploadedByName, URL: url, ThumbURL: thumb,
			})
			r.MediaCount++
		}
	}

	sort.SliceStable(r.Entries, func(i, j int) bool { return r.Entries[i].At.Before(r.Entries[j].At) })

	if isRowsRequest(c, "timeline") {
		return views.Render(c, views.TimelineBody(r))
	}
	return views.Render(c, views.ChildTimelinePage(h.page(c, "Timeline "+child.FullName, "children"), r))
}

func (h *AdminHandler) dayOf(t time.Time) time.Time {
	y, m, d := t.In(h.Location).Date()
	return time.Date(y, m, d, 0, 0, 0, 0, h.Location)
}

func (h *AdminHandler) clock(t time.Time) string { return t.In(h.Location).Format("15:04") }

// lateLabel formats a delay like "40 menit" or "2 jam 5 menit".
func lateLabel(d time.Duration) string {
	mins := int(d.Round(time.Minute).Minutes())
	switch {
	case mins < 60:
		return fmt.Sprintf("%d menit", mins)
	case mins%60 == 0:
		return fmt.Sprintf("%d jam", mins/60)
	default:
		return fmt.Sprintf("%d jam %d menit", mins/60, mins%60)
	}
}
