// Package activity validates the type-specific details of timeline entries.
// Details are strict (unknown fields rejected) so every client writes the
// same shape and the parent app can render them without guessing.
package activity

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"slices"
	"unicode/utf8"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

// Eat: how much of the meal was finished.
type Eat struct {
	Portion string `json:"portion"`        // all | most | half | little | none
	Menu    string `json:"menu,omitempty"` // e.g. "Bubur ayam"
}

// Toilet: diaper / potty result.
type Toilet struct {
	Kind string `json:"kind"` // wet | dirty | both | dry
}

// Play: optional description of the activity.
type Play struct {
	Activity string `json:"activity,omitempty"`
}

// Medical: temperature checks, medicine given, injuries.
type Medical struct {
	Kind         string   `json:"kind"`                    // temperature | medicine | injury | other
	TemperatureC *float64 `json:"temperature_c,omitempty"` // required for temperature
	Medicine     string   `json:"medicine,omitempty"`      // required for medicine
}

// Sleep has no details; duration comes from started_at / ended_at.
type Sleep struct{}

var (
	portions     = []string{"all", "most", "half", "little", "none"}
	toiletKinds  = []string{"wet", "dirty", "both", "dry"}
	medicalKinds = []string{"temperature", "medicine", "injury", "other"}
)

// AllowsEndTime reports whether an activity type has a duration.
func AllowsEndTime(t repository.ActivityType) bool {
	return t == repository.ActivityTypeSleep || t == repository.ActivityTypePlay
}

// ValidType reports whether t is a known activity type.
func ValidType(t repository.ActivityType) bool {
	switch t {
	case repository.ActivityTypeEat, repository.ActivityTypeSleep, repository.ActivityTypeToilet,
		repository.ActivityTypePlay, repository.ActivityTypeMedical:
		return true
	}
	return false
}

// NormalizeDetails validates raw details for the given type and returns the
// canonical JSON to store. Empty input is treated as {}.
func NormalizeDetails(t repository.ActivityType, raw json.RawMessage) ([]byte, error) {
	if len(bytes.TrimSpace(raw)) == 0 || bytes.Equal(bytes.TrimSpace(raw), []byte("null")) {
		raw = json.RawMessage("{}")
	}

	switch t {
	case repository.ActivityTypeEat:
		var d Eat
		if err := decodeStrict(raw, &d); err != nil {
			return nil, err
		}
		if !slices.Contains(portions, d.Portion) {
			return nil, fmt.Errorf("details.portion must be one of %v", portions)
		}
		if err := maxLen("details.menu", d.Menu, 100); err != nil {
			return nil, err
		}
		return json.Marshal(d)

	case repository.ActivityTypeSleep:
		var d Sleep
		if err := decodeStrict(raw, &d); err != nil {
			return nil, err
		}
		return json.Marshal(d)

	case repository.ActivityTypeToilet:
		var d Toilet
		if err := decodeStrict(raw, &d); err != nil {
			return nil, err
		}
		if !slices.Contains(toiletKinds, d.Kind) {
			return nil, fmt.Errorf("details.kind must be one of %v", toiletKinds)
		}
		return json.Marshal(d)

	case repository.ActivityTypePlay:
		var d Play
		if err := decodeStrict(raw, &d); err != nil {
			return nil, err
		}
		if err := maxLen("details.activity", d.Activity, 100); err != nil {
			return nil, err
		}
		return json.Marshal(d)

	case repository.ActivityTypeMedical:
		var d Medical
		if err := decodeStrict(raw, &d); err != nil {
			return nil, err
		}
		if !slices.Contains(medicalKinds, d.Kind) {
			return nil, fmt.Errorf("details.kind must be one of %v", medicalKinds)
		}
		if d.Kind == "temperature" && (d.TemperatureC == nil || *d.TemperatureC < 34 || *d.TemperatureC > 43) {
			return nil, errors.New("details.temperature_c (34-43) is required for kind temperature")
		}
		if d.Kind == "medicine" && d.Medicine == "" {
			return nil, errors.New("details.medicine is required for kind medicine")
		}
		if err := maxLen("details.medicine", d.Medicine, 100); err != nil {
			return nil, err
		}
		return json.Marshal(d)
	}
	return nil, fmt.Errorf("unknown activity type %q", t)
}

func decodeStrict(raw json.RawMessage, v any) error {
	dec := json.NewDecoder(bytes.NewReader(raw))
	dec.DisallowUnknownFields()
	if err := dec.Decode(v); err != nil {
		return fmt.Errorf("invalid details: %w", err)
	}
	return nil
}

func maxLen(field, s string, n int) error {
	if utf8.RuneCountInString(s) > n {
		return fmt.Errorf("%s must be at most %d characters", field, n)
	}
	return nil
}
