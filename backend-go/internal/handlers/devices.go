package handlers

import (
	"strings"

	"github.com/gofiber/fiber/v3"

	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

type deviceRequest struct {
	Token    string `json:"token"`
	Platform string `json:"platform"`
}

// RegisterDevice stores the phone's FCM token so the user receives push
// notifications. Call after login and whenever FCM rotates the token.
// POST /api/v1/devices
func (h *MobileHandler) RegisterDevice(c fiber.Ctx) error {
	var req deviceRequest
	if err := c.Bind().JSON(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid JSON body")
	}
	req.Token = strings.TrimSpace(req.Token)
	if req.Token == "" || len(req.Token) > 4096 {
		return fiber.NewError(fiber.StatusBadRequest, "token is required")
	}
	platform := repository.DevicePlatform(req.Platform)
	switch platform {
	case repository.DevicePlatformAndroid, repository.DevicePlatformIos, repository.DevicePlatformWeb:
	default:
		return fiber.NewError(fiber.StatusUnprocessableEntity, "platform must be android, ios or web")
	}
	if err := h.Q.UpsertDeviceToken(c.Context(), repository.UpsertDeviceTokenParams{
		UserID:   middleware.CurrentUser(c).ID,
		Token:    req.Token,
		Platform: platform,
	}); err != nil {
		return err
	}
	return c.SendStatus(fiber.StatusNoContent)
}

// UnregisterDevice stops notifications to this phone. Call on logout.
// POST /api/v1/devices/unregister
func (h *MobileHandler) UnregisterDevice(c fiber.Ctx) error {
	var req deviceRequest
	if err := c.Bind().JSON(&req); err != nil || strings.TrimSpace(req.Token) == "" {
		return fiber.NewError(fiber.StatusBadRequest, "token is required")
	}
	if err := h.Q.DeleteDeviceToken(c.Context(), repository.DeleteDeviceTokenParams{
		Token:  strings.TrimSpace(req.Token),
		UserID: middleware.CurrentUser(c).ID,
	}); err != nil {
		return err
	}
	return c.SendStatus(fiber.StatusNoContent)
}
