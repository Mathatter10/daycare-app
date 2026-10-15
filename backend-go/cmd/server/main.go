package main

import (
	"context"
	"errors"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/recover"
	"github.com/gofiber/fiber/v3/middleware/static"

	"github.com/Mathatter10/daycare-app/backend-go/internal/auth"
	"github.com/Mathatter10/daycare-app/backend-go/internal/config"
	"github.com/Mathatter10/daycare-app/backend-go/internal/database"
	"github.com/Mathatter10/daycare-app/backend-go/internal/handlers"
	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)

	if err := run(); err != nil {
		slog.Error("server exited with error", "err", err)
		os.Exit(1)
	}
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	pool, err := database.Connect(ctx, cfg.DatabaseURL, cfg.DBConnectTimeout)
	if err != nil {
		return err
	}
	defer pool.Close()

	authSvc := auth.NewService(pool,
		auth.NewJWTManager(cfg.JWTSecret, cfg.JWTAccessTTL),
		cfg.JWTRefreshTTL, cfg.SessionTTL)
	go cleanupLoop(ctx, authSvc)

	app := fiber.New(fiber.Config{
		AppName:      "daycare-api",
		ReadTimeout:  30 * time.Second, // media uploads need headroom
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  60 * time.Second,
		BodyLimit:    20 * 1024 * 1024,
		ErrorHandler: errorHandler,
		// TrustProxy stays false until we deploy behind a known proxy.
	})
	app.Use(recover.New(), requestLogger())

	health := &handlers.HealthHandler{DB: pool}
	app.Get("/api/health", health.Check)

	// Middleware is attached per route: a Group("", mw) in Fiber would also
	// wrap the public login routes that share the prefix.
	requireJWT := middleware.RequireJWT(authSvc)
	requireAdmin := middleware.RequireAdminSession(authSvc)

	// Mobile JSON API (JWT).
	authAPI := &handlers.AuthAPIHandler{Auth: authSvc}
	v1 := app.Group("/api/v1")
	v1.Post("/auth/login", middleware.LoginRateLimit(), authAPI.Login)
	v1.Post("/auth/refresh", authAPI.Refresh)
	v1.Post("/auth/logout", authAPI.Logout)
	v1.Get("/me", requireJWT, authAPI.Me)

	// Admin web (templ + HTMX, HttpOnly cookie session).
	adminAuth := &handlers.AdminAuthHandler{Auth: authSvc, CookieSecure: cfg.CookieSecure}
	admin := app.Group("/admin", middleware.SameOrigin())
	admin.Get("/login", adminAuth.LoginPage)
	admin.Post("/login", middleware.LoginRateLimit(), adminAuth.Login)
	admin.Post("/logout", adminAuth.Logout)
	admin.Get("/", requireAdmin, adminAuth.Dashboard)

	app.Get("/", func(c fiber.Ctx) error {
		return c.Redirect().Status(fiber.StatusSeeOther).To("/admin")
	})
	app.Get("/static*", static.New("./static"))

	errCh := make(chan error, 1)
	go func() {
		slog.Info("server listening", "port", cfg.Port, "env", cfg.Env)
		errCh <- app.Listen(":"+cfg.Port, fiber.ListenConfig{DisableStartupMessage: true})
	}()

	select {
	case err := <-errCh:
		return err
	case <-ctx.Done():
	}

	slog.Info("shutting down")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
	defer cancel()
	return app.ShutdownWithContext(shutdownCtx)
}

// cleanupLoop periodically deletes expired sessions and refresh tokens.
func cleanupLoop(ctx context.Context, svc *auth.Service) {
	ticker := time.NewTicker(time.Hour)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := svc.CleanupExpired(ctx); err != nil {
				slog.Error("cleanup expired auth records", "err", err)
			}
		}
	}
}

// errorHandler returns JSON for every error and hides internal details
// behind a generic message for 5xx responses.
func errorHandler(c fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError
	msg := "internal server error"
	var fe *fiber.Error
	if errors.As(err, &fe) {
		code, msg = fe.Code, fe.Message
	}
	if code >= fiber.StatusInternalServerError {
		slog.Error("request failed", "path", c.Route().Path, "err", err)
	}
	return c.Status(code).JSON(fiber.Map{"error": msg})
}

// requestLogger logs method, route, status and latency only — never bodies,
// query strings or headers, to keep PII and credentials out of logs.
func requestLogger() fiber.Handler {
	return func(c fiber.Ctx) error {
		start := time.Now()
		err := c.Next()
		slog.Info("request",
			"method", c.Method(),
			"route", c.Route().Path,
			"status", c.Response().StatusCode(),
			"latency_ms", time.Since(start).Milliseconds(),
		)
		return err
	}
}
