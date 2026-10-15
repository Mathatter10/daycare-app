package push

import (
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/Mathatter10/daycare-app/backend-go/internal/activity"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

// Messages builds the Indonesian notification texts parents receive.
type Messages struct {
	Location *time.Location // daycare time zone for "pukul 09:15"
}

func (m Messages) clock(t time.Time) string { return t.In(m.Location).Format("15:04") }

func data(kind string, childID, id uuid.UUID) map[string]string {
	return map[string]string{"type": kind, "child_id": childID.String(), "id": id.String()}
}

func (m Messages) CheckIn(childID, attendanceID uuid.UUID, at time.Time) func(string) Message {
	return func(name string) Message {
		return Message{
			Title: fmt.Sprintf("✅ %s sudah tiba di daycare", name),
			Body:  "Check-in pukul " + m.clock(at),
			Data:  data("attendance", childID, attendanceID),
		}
	}
}

func (m Messages) CheckOut(childID, attendanceID uuid.UUID, at time.Time, pickedUpBy string) func(string) Message {
	return func(name string) Message {
		body := "Pukul " + m.clock(at)
		if pickedUpBy != "" {
			body += " oleh " + pickedUpBy
		}
		return Message{
			Title: fmt.Sprintf("👋 %s sudah dijemput", name),
			Body:  body,
			Data:  data("attendance", childID, attendanceID),
		}
	}
}

// ActivityEvent is the subset of an activity a notification needs.
type ActivityEvent struct {
	ID        uuid.UUID
	ChildID   uuid.UUID
	Type      repository.ActivityType
	StartedAt time.Time
	EndedAt   *time.Time
	Details   []byte
	Notes     string
}

func (m Messages) ActivityLogged(e ActivityEvent) func(string) Message {
	return func(name string) Message {
		var title, body string
		switch e.Type {
		case repository.ActivityTypeEat:
			var d activity.Eat
			_ = json.Unmarshal(e.Details, &d)
			title = fmt.Sprintf("🍼 %s makan", name)
			body = join(portionLabel[d.Portion], d.Menu)
		case repository.ActivityTypeSleep:
			if e.EndedAt != nil {
				title = fmt.Sprintf("😴 %s tidur", name)
				body = m.clock(e.StartedAt) + "–" + m.clock(*e.EndedAt) + " (" + duration(e.EndedAt.Sub(e.StartedAt)) + ")"
			} else {
				title = fmt.Sprintf("😴 %s mulai tidur", name)
				body = "Pukul " + m.clock(e.StartedAt)
			}
		case repository.ActivityTypeToilet:
			var d activity.Toilet
			_ = json.Unmarshal(e.Details, &d)
			title = fmt.Sprintf("🧻 %s ke toilet", name)
			body = toiletLabel[d.Kind]
		case repository.ActivityTypePlay:
			var d activity.Play
			_ = json.Unmarshal(e.Details, &d)
			title = fmt.Sprintf("🎨 %s bermain", name)
			body = d.Activity
		case repository.ActivityTypeMedical:
			var d activity.Medical
			_ = json.Unmarshal(e.Details, &d)
			title = fmt.Sprintf("💊 Catatan kesehatan %s", name)
			switch d.Kind {
			case "temperature":
				if d.TemperatureC != nil {
					body = fmt.Sprintf("Suhu %.1f°C", *d.TemperatureC)
				}
			case "medicine":
				body = "Diberi obat: " + d.Medicine
			case "injury":
				body = "Cedera ringan"
			}
		}
		if body == "" {
			body = e.Notes
		}
		if body == "" {
			body = "Pukul " + m.clock(e.StartedAt)
		}
		return Message{Title: title, Body: body, Data: data("activity", e.ChildID, e.ID)}
	}
}

func (m Messages) WokeUp(e ActivityEvent) func(string) Message {
	return func(name string) Message {
		return Message{
			Title: fmt.Sprintf("🌤️ %s sudah bangun", name),
			Body:  "Tidur " + m.clock(e.StartedAt) + "–" + m.clock(*e.EndedAt) + " (" + duration(e.EndedAt.Sub(e.StartedAt)) + ")",
			Data:  data("activity", e.ChildID, e.ID),
		}
	}
}

func (m Messages) MediaReady(childID, mediaID uuid.UUID, kind repository.MediaKind) func(string) Message {
	return func(name string) Message {
		title := fmt.Sprintf("📷 Foto baru %s", name)
		if kind == repository.MediaKindVideo {
			title = fmt.Sprintf("🎬 Video baru %s", name)
		}
		return Message{Title: title, Body: "Ketuk untuk melihat", Data: data("media", childID, mediaID)}
	}
}

var portionLabel = map[string]string{
	"all":    "Habis semua",
	"most":   "Hampir habis",
	"half":   "Setengah porsi",
	"little": "Sedikit",
	"none":   "Tidak mau makan",
}

var toiletLabel = map[string]string{
	"wet":   "Pipis",
	"dirty": "BAB",
	"both":  "Pipis dan BAB",
	"dry":   "Popok kering",
}

func join(parts ...string) string {
	var out []string
	for _, p := range parts {
		if p != "" {
			out = append(out, p)
		}
	}
	return strings.Join(out, " · ")
}

// duration formats like "1 j 15 m" or "40 m".
func duration(d time.Duration) string {
	mins := int(d.Round(time.Minute).Minutes())
	if mins < 60 {
		return fmt.Sprintf("%d m", mins)
	}
	if mins%60 == 0 {
		return fmt.Sprintf("%d j", mins/60)
	}
	return fmt.Sprintf("%d j %d m", mins/60, mins%60)
}
