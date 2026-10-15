package handlers

import (
	"context"
	"errors"
	"strings"

	"github.com/a-h/templ"
	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"

	"github.com/Mathatter10/daycare-app/backend-go/internal/auth"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
	"github.com/Mathatter10/daycare-app/backend-go/internal/views"
)

// The user handlers serve both /admin/caregivers and /admin/parents; ri
// selects the role. Every query also filters by role, so these pages can
// never read or modify an admin account or an account of the other role.

// Users lists caregivers or parents, optionally filtered by ?q=.
// GET /admin/{caregivers|parents}
func (h *AdminHandler) Users(ri views.RoleInfo) fiber.Handler {
	return func(c fiber.Ctx) error {
		search := strings.TrimSpace(c.Query("q"))
		rows, err := h.Q.ListUsers(c.Context(), repository.ListUsersParams{Role: ri.Role, Search: search})
		if err != nil {
			return err
		}
		if isRowsRequest(c, "user-rows") {
			return views.Render(c, views.UserRows(ri, rows))
		}
		return views.Render(c, views.UsersPage(h.page(c, ri.Title, ri.Path), ri, rows, search))
	}
}

// NewUser renders the empty form.
// GET /admin/{role}/new
func (h *AdminHandler) NewUser(ri views.RoleInfo) fiber.Handler {
	return func(c fiber.Ctx) error {
		return views.Render(c, views.UserFormModal(ri, views.UserForm{}))
	}
}

// EditUser renders the form for an existing account.
// GET /admin/{role}/:id/edit
func (h *AdminHandler) EditUser(ri views.RoleInfo) fiber.Handler {
	return func(c fiber.Ctx) error {
		row, err := h.userRow(c, ri)
		if err != nil {
			return err
		}
		return views.Render(c, views.UserFormModal(ri, views.UserForm{
			ID:       row.ID.String(),
			FullName: row.FullName,
			Email:    row.Email,
			Phone:    pgText(row.Phone),
		}))
	}
}

// CreateUser creates the account with a generated temporary password and
// shows that password once.
// POST /admin/{role}
func (h *AdminHandler) CreateUser(ri views.RoleInfo) fiber.Handler {
	return func(c fiber.Ctx) error {
		f, v := parseUserForm(c)
		if !v.ok() {
			f.Errors = v.errs
			return renderInvalid(c, views.UserFormModal(ri, f))
		}

		password, err := auth.GenerateTempPassword()
		if err != nil {
			return err
		}
		hash, err := auth.HashPassword(password)
		if err != nil {
			return err
		}
		user, err := h.Q.CreateUser(c.Context(), repository.CreateUserParams{
			Email:        f.Email,
			PasswordHash: hash,
			FullName:     f.FullName,
			Phone:        textOrNull(f.Phone),
			Role:         ri.Role,
		})
		if isUniqueViolation(err, "users_email_lower_key") {
			f.Errors = views.FormErrors{"email": "Email ini sudah terdaftar."}
			return renderInvalid(c, views.UserFormModal(ri, f))
		}
		if err != nil {
			return err
		}

		rows, err := h.Q.ListUsers(c.Context(), repository.ListUsersParams{
			Role: ri.Role, ID: uuid.NullUUID{UUID: user.ID, Valid: true},
		})
		if err != nil || len(rows) == 0 {
			return errors.Join(err, fiber.ErrNotFound)
		}
		return views.Render(c, templ.Join(
			views.CredentialsModal("Akun "+ri.Singular+" dibuat", user.FullName, user.Email, password),
			views.OOBInsert("user-rows", views.UserRow(ri, rows[0], false)),
		))
	}
}

