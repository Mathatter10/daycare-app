package handlers

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
	"github.com/Mathatter10/daycare-app/backend-go/internal/views"
)

const dateLayout = "2006-01-02"

// Children lists children with search, class and inactive filters.
// GET /admin/children?q=&class_id=&inactive=1
func (h *AdminHandler) Children(c fiber.Ctx) error {
	filter := views.ChildFilter{
		Search:          strings.TrimSpace(c.Query("q")),
		IncludeInactive: c.Query("inactive") == "1",
	}
	params := repository.ListChildrenParams{Search: filter.Search, IncludeInactive: filter.IncludeInactive}
	if classID, err := uuid.Parse(c.Query("class_id")); err == nil {
		filter.ClassID = classID.String()
		params.ClassID = uuid.NullUUID{UUID: classID, Valid: true}
	}

	rows, err := h.Q.ListChildren(c.Context(), params)
	if err != nil {
		return err
	}
	if isRowsRequest(c, "child-rows") {
		return views.Render(c, views.ChildRows(rows))
	}
	classes, err := h.classOptions(c.Context())
	if err != nil {
		return err
	}
	return views.Render(c, views.ChildrenPage(h.page(c, "Anak", "children"), rows, filter, classes))
}

// NewChild renders the empty child form.
// GET /admin/children/new
func (h *AdminHandler) NewChild(c fiber.Ctx) error {
	return h.renderChildForm(c, views.ChildForm{}, false)
}

// EditChild renders the form for an existing child.
// GET /admin/children/:id/edit
func (h *AdminHandler) EditChild(c fiber.Ctx) error {
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	child, err := h.Q.GetChildForEdit(c.Context(), id)
	if errors.Is(err, pgx.ErrNoRows) {
		return fiber.ErrNotFound
	}
	if err != nil {
		return err
	}
	f := views.ChildForm{
		ID:               id.String(),
		FullName:         child.FullName,
		Nickname:         pgText(child.Nickname),
		DateOfBirth:      child.DateOfBirth.Format(dateLayout),
		Gender:           pgText(child.Gender),
		ParentEmail:      child.ParentEmail,
		Allergies:        pgText(child.Allergies),
		MedicalNotes:     pgText(child.MedicalNotes),
		EmergencyContact: pgText(child.EmergencyContact),
	}
	if child.ClassID.Valid {
		f.ClassID = child.ClassID.UUID.String()
	}
	return h.renderChildForm(c, f, false)
}

// CreateChild adds a child linked to an existing parent account.
// POST /admin/children
func (h *AdminHandler) CreateChild(c fiber.Ctx) error {
	return h.saveChild(c, uuid.Nil)
}

// UpdateChild updates a child's profile.
// POST /admin/children/:id
func (h *AdminHandler) UpdateChild(c fiber.Ctx) error {
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	return h.saveChild(c, id)
}

