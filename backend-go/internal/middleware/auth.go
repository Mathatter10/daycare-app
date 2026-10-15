// Package middleware holds authentication and authorization middleware for
// the mobile JSON API (JWT) and the admin web (cookie session).
package middleware

import (
	"errors"
	"slices"
	"strings"

	"github.com/gofiber/fiber/v3"

	"github.com/Mathatter10/daycare-app/backend-go/internal/auth"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

const (
	SessionCookie = "daycare_session"
	userLocalKey  = "auth.user"
)

// CurrentUser returns the user set by RequireJWT or RequireAdminSession.
func CurrentUser(c fiber.Ctx) repository.User {
	user, _ := c.Locals(userLocalKey).(repository.User)
	return user
}

// RequireJWT authenticates a mobile API request from the Bearer token. The
// user is reloaded from the database so a deactivated account loses access
// immediately rather than when the token expires.
func RequireJWT(svc *auth.Service) fiber.Handler {
	return func(c fiber.Ctx) error {
		header := c.Get(fiber.HeaderAuthorization)
		token, ok := strings.CutPrefix(header, "Bearer ")
		if !ok || token == "" {
			return fiber.NewError(fiber.StatusUnauthorized, "missing bearer token")
		}
		userID, err := svc.JWT().Parse(token)
		if err != nil {
			return fiber.NewError(fiber.StatusUnauthorized, "invalid or expired token")
		}
		user, err := svc.ActiveUser(c.Context(), userID)
		if errors.Is(err, auth.ErrInvalidToken) || errors.Is(err, auth.ErrInactiveUser) {
			return fiber.NewError(fiber.StatusUnauthorized, "invalid or expired token")
		}
		if err != nil {
			return err
		}
		c.Locals(userLocalKey, user)
		return c.Next()
	}
}

// RequireRole allows the request only if the authenticated user has one of
// the given roles. It must run after RequireJWT or RequireAdminSession.
func RequireRole(roles ...repository.UserRole) fiber.Handler {
	return func(c fiber.Ctx) error {
		if !slices.Contains(roles, CurrentUser(c).Role) {
			return fiber.NewError(fiber.StatusForbidden, "forbidden")
		}
		return c.Next()
	}
}

// RequireAdminSession authenticates an admin web request from the session
// cookie. Unauthenticated users are sent to the login page; HTMX requests
// get an HX-Redirect header so the whole page navigates, not just a target.
func RequireAdminSession(svc *auth.Service) fiber.Handler {
	return func(c fiber.Ctx) error {
		raw := c.Cookies(SessionCookie)
		if raw != "" {
			user, err := svc.SessionUser(c.Context(), raw)
			if err == nil && user.Role == repository.UserRoleAdmin {
				c.Locals(userLocalKey, user)
				return c.Next()
			}
			if err != nil && !errors.Is(err, auth.ErrInvalidToken) {
				return err
			}
		}
		if c.Get("HX-Request") == "true" {
			c.Set("HX-Redirect", "/admin/login")
			return c.SendStatus(fiber.StatusUnauthorized)
		}
		return c.Redirect().Status(fiber.StatusSeeOther).To("/admin/login")
	}
}
