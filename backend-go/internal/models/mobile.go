package models

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

const DateLayout = "2006-01-02"

type ChildResponse struct {
	ID           uuid.UUID  `json:"id"`
	FullName     string     `json:"full_name"`
	Nickname     *string    `json:"nickname"`
	DateOfBirth  string     `json:"date_of_birth"`
	Gender       *string    `json:"gender"`
	ClassID      *uuid.UUID `json:"class_id"`
	ClassName    string     `json:"class_name"`
	Allergies    *string    `json:"allergies"`
	MedicalNotes *string    `json:"medical_notes"`
	UpdatedAt    time.Time  `json:"updated_at"`
	Today        TodayState `json:"today"`
}

// TodayState is the child's attendance for the current daycare day.
type TodayState struct {
	CheckInAt  *time.Time `json:"check_in_at"`
	CheckOutAt *time.Time `json:"check_out_at"`
}

func NewChildResponse(r repository.ListAccessibleChildrenRow) ChildResponse {
	resp := ChildResponse{
		ID:           r.ID,
		FullName:     r.FullName,
		Nickname:     textPtr(r.Nickname),
		DateOfBirth:  r.DateOfBirth.Format(DateLayout),
		Gender:       textPtr(r.Gender),
		ClassName:    r.ClassName,
		Allergies:    textPtr(r.Allergies),
		MedicalNotes: textPtr(r.MedicalNotes),
		UpdatedAt:    r.UpdatedAt,
		Today:        TodayState{CheckInAt: r.CheckInAt, CheckOutAt: r.CheckOutAt},
	}
	if r.ClassID.Valid {
		resp.ClassID = &r.ClassID.UUID
	}
	return resp
}

type AttendanceResponse struct {
	ID         uuid.UUID  `json:"id"`
	ChildID    uuid.UUID  `json:"child_id"`
	Date       string     `json:"date"`
	CheckInAt  time.Time  `json:"check_in_at"`
	CheckInBy  uuid.UUID  `json:"check_in_by"`
	CheckOutAt *time.Time `json:"check_out_at"`
	CheckOutBy *uuid.UUID `json:"check_out_by"`
	PickedUpBy *string    `json:"picked_up_by"`
	UpdatedAt  time.Time  `json:"updated_at"`
}

func NewAttendanceResponse(a repository.Attendance) AttendanceResponse {
	resp := AttendanceResponse{
		ID:         a.ID,
		ChildID:    a.ChildID,
		Date:       a.AttendanceDate.Format(DateLayout),
		CheckInAt:  a.CheckInAt,
		CheckInBy:  a.CheckInBy,
		CheckOutAt: a.CheckOutAt,
		PickedUpBy: textPtr(a.PickedUpBy),
		UpdatedAt:  a.UpdatedAt,
	}
	if a.CheckOutBy.Valid {
		resp.CheckOutBy = &a.CheckOutBy.UUID
	}
	return resp
}

type ActivityResponse struct {
	ID            uuid.UUID       `json:"id"`
	ChildID       uuid.UUID       `json:"child_id"`
	CaregiverID   uuid.UUID       `json:"caregiver_id"`
	CaregiverName string          `json:"caregiver_name"`
	Type          string          `json:"type"`
	StartedAt     time.Time       `json:"started_at"`
	EndedAt       *time.Time      `json:"ended_at"`
	Details       json.RawMessage `json:"details"`
	Notes         *string         `json:"notes"`
	CreatedAt     time.Time       `json:"created_at"`
	UpdatedAt     time.Time       `json:"updated_at"`
	DeletedAt     *time.Time      `json:"deleted_at"`
}

// NewActivityResponse takes the GetActivityView row shape; the list and
// sync rows have identical fields and convert to it directly.
func NewActivityResponse(r repository.GetActivityViewRow) ActivityResponse {
	return ActivityResponse{
		ID:            r.ID,
		ChildID:       r.ChildID,
		CaregiverID:   r.CaregiverID,
		CaregiverName: r.CaregiverName,
		Type:          string(r.Type),
		StartedAt:     r.StartedAt,
		EndedAt:       r.EndedAt,
		Details:       json.RawMessage(r.Details),
		Notes:         textPtr(r.Notes),
		CreatedAt:     r.CreatedAt,
		UpdatedAt:     r.UpdatedAt,
		DeletedAt:     r.DeletedAt,
	}
}

func textPtr(t pgtype.Text) *string {
	if !t.Valid {
		return nil
	}
	return &t.String
}
