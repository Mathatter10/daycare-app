package handlers

import (
	"errors"
	"net/mail"
	"strconv"
	"strings"
	"unicode/utf8"

	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/Mathatter10/daycare-app/backend-go/internal/views"
)

// form returns a trimmed form value.
func form(c fiber.Ctx, name string) string {
	return strings.TrimSpace(c.FormValue(name))
}

// formMulti returns every value of a repeated form field (e.g. checkboxes).
func formMulti(c fiber.Ctx, name string) []string {
	var out []string
	for _, v := range c.RequestCtx().PostArgs().PeekMulti(name) {
		out = append(out, string(v))
	}
	return out
}

func textOrNull(s string) pgtype.Text {
	return pgtype.Text{String: s, Valid: s != ""}
}

func pgText(t pgtype.Text) string {
	if !t.Valid {
		return ""
	}
	return t.String
}

// paramUUID parses the :id route parameter, answering 404 when malformed.
func paramUUID(c fiber.Ctx) (uuid.UUID, error) {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return uuid.Nil, fiber.ErrNotFound
	}
	return id, nil
}

func isUniqueViolation(err error, constraint string) bool {
	var pgErr *pgconn.PgError
	return errors.As(err, &pgErr) && pgErr.Code == "23505" && pgErr.ConstraintName == constraint
}

// validator collects per-field validation errors.
type validator struct {
	errs views.FormErrors
}

func newValidator() *validator { return &validator{errs: views.FormErrors{}} }

func (v *validator) ok() bool { return len(v.errs) == 0 }

func (v *validator) add(field, msg string) {
	if _, exists := v.errs[field]; !exists {
		v.errs[field] = msg
	}
}

func (v *validator) required(field, value, msg string) {
	if value == "" {
		v.add(field, msg)
	}
}

func (v *validator) maxLen(field, value string, n int) {
	if utf8.RuneCountInString(value) > n {
		v.add(field, "Maksimal "+strconv.Itoa(n)+" karakter.")
	}
}

func (v *validator) email(field, value string) {
	if value == "" {
		v.add(field, "Email wajib diisi.")
		return
	}
	addr, err := mail.ParseAddress(value)
	if err != nil || addr.Address != value || !strings.Contains(value, ".") {
		v.add(field, "Format email tidak valid.")
	}
}
