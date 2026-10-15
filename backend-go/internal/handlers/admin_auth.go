package handlers

import (
	"errors"
	"strings"
	"time"

	"github.com/gofiber/fiber/v3"

	"github.com/Mathatter10/daycare-app/backend-go/internal/auth"
	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
	"github.com/Mathatter10/daycare-app/backend-go/internal/views"
)

const msgInvalidLogin = "Email atau kata sandi salah."

// AdminAuthHandler serves the admin web login and logout.
type AdminAuthHandler struct {
	Auth         *auth.Service
	CookieSecure bool
}

// LoginPage renders the login form, or sends a logged-in admin straight to
// the dashboard.
// GET /admin/login
func (h *AdminAuthHandler) LoginPage(c fiber.Ctx) error {
	if raw := c.Cookies(middleware.SessionCookie); raw != "" {
		if user, err := h.Auth.SessionUser(c.Context(), raw); err == nil && user.Role == repository.UserRoleAdmin {
			return c.Redirect().Status(fiber.StatusSeeOther).To("/admin")
		}
	}
	return views.Render(c, views.LoginPage("", ""))
}

// Login handles the form post. HTMX requests get an error partial or an
// HX-Redirect; plain form posts (no JS) get a full page or a 303 redirect.
// POST /admin/login
func (h *AdminAuthHandler) Login(c fiber.Ctx) error {
	email := strings.TrimSpace(c.FormValue("email"))
	password := c.FormValue("password")

	user, err := h.Auth.Authenticate(c.Context(), email, password)
	if err != nil && !errors.Is(err, auth.ErrInvalidCredentials) {
		return err
	}
	if err != nil || user.Role != repository.UserRoleAdmin {
		// 422 (not 2xx) so the login rate limiter counts the failure;
		// Layout configures HTMX to still swap 422 responses.
		c.Status(fiber.StatusUnprocessableEntity)
		if views.IsHTMX(c) {
			return views.Render(c, views.LoginError(msgInvalidLogin))
		}
		return views.Render(c, views.LoginPage(email, msgInvalidLogin))
	}

	raw, exp, err := h.Auth.CreateSession(c.Context(), user.ID)
	if err != nil {
		return err
	}
	h.setSessionCookie(c, raw, exp)

	if views.IsHTMX(c) {
		c.Set("HX-Redirect", "/admin")
		return c.SendStatus(fiber.StatusNoContent)
	}
	return c.Redirect().Status(fiber.StatusSeeOther).To("/admin")
}

// Logout deletes the session and clears the cookie.
// POST /admin/logout
func (h *AdminAuthHandler) Logout(c fiber.Ctx) error {
	if raw := c.Cookies(middleware.SessionCookie); raw != "" {
		if err := h.Auth.DeleteSession(c.Context(), raw); err != nil {
			return err
		}
	}
	h.setSessionCookie(c, "", time.Unix(0, 0))

	if views.IsHTMX(c) {
		c.Set("HX-Redirect", "/admin/login")
		return c.SendStatus(fiber.StatusNoContent)
	}
	return c.Redirect().Status(fiber.StatusSeeOther).To("/admin/login")
}

func (h *AdminAuthHandler) setSessionCookie(c fiber.Ctx, value string, expires time.Time) {
	c.Cookie(&fiber.Cookie{
		Name:     middleware.SessionCookie,
		Value:    value,
		Path:     "/",
		Expires:  expires,
		HTTPOnly: true,
		Secure:   h.CookieSecure,
		SameSite: fiber.CookieSameSiteLaxMode,
	})
}
