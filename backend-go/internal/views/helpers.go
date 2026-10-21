package views

import (
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgtype"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

// Page carries what every admin page needs for the shell.
type Page struct {
	Title     string
	Nav       string // dashboard | children | classes | caregivers | parents | deleted
	AdminName string
}

// FormErrors maps a form field name to its validation message.
type FormErrors map[string]string

type Option struct {
	Value string
	Label string
}

// RoleInfo describes one of the two user-management pages, which share
// handlers and templates.
type RoleInfo struct {
	Role     repository.UserRole
	Path     string // URL segment: caregivers | parents
	Title    string // page title (plural)
	Singular string
	Related  string // column header for linked classes / children
}

var (
	CaregiverRole = RoleInfo{repository.UserRoleCaregiver, "caregivers", "Pengasuh", "pengasuh", "Kelas"}
	ParentRole    = RoleInfo{repository.UserRoleParent, "parents", "Orang Tua", "orang tua", "Anak"}
)

func (r RoleInfo) URL(suffix string) string { return "/admin/" + r.Path + suffix }

func text(t pgtype.Text) string {
	if !t.Valid {
		return ""
	}
	return t.String
}

// ageLabel formats an age like "2 th 3 bln" or "8 bln".
func ageLabel(dob time.Time) string {
	now := time.Now()
	months := (now.Year()-dob.Year())*12 + int(now.Month()) - int(dob.Month())
	if now.Day() < dob.Day() {
		months--
	}
	if months < 0 {
		months = 0
	}
	if months < 12 {
		return fmt.Sprintf("%d bln", months)
	}
	if months%12 == 0 {
		return fmt.Sprintf("%d th", months/12)
	}
	return fmt.Sprintf("%d th %d bln", months/12, months%12)
}

var monthShort = [...]string{"Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"}

// DateTimeLabel formats like "20 Okt 2026 14:31".
func DateTimeLabel(t time.Time) string {
	return fmt.Sprintf("%d %s %d %s", t.Day(), monthShort[t.Month()-1], t.Year(), t.Format("15:04"))
}

func genderLabel(g pgtype.Text) string {
	switch text(g) {
	case "male":
		return "Laki-laki"
	case "female":
		return "Perempuan"
	}
	return ""
}
