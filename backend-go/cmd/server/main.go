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

	"github.com/Mathatter10/daycare-app/backend-go/internal/config"
	"github.com/Mathatter10/daycare-app/backend-go/internal/database"
	"github.com/Mathatter10/daycare-app/backend-go/internal/handlers"
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

	// Route groups wired up in later sprints:
	//   /api/v1/...  JSON API for mobile (JWT)
	//   /admin/...   templ + HTMX admin web (HttpOnly cookie session)
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
