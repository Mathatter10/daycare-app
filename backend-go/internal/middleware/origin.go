package middleware

import (
	"net/url"

	"github.com/gofiber/fiber/v3"
)

// SameOrigin blocks cross-site state-changing requests to the admin web
// (CSRF defence, on top of the SameSite=Lax session cookie). Modern browsers
// always send Origin or Sec-Fetch-Site on POST; non-browser clients that
// send neither are not a CSRF vector and are allowed through.
func SameOrigin() fiber.Handler {
	return func(c fiber.Ctx) error {
		switch c.Method() {
		case fiber.MethodGet, fiber.MethodHead, fiber.MethodOptions:
			return c.Next()
		}

		if site := c.Get("Sec-Fetch-Site"); site == "cross-site" || site == "same-site" {
			return fiber.NewError(fiber.StatusForbidden, "cross-origin request blocked")
		}
		if origin := c.Get(fiber.HeaderOrigin); origin != "" {
			u, err := url.Parse(origin)
			if err != nil || u.Host != c.Host() {
				return fiber.NewError(fiber.StatusForbidden, "cross-origin request blocked")
			}
		}
		return c.Next()
	}
}
