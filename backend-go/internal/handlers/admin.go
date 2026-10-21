package handlers

import (
	"time"

	"github.com/a-h/templ"
	"github.com/gofiber/fiber/v3"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
	"github.com/Mathatter10/daycare-app/backend-go/internal/views"
)

// AdminHandler serves the admin master-data pages (templ + HTMX). Every
// route using it must sit behind middleware.RequireAdminSession.
//
// Response conventions:
//   - direct page load      -> full page (AdminLayout)
//   - HTMX list filter      -> table rows only
//   - form GET              -> modal partial into #modal
//   - form POST invalid     -> modal partial with errors, status 422
//   - form POST success     -> empty #modal (closes it) + out-of-band row swap
type AdminHandler struct {
	DB       *pgxpool.Pool
	Q        *repository.Queries
	Location *time.Location // daycare time zone for displayed times
}

func NewAdminHandler(pool *pgxpool.Pool, loc *time.Location) *AdminHandler {
	return &AdminHandler{DB: pool, Q: repository.New(pool), Location: loc}
}

func (h *AdminHandler) page(c fiber.Ctx, title, nav string) views.Page {
	return views.Page{Title: title, Nav: nav, AdminName: middleware.CurrentUser(c).FullName}
}

// Dashboard shows summary counts.
// GET /admin
func (h *AdminHandler) Dashboard(c fiber.Ctx) error {
	counts, err := h.Q.DashboardCounts(c.Context())
	if err != nil {
		return err
	}
	return views.Render(c, views.DashboardPage(h.page(c, "Dashboard", "dashboard"), counts))
}

// renderInvalid answers a failed form submission. 422 keeps the login rate
// limiter semantics consistent and is swapped by HTMX per Layout's config.
func renderInvalid(c fiber.Ctx, component templ.Component) error {
	c.Status(fiber.StatusUnprocessableEntity)
	return views.Render(c, component)
}

// isRowsRequest reports whether an HTMX request only wants the tbody rows
// (search / filter), identified by the target element id.
func isRowsRequest(c fiber.Ctx, bodyID string) bool {
	return views.IsHTMX(c) && c.Get("HX-Target") == bodyID
}
