package handlers

import (
	"context"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v3"
	"github.com/jackc/pgx/v5/pgxpool"
)

type HealthHandler struct {
	DB *pgxpool.Pool
}

// Check reports service liveness and database reachability.
// GET /api/health
func (h *HealthHandler) Check(c fiber.Ctx) error {
	ctx, cancel := context.WithTimeout(c.Context(), 2*time.Second)
	defer cancel()

	dbStatus := "up"
	status := fiber.StatusOK
	if err := h.DB.Ping(ctx); err != nil {
		dbStatus = "down"
		status = fiber.StatusServiceUnavailable
	}

	return c.Status(status).JSON(fiber.Map{
		"status":   http.StatusText(status),
		"database": dbStatus,
		"time":     time.Now().UTC().Format(time.RFC3339),
	})
}
