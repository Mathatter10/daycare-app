package activity

import (
	"encoding/json"
	"testing"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

func TestNormalizeDetails(t *testing.T) {
	tests := []struct {
		typ     repository.ActivityType
		in      string
		want    string // canonical JSON; empty means an error is expected
		comment string
	}{
		{repository.ActivityTypeEat, `{"portion":"half","menu":"Bubur"}`, `{"portion":"half","menu":"Bubur"}`, "valid eat"},
		{repository.ActivityTypeEat, `{"portion":"banyak"}`, "", "bad portion"},
		{repository.ActivityTypeEat, `{"portion":"all","x":1}`, "", "unknown field"},
		{repository.ActivityTypeEat, ``, "", "portion required"},
		{repository.ActivityTypeSleep, ``, `{}`, "sleep empty"},
		{repository.ActivityTypeSleep, `null`, `{}`, "sleep null"},
		{repository.ActivityTypeSleep, `{"x":1}`, "", "sleep rejects fields"},
		{repository.ActivityTypeToilet, `{"kind":"wet"}`, `{"kind":"wet"}`, "valid toilet"},
		{repository.ActivityTypeToilet, `{"kind":"pee"}`, "", "bad toilet kind"},
		{repository.ActivityTypePlay, `{}`, `{}`, "play empty"},
		{repository.ActivityTypeMedical, `{"kind":"temperature","temperature_c":38.5}`, `{"kind":"temperature","temperature_c":38.5}`, "temperature"},
		{repository.ActivityTypeMedical, `{"kind":"temperature","temperature_c":50}`, "", "temperature out of range"},
		{repository.ActivityTypeMedical, `{"kind":"medicine"}`, "", "medicine name required"},
		{repository.ActivityTypeMedical, `{"kind":"injury"}`, `{"kind":"injury"}`, "injury"},
	}
	for _, tt := range tests {
		got, err := NormalizeDetails(tt.typ, json.RawMessage(tt.in))
		if tt.want == "" {
			if err == nil {
				t.Errorf("%s: expected error, got %s", tt.comment, got)
			}
			continue
		}
		if err != nil {
			t.Errorf("%s: unexpected error %v", tt.comment, err)
			continue
		}
		if string(got) != tt.want {
			t.Errorf("%s: got %s, want %s", tt.comment, got, tt.want)
		}
	}
}
