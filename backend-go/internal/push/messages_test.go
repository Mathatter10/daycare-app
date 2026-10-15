package push

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

func TestMessages(t *testing.T) {
	jkt, err := time.LoadLocation("Asia/Jakarta")
	if err != nil {
		t.Fatal(err)
	}
	m := Messages{Location: jkt}
	start := time.Date(2026, 10, 15, 2, 15, 0, 0, time.UTC) // 09:15 WIB
	end := start.Add(75 * time.Minute)
	child, id := uuid.New(), uuid.New()

	tests := []struct {
		name      string
		msg       Message
		wantTitle string
		wantBody  string
	}{
		{"check-in", m.CheckIn(child, id, start)("Citra"),
			"✅ Citra sudah tiba di daycare", "Check-in pukul 09:15"},
		{"check-out", m.CheckOut(child, id, end, "Nenek")("Citra"),
			"👋 Citra sudah dijemput", "Pukul 10:30 oleh Nenek"},
		{"eat", m.ActivityLogged(ActivityEvent{ChildID: child, Type: repository.ActivityTypeEat, StartedAt: start,
			Details: []byte(`{"portion":"half","menu":"Bubur ayam"}`)})("Citra"),
			"🍼 Citra makan", "Setengah porsi · Bubur ayam"},
		{"sleep start", m.ActivityLogged(ActivityEvent{ChildID: child, Type: repository.ActivityTypeSleep, StartedAt: start})("Citra"),
			"😴 Citra mulai tidur", "Pukul 09:15"},
		{"woke up", m.WokeUp(ActivityEvent{ChildID: child, Type: repository.ActivityTypeSleep, StartedAt: start, EndedAt: &end})("Citra"),
			"🌤️ Citra sudah bangun", "Tidur 09:15–10:30 (1 j 15 m)"},
		{"temperature", m.ActivityLogged(ActivityEvent{ChildID: child, Type: repository.ActivityTypeMedical, StartedAt: start,
			Details: []byte(`{"kind":"temperature","temperature_c":37.8}`)})("Citra"),
			"💊 Catatan kesehatan Citra", "Suhu 37.8°C"},
		{"toilet", m.ActivityLogged(ActivityEvent{ChildID: child, Type: repository.ActivityTypeToilet, StartedAt: start,
			Details: []byte(`{"kind":"both"}`)})("Citra"),
			"🧻 Citra ke toilet", "Pipis dan BAB"},
		{"play without details falls back to time", m.ActivityLogged(ActivityEvent{ChildID: child, Type: repository.ActivityTypePlay, StartedAt: start,
			Details: []byte(`{}`)})("Citra"),
			"🎨 Citra bermain", "Pukul 09:15"},
		{"video", m.MediaReady(child, id, repository.MediaKindVideo)("Citra"),
			"🎬 Video baru Citra", "Ketuk untuk melihat"},
	}
	for _, tt := range tests {
		if tt.msg.Title != tt.wantTitle || tt.msg.Body != tt.wantBody {
			t.Errorf("%s: got %q / %q, want %q / %q", tt.name, tt.msg.Title, tt.msg.Body, tt.wantTitle, tt.wantBody)
		}
		if tt.msg.Data["child_id"] != child.String() {
			t.Errorf("%s: data.child_id missing", tt.name)
		}
	}
}

func TestDisplayName(t *testing.T) {
	if got := displayName(repository.GetChildNamesRow{FullName: "Citra Ayu Lestari"}); got != "Citra" {
		t.Errorf("first name: got %q", got)
	}
	if got := displayName(repository.GetChildNamesRow{FullName: "Citra Ayu", Nickname: pgtype.Text{String: "Caca", Valid: true}}); got != "Caca" {
		t.Errorf("nickname: got %q", got)
	}
}
