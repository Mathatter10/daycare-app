package handlers

import (
	"context"
	"errors"
	"fmt"

	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
	"github.com/Mathatter10/daycare-app/backend-go/internal/views"
)

// Classes lists all classes.
// GET /admin/classes
func (h *AdminHandler) Classes(c fiber.Ctx) error {
	rows, err := h.Q.ListClasses(c.Context(), uuid.NullUUID{})
	if err != nil {
		return err
	}
	return views.Render(c, views.ClassesPage(h.page(c, "Kelas", "classes"), rows))
}

// NewClass renders the empty class form.
// GET /admin/classes/new
func (h *AdminHandler) NewClass(c fiber.Ctx) error {
	caregivers, err := h.activeCaregivers(c.Context())
	if err != nil {
		return err
	}
	return views.Render(c, views.ClassFormModal(views.ClassForm{CaregiverIDs: map[string]bool{}}, caregivers))
}

// EditClass renders the form for an existing class.
// GET /admin/classes/:id/edit
func (h *AdminHandler) EditClass(c fiber.Ctx) error {
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	class, err := h.Q.GetClass(c.Context(), id)
	if errors.Is(err, pgx.ErrNoRows) {
		return fiber.ErrNotFound
	}
	if err != nil {
		return err
	}
	assigned, err := h.Q.ListClassCaregiverIDs(c.Context(), id)
	if err != nil {
		return err
	}
	caregivers, err := h.activeCaregivers(c.Context())
	if err != nil {
		return err
	}

	f := views.ClassForm{
		ID:           id.String(),
		Name:         class.Name,
		Description:  pgText(class.Description),
		CaregiverIDs: map[string]bool{},
	}
	for _, cid := range assigned {
		f.CaregiverIDs[cid.String()] = true
	}
	return views.Render(c, views.ClassFormModal(f, caregivers))
}

// CreateClass inserts a class and its caregiver assignments.
// POST /admin/classes
func (h *AdminHandler) CreateClass(c fiber.Ctx) error {
	return h.saveClass(c, uuid.Nil)
}

// UpdateClass updates a class and replaces its caregiver assignments.
// POST /admin/classes/:id
func (h *AdminHandler) UpdateClass(c fiber.Ctx) error {
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	return h.saveClass(c, id)
}

func (h *AdminHandler) saveClass(c fiber.Ctx, id uuid.UUID) error {
	ctx := c.Context()
	caregivers, err := h.activeCaregivers(ctx)
	if err != nil {
		return err
	}

	f := views.ClassForm{
		Name:         form(c, "name"),
		Description:  form(c, "description"),
		CaregiverIDs: map[string]bool{},
	}
	if id != uuid.Nil {
		f.ID = id.String()
	}

	v := newValidator()
	v.required("name", f.Name, "Nama kelas wajib diisi.")
	v.maxLen("name", f.Name, 100)
	v.maxLen("description", f.Description, 500)

	// Only active caregivers may be assigned; unknown IDs are rejected.
	active := make(map[string]bool, len(caregivers))
	for _, cg := range caregivers {
		active[cg.ID.String()] = true
	}
	var caregiverIDs []uuid.UUID
	for _, raw := range formMulti(c, "caregiver_ids") {
		if !active[raw] {
			v.add("caregiver_ids", "Pengasuh yang dipilih tidak valid. Muat ulang halaman.")
			continue
		}
		f.CaregiverIDs[raw] = true
		caregiverIDs = append(caregiverIDs, uuid.MustParse(raw))
	}

	if v.ok() {
		var saveErr error
		id, saveErr = h.writeClass(ctx, id, f, caregiverIDs)
		switch {
		case isUniqueViolation(saveErr, "classes_name_key"):
			v.add("name", "Nama kelas sudah dipakai.")
		case saveErr != nil:
			return saveErr
		}
	}
	if !v.ok() {
		f.Errors = v.errs
		return renderInvalid(c, views.ClassFormModal(f, caregivers))
	}

	rows, err := h.Q.ListClasses(ctx, uuid.NullUUID{UUID: id, Valid: true})
	if err != nil {
		return err
	}
	if len(rows) == 0 {
		return fiber.ErrNotFound
	}
	if f.ID == "" {
		return views.Render(c, views.OOBInsert("class-rows", views.ClassRow(rows[0], false)))
	}
	return views.Render(c, views.OOBReplace(views.ClassRow(rows[0], true)))
}

// writeClass creates (id == uuid.Nil) or updates a class and sets its
// caregivers in one transaction. It returns the class ID.
func (h *AdminHandler) writeClass(ctx context.Context, id uuid.UUID, f views.ClassForm, caregiverIDs []uuid.UUID) (uuid.UUID, error) {
	tx, err := h.DB.Begin(ctx)
	if err != nil {
		return uuid.Nil, fmt.Errorf("begin tx: %w", err)
	}
	defer tx.Rollback(ctx)
	q := h.Q.WithTx(tx)

	if id == uuid.Nil {
		id, err = q.CreateClass(ctx, repository.CreateClassParams{
			Name:        f.Name,
			Description: textOrNull(f.Description),
		})
		if err != nil {
			return uuid.Nil, err
		}
	} else {
		n, err := q.UpdateClass(ctx, repository.UpdateClassParams{
			ID:          id,
			Name:        f.Name,
			Description: textOrNull(f.Description),
		})
		if err != nil {
			return uuid.Nil, err
		}
		if n == 0 {
			return uuid.Nil, fiber.ErrNotFound
		}
		if err := q.ClearClassCaregivers(ctx, id); err != nil {
			return uuid.Nil, err
		}
	}

	for _, cid := range caregiverIDs {
		if err := q.AssignCaregiverToClass(ctx, repository.AssignCaregiverToClassParams{
			ClassID:     id,
			CaregiverID: cid,
		}); err != nil {
			return uuid.Nil, err
		}
	}
	return id, tx.Commit(ctx)
}

// DeleteClass removes a class. Its children become unassigned (FK SET NULL)
// and caregiver assignments are dropped (FK CASCADE).
// DELETE /admin/classes/:id
func (h *AdminHandler) DeleteClass(c fiber.Ctx) error {
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	n, err := h.Q.DeleteClass(c.Context(), id)
	if err != nil {
		return err
	}
	if n == 0 {
		return fiber.ErrNotFound
	}
	// Empty 200 body: hx-swap="outerHTML" removes the row.
	return c.SendString("")
}

func (h *AdminHandler) activeCaregivers(ctx context.Context) ([]repository.ListUserOptionsRow, error) {
	return h.Q.ListUserOptions(ctx, repository.UserRoleCaregiver)
}
