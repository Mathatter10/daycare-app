package middleware

import (
	"encoding/json"
	"strings"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/limiter"
)

// LoginRateLimit allows 10 failed logins per email per 15 minutes. It keys
// on the email rather than the client IP because the server runs behind a
// proxy (Render) where every request may share the same remote address.
func LoginRateLimit() fiber.Handler {
	return limiter.New(limiter.Config{
		Max:                    10,
		Expiration:             15 * time.Minute,
		SkipSuccessfulRequests: true,
		KeyGenerator:           loginEmailKey,
		LimitReached: func(c fiber.Ctx) error {
			return fiber.NewError(fiber.StatusTooManyRequests, "too many login attempts, try again later")
		},
	})
}

func loginEmailKey(c fiber.Ctx) string {
	email := c.FormValue("email")
	if email == "" {
		var body struct {
			Email string `json:"email"`
		}
		_ = json.Unmarshal(c.Body(), &body)
		email = body.Email
	}
	return "login:" + strings.ToLower(strings.TrimSpace(email))
}
