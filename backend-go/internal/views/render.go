// Package views holds templ components for the HTMX admin web.
// Run `go tool templ generate` after editing any .templ file.
package views

import (
	"github.com/a-h/templ"
	"github.com/gofiber/fiber/v3"
)

// Render writes a templ component as the HTML response. Handlers render a
// full page (Layout-wrapped) on direct loads and a bare partial when the
// request comes from HTMX (see IsHTMX).
func Render(c fiber.Ctx, component templ.Component) error {
	c.Set(fiber.HeaderContentType, fiber.MIMETextHTMLCharsetUTF8)
	return component.Render(c.Context(), c.Response().BodyWriter())
}

// IsHTMX reports whether the request was issued by HTMX.
func IsHTMX(c fiber.Ctx) bool {
	return c.Get("HX-Request") == "true"
}