func (h *AdminHandler) saveChild(c fiber.Ctx, id uuid.UUID) error {
	ctx := c.Context()
	f := views.ChildForm{
		FullName:         form(c, "full_name"),
		Nickname:         form(c, "nickname"),
		DateOfBirth:      form(c, "date_of_birth"),
		Gender:           form(c, "gender"),
		ClassID:          form(c, "class_id"),
		ParentEmail:      strings.ToLower(form(c, "parent_email")),
		Allergies:        form(c, "allergies"),
		MedicalNotes:     form(c, "medical_notes"),
		EmergencyContact: form(c, "emergency_contact"),
	}
	if id != uuid.Nil {
		f.ID = id.String()
	}

	v := newValidator()
	v.required("full_name", f.FullName, "Nama wajib diisi.")
	v.maxLen("full_name", f.FullName, 100)
	v.maxLen("nickname", f.Nickname, 50)
	v.maxLen("allergies", f.Allergies, 500)
	v.maxLen("medical_notes", f.MedicalNotes, 1000)
	v.maxLen("emergency_contact", f.EmergencyContact, 200)

	dob, err := time.Parse(dateLayout, f.DateOfBirth)
	switch {
	case f.DateOfBirth == "":
		v.add("date_of_birth", "Tanggal lahir wajib diisi.")
	case err != nil:
		v.add("date_of_birth", "Format tanggal tidak valid.")
	case dob.After(time.Now()):
		v.add("date_of_birth", "Tanggal lahir tidak boleh di masa depan.")
	case dob.Before(time.Now().AddDate(-10, 0, 0)):
		v.add("date_of_birth", "Umur anak lebih dari 10 tahun. Periksa kembali.")
	}

	if f.Gender != "" && f.Gender != "male" && f.Gender != "female" {
		v.add("gender", "Pilihan tidak valid.")
	}

	classID := uuid.NullUUID{}
	if f.ClassID != "" {
		parsed, err := uuid.Parse(f.ClassID)
		if err != nil {
			v.add("class_id", "Kelas tidak valid.")
		} else if _, err := h.Q.GetClass(ctx, parsed); errors.Is(err, pgx.ErrNoRows) {
			v.add("class_id", "Kelas tidak ditemukan. Muat ulang halaman.")
		} else if err != nil {
			return err
		} else {
			classID = uuid.NullUUID{UUID: parsed, Valid: true}
		}
	}

	var parentID uuid.UUID
	if f.ParentEmail == "" {
		v.add("parent_email", "Email orang tua wajib diisi.")
	} else {
		parent, err := h.Q.GetUserByEmail(ctx, f.ParentEmail)
		switch {
		case errors.Is(err, pgx.ErrNoRows) || (err == nil && parent.Role != repository.UserRoleParent):
			v.add("parent_email", "Akun orang tua dengan email ini tidak ditemukan. Buat dulu di menu Orang Tua.")
		case err != nil:
			return err
		case !parent.IsActive:
			v.add("parent_email", "Akun orang tua ini nonaktif. Aktifkan dulu di menu Orang Tua.")
		default:
			parentID = parent.ID
		}
	}

	if !v.ok() {
		f.Errors = v.errs
		return h.renderChildForm(c, f, true)
	}

	isNew := id == uuid.Nil
	if isNew {
		id, err = h.Q.CreateChild(ctx, repository.CreateChildParams{
			FullName:         f.FullName,
			Nickname:         textOrNull(f.Nickname),
			DateOfBirth:      dob,
			Gender:           textOrNull(f.Gender),
			ClassID:          classID,
			ParentID:         parentID,
			Allergies:        textOrNull(f.Allergies),
			MedicalNotes:     textOrNull(f.MedicalNotes),
			EmergencyContact: textOrNull(f.EmergencyContact),
		})
		if err != nil {
			return err
		}
	} else {
		n, err := h.Q.UpdateChild(ctx, repository.UpdateChildParams{
			ID:               id,
			FullName:         f.FullName,
			Nickname:         textOrNull(f.Nickname),
			DateOfBirth:      dob,
			Gender:           textOrNull(f.Gender),
			ClassID:          classID,
			ParentID:         parentID,
			Allergies:        textOrNull(f.Allergies),
			MedicalNotes:     textOrNull(f.MedicalNotes),
			EmergencyContact: textOrNull(f.EmergencyContact),
		})
		if err != nil {
			return err
		}
		if n == 0 {
			return fiber.ErrNotFound
		}
	}

	row, err := h.childRow(ctx, id)
	if err != nil {
		return err
	}
	if isNew {
		return views.Render(c, views.OOBInsert("child-rows", views.ChildRow(row, false)))
	}
	return views.Render(c, views.OOBReplace(views.ChildRow(row, true)))
}

// SetChildActive activates or deactivates a child. Records are kept so the
// attendance and activity history stays intact.
// POST /admin/children/:id/active   (form: active=true|false)
func (h *AdminHandler) SetChildActive(c fiber.Ctx) error {
	id, err := paramUUID(c)
	if err != nil {
		return err
	}
	n, err := h.Q.SetChildActive(c.Context(), repository.SetChildActiveParams{
		ID:       id,
		IsActive: c.FormValue("active") == "true",
	})
	if err != nil {
		return err
	}
	if n == 0 {
		return fiber.ErrNotFound
	}
	row, err := h.childRow(c.Context(), id)
	if err != nil {
		return err
	}
	return views.Render(c, views.ChildRow(row, false))
}

func (h *AdminHandler) renderChildForm(c fiber.Ctx, f views.ChildForm, invalid bool) error {
	classes, err := h.classOptions(c.Context())
	if err != nil {
		return err
	}
	parents, err := h.Q.ListUserOptions(c.Context(), repository.UserRoleParent)
	if err != nil {
		return err
	}
	modal := views.ChildFormModal(f, classes, parents)
	if invalid {
		return renderInvalid(c, modal)
	}
	return views.Render(c, modal)
}

func (h *AdminHandler) childRow(ctx context.Context, id uuid.UUID) (repository.ListChildrenRow, error) {
	rows, err := h.Q.ListChildren(ctx, repository.ListChildrenParams{
		ID:              uuid.NullUUID{UUID: id, Valid: true},
		IncludeInactive: true,
	})
	if err != nil {
		return repository.ListChildrenRow{}, err
	}
	if len(rows) == 0 {
		return repository.ListChildrenRow{}, fiber.ErrNotFound
	}
	return rows[0], nil
}

func (h *AdminHandler) classOptions(ctx context.Context) ([]views.Option, error) {
	classes, err := h.Q.ListClassOptions(ctx)
	if err != nil {
		return nil, err
	}
	opts := make([]views.Option, len(classes))
	for i, cl := range classes {
		opts[i] = views.Option{Value: cl.ID.String(), Label: cl.Name}
	}
	return opts, nil
}
