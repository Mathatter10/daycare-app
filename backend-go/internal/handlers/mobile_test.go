package handlers

import (
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgtype"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

func TestActivityEdited(t *testing.T) {
	start := time.Date(2026, 10, 20, 7, 0, 0, 0, time.UTC)
	end := start.Add(time.Hour)
	later := end.Add(time.Minute)
	sleep := repository.Activity{
		Type: repository.ActivityTypeSleep, StartedAt: start,
		Details: []byte(`{"a": 1, "b": 2}`), Notes: pgtype.Text{},
	}
	ended := sleep
	ended.EndedAt = &end

	cases := []struct {
		name    string
		prev    repository.Activity
		ended   *time.Time
		details string
		notes   string
		want    bool
	}{
		{"offline resend, same data (jsonb key order differs)", sleep, nil, `{"b":2,"a":1}`, "", false},
		{"waking up is not an edit", sleep, &end, `{"a":1,"b":2}`, "", false},
		{"resending the wake-up", ended, &end, `{"a":1,"b":2}`, "", false},
		{"changing the wake-up time", ended, &later, `{"a":1,"b":2}`, "", true},
		{"details changed", sleep, nil, `{"a":1,"b":3}`, "", true},
		{"notes added", sleep, nil, `{"a":1,"b":2}`, "rewel", true},
	}
	for _, c := range cases {
		got := activityEdited(c.prev, repository.ActivityTypeSleep, start, c.ended, []byte(c.details), c.notes)
		if got != c.want {
			t.Errorf("%s: got %v, want %v", c.name, got, c.want)
		}
	}
}