// UpdateUser updates name, email and phone.
// POST /admin/{role}/:id
func (h *AdminHandler) UpdateUser(ri views.RoleInfo) fiber.Handler {
	return func(c fiber.Ctx) error {
		id, err := paramUUID(c)
		if err != nil {
			return err
		}
		f, v := parseUserForm(c)
		f.ID = id.String()
		if !v.ok() {
			f.Errors = v.errs
			return renderInvalid(c, views.UserFormModal(ri, f))
		}

		n, err := h.Q.UpdateUserProfile(c.Context(), repository.UpdateUserProfileParams{
			ID:       id,
			Email:    f.Email,
			FullName: f.FullName,
			Phone:    textOrNull(f.Phone),
			Role:     ri.Role,
		})
		if isUniqueViolation(err, "users_email_lower_key") {
			f.Errors = views.FormErrors{"email": "Email ini sudah terdaftar."}
			return renderInvalid(c, views.UserFormModal(ri, f))
		}
		if err != nil {
			return err
		}
		if n == 0 {
			return fiber.ErrNotFound
		}

		row, err := h.userRow(c, ri)
		if err != nil {
			return err
		}
		return views.Render(c, views.OOBReplace(views.UserRow(ri, row, true)))
	}
}

// SetUserActive activates or deactivates an account. Deactivation signs
// the user out everywhere at once.
// POST /admin/{role}/:id/active   (form: active=true|false)
func (h *AdminHandler) SetUserActive(ri views.RoleInfo) fiber.Handler {
	return func(c fiber.Ctx) error {
		id, err := paramUUID(c)
		if err != nil {
			return err
		}
		active := c.FormValue("active") == "true"
		n, err := h.Q.SetUserActive(c.Context(), repository.SetUserActiveParams{ID: id, IsActive: active, Role: ri.Role})
		if err != nil {
			return err
		}
		if n == 0 {
			return fiber.ErrNotFound
		}
		if !active {
			if err := h.signOutEverywhere(c.Context(), id); err != nil {
				return err
			}
		}

		row, err := h.userRow(c, ri)
		if err != nil {
			return err
		}
		return views.Render(c, views.UserRow(ri, row, false))
	}
}

// ResetUserPassword sets a new temporary password, signs the user out and
// shows the password once.
// POST /admin/{role}/:id/password
func (h *AdminHandler) ResetUserPassword(ri views.RoleInfo) fiber.Handler {
	return func(c fiber.Ctx) error {
		row, err := h.userRow(c, ri)
		if err != nil {
			return err
		}
		password, err := auth.GenerateTempPassword()
		if err != nil {
			return err
		}
		hash, err := auth.HashPassword(password)
		if err != nil {
			return err
		}
		n, err := h.Q.SetUserPassword(c.Context(), repository.SetUserPasswordParams{ID: row.ID, PasswordHash: hash, Role: ri.Role})
		if err != nil {
			return err
		}
		if n == 0 {
			return fiber.ErrNotFound
		}
		if err := h.signOutEverywhere(c.Context(), row.ID); err != nil {
			return err
		}
		return views.Render(c, views.CredentialsModal("Kata sandi baru", row.FullName, row.Email, password))
	}
}

// userRow loads the :id account in table-row shape, restricted to ri.Role.
func (h *AdminHandler) userRow(c fiber.Ctx, ri views.RoleInfo) (repository.ListUsersRow, error) {
	id, err := paramUUID(c)
	if err != nil {
		return repository.ListUsersRow{}, err
	}
	rows, err := h.Q.ListUsers(c.Context(), repository.ListUsersParams{
		Role: ri.Role, ID: uuid.NullUUID{UUID: id, Valid: true},
	})
	if err != nil {
		return repository.ListUsersRow{}, err
	}
	if len(rows) == 0 {
		return repository.ListUsersRow{}, fiber.ErrNotFound
	}
	return rows[0], nil
}

func (h *AdminHandler) signOutEverywhere(ctx context.Context, userID uuid.UUID) error {
	return errors.Join(
		h.Q.RevokeAllRefreshTokensForUser(ctx, userID),
		h.Q.DeleteWebSessionsForUser(ctx, userID),
		h.Q.DeleteDeviceTokensForUser(ctx, userID),
	)
}

func parseUserForm(c fiber.Ctx) (views.UserForm, *validator) {
	f := views.UserForm{
		FullName: form(c, "full_name"),
		Email:    strings.ToLower(form(c, "email")),
		Phone:    form(c, "phone"),
	}
	v := newValidator()
	v.required("full_name", f.FullName, "Nama wajib diisi.")
	v.maxLen("full_name", f.FullName, 100)
	v.email("email", f.Email)
	v.maxLen("email", f.Email, 254)
	v.maxLen("phone", f.Phone, 30)
	return f, v
}
