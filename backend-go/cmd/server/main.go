package main

import (
	"context"
	"errors"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"
	_ "time/tzdata" // the distroless image has no zoneinfo; embed it

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/recover"
	"github.com/gofiber/fiber/v3/middleware/static"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/Mathatter10/daycare-app/backend-go/internal/auth"
	"github.com/Mathatter10/daycare-app/backend-go/internal/config"
	"github.com/Mathatter10/daycare-app/backend-go/internal/database"
	"github.com/Mathatter10/daycare-app/backend-go/internal/handlers"
	"github.com/Mathatter10/daycare-app/backend-go/internal/media"
	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
	"github.com/Mathatter10/daycare-app/backend-go/internal/push"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
	"github.com/Mathatter10/daycare-app/backend-go/internal/storage"
	"github.com/Mathatter10/daycare-app/backend-go/internal/views"
	"github.com/Mathatter10/daycare-app/backend-go/internal/worker"
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

	if cfg.AutoMigrate {
		if err := database.Migrate(ctx, pool); err != nil {
			return err
		}
	}

	dispatcher, mediaSvc, closeWorkers, err := setupMediaAndPush(ctx, cfg, pool)
	if err != nil {
		return err
	}

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

	mobile := handlers.NewMobileHandler(pool, cfg.Location, mediaSvc, dispatcher)
	caregiverOnly := middleware.RequireRole(repository.UserRoleCaregiver)
	v1.Get("/children", requireJWT, mobile.Children)
	v1.Get("/children/:id/timeline", requireJWT, mobile.Timeline)
	v1.Get("/sync", requireJWT, mobile.Sync)
	v1.Post("/attendance/check-in", requireJWT, caregiverOnly, mobile.CheckIn)
	v1.Post("/attendance/check-out", requireJWT, caregiverOnly, mobile.CheckOut)
	v1.Put("/activities/:id", requireJWT, caregiverOnly, mobile.PutActivity)
	v1.Delete("/activities/:id", requireJWT, caregiverOnly, mobile.DeleteActivity)
	v1.Put("/media/:id/photo", requireJWT, caregiverOnly, mobile.PutPhoto)
	v1.Put("/media/:id/video", requireJWT, caregiverOnly, mobile.PutVideo)
	v1.Post("/media/:id/complete", requireJWT, caregiverOnly, mobile.CompleteVideo)
	v1.Get("/media/:id", requireJWT, mobile.GetMedia)
	v1.Delete("/media/:id", requireJWT, caregiverOnly, mobile.DeleteMedia)
	v1.Post("/devices", requireJWT, mobile.RegisterDevice)
	v1.Post("/devices/unregister", requireJWT, mobile.UnregisterDevice)

	// Admin web (templ + HTMX, HttpOnly cookie session).
	adminAuth := &handlers.AdminAuthHandler{Auth: authSvc, CookieSecure: cfg.CookieSecure}
	admin := app.Group("/admin", middleware.SameOrigin())
	admin.Get("/login", adminAuth.LoginPage)
	admin.Post("/login", middleware.LoginRateLimit(), adminAuth.Login)
	admin.Post("/logout", adminAuth.Logout)

	adm := handlers.NewAdminHandler(pool)
	admin.Get("/", requireAdmin, adm.Dashboard)

	admin.Get("/classes", requireAdmin, adm.Classes)
	admin.Get("/classes/new", requireAdmin, adm.NewClass)
	admin.Post("/classes", requireAdmin, adm.CreateClass)
	admin.Get("/classes/:id/edit", requireAdmin, adm.EditClass)
	admin.Post("/classes/:id", requireAdmin, adm.UpdateClass)
	admin.Delete("/classes/:id", requireAdmin, adm.DeleteClass)

	admin.Get("/children", requireAdmin, adm.Children)
	admin.Get("/children/new", requireAdmin, adm.NewChild)
	admin.Post("/children", requireAdmin, adm.CreateChild)
	admin.Get("/children/:id/edit", requireAdmin, adm.EditChild)
	admin.Post("/children/:id", requireAdmin, adm.UpdateChild)
	admin.Post("/children/:id/active", requireAdmin, adm.SetChildActive)

	for _, ri := range []views.RoleInfo{views.CaregiverRole, views.ParentRole} {
		base := "/" + ri.Path
		admin.Get(base, requireAdmin, adm.Users(ri))
		admin.Get(base+"/new", requireAdmin, adm.NewUser(ri))
		admin.Post(base, requireAdmin, adm.CreateUser(ri))
		admin.Get(base+"/:id/edit", requireAdmin, adm.EditUser(ri))
		admin.Post(base+"/:id", requireAdmin, adm.UpdateUser(ri))
		admin.Post(base+"/:id/active", requireAdmin, adm.SetUserActive(ri))
		admin.Post(base+"/:id/password", requireAdmin, adm.ResetUserPassword(ri))
	}

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
	// Stop taking requests first, then let queued photo and push jobs finish.
	return errors.Join(app.ShutdownWithContext(shutdownCtx), closeWorkers(shutdownCtx))
}

// setupMediaAndPush builds the push dispatcher and media service with their
// background worker pools. Missing storage or FCM settings disable those
// features instead of failing startup.
func setupMediaAndPush(ctx context.Context, cfg *config.Config, pool *pgxpool.Pool) (*push.Dispatcher, *media.Service, func(context.Context) error, error) {
	var sender push.Sender = push.LogSender{}
	if len(cfg.FCMCredentials) > 0 {
		fcm, err := push.NewFCM(ctx, cfg.FCMCredentials, cfg.FCMEndpoint)
		if err != nil {
			return nil, nil, nil, err
		}
		sender = fcm
		slog.Info("push notifications enabled (FCM)")
	} else {
		slog.Warn("push notifications disabled: FCM credentials not set")
	}

	var store *storage.Store
	if cfg.Storage.Configured() {
		s, err := storage.New(cfg.Storage)
		if err != nil {
			return nil, nil, nil, err
		}
		if err := s.Check(ctx); err != nil {
			slog.Error("media storage check failed", "err", err)
		} else {
			slog.Info("media storage enabled", "bucket", cfg.Storage.Bucket)
		}
		store = s
	} else {
		slog.Warn("media uploads disabled: S3 storage not configured")
	}

	pushPool := worker.NewPool("push", 4, 1000, 30*time.Second)
	mediaPool := worker.NewPool("media", 2, 50, 2*time.Minute)
	dispatcher := push.NewDispatcher(pool, sender, pushPool)
	mediaSvc := media.NewService(pool, store, mediaPool, dispatcher, push.Messages{Location: cfg.Location})

	closeAll := func(ctx context.Context) error {
		// Media jobs may still queue notifications, so drain them first.
		return errors.Join(mediaPool.Close(ctx), pushPool.Close(ctx))
	}
	return dispatcher, mediaSvc, closeAll, nil
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
// Handler errors are rendered here (not after) so the logged status is the
// one the client actually receives.
func requestLogger() fiber.Handler {
	return func(c fiber.Ctx) error {
		start := time.Now()
		if err := c.Next(); err != nil {
			if hErr := c.App().ErrorHandler(c, err); hErr != nil {
				_ = c.SendStatus(fiber.StatusInternalServerError)
			}
		}
		slog.Info("request",
			"method", c.Method(),
			"route", c.Route().Path,
			"status", c.Response().StatusCode(),
			"latency_ms", time.Since(start).Milliseconds(),
		)
		return nil
	}
}
