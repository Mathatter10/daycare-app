package handlers

import (
	"errors"
	"strings"

	"github.com/gofiber/fiber/v3"

	"github.com/Mathatter10/daycare-app/backend-go/internal/auth"
	"github.com/Mathatter10/daycare-app/backend-go/internal/middleware"
	"github.com/Mathatter10/daycare-app/backend-go/internal/models"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

// AuthAPIHandler serves /api/v1/auth for the mobile app.
type AuthAPIHandler struct {
	Auth *auth.Service
}

type loginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type tokenResponse struct {
	auth.TokenPair
	User models.UserResponse `json:"user"`
}

// Login exchanges email + password for an access/refresh token pair.
// Only caregivers and parents use the mobile app; admins use the web.
// POST /api/v1/auth/login
func (h *AuthAPIHandler) Login(c fiber.Ctx) error {
	var req loginRequest
	if err := c.Bind().JSON(&req); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid JSON body")
	}
	req.Email = strings.TrimSpace(req.Email)
	if req.Email == "" || req.Password == "" {
		return fiber.NewError(fiber.StatusBadRequest, "email and password are required")
	}

	user, err := h.Auth.Authenticate(c.Context(), req.Email, req.Password)
	if errors.Is(err, auth.ErrInvalidCredentials) {
		return fiber.NewError(fiber.StatusUnauthorized, "invalid email or password")
	}
	if err != nil {
		return err
	}
	if user.Role != repository.UserRoleCaregiver && user.Role != repository.UserRoleParent {
		return fiber.NewError(fiber.StatusForbidden, "this account cannot use the mobile app")
	}

	pair, err := h.Auth.IssueTokens(c.Context(), user)
	if err != nil {
		return err
	}
	return c.JSON(tokenResponse{TokenPair: pair, User: models.NewUserResponse(user)})
}

// Refresh rotates the refresh token and returns a new token pair.
// POST /api/v1/auth/refresh
func (h *AuthAPIHandler) Refresh(c fiber.Ctx) error {
	var req refreshRequest
	if err := c.Bind().JSON(&req); err != nil || req.RefreshToken == "" {
		return fiber.NewError(fiber.StatusBadRequest, "refresh_token is required")
	}
	pair, user, err := h.Auth.Refresh(c.Context(), req.RefreshToken)
	if errors.Is(err, auth.ErrInvalidToken) {
		return fiber.NewError(fiber.StatusUnauthorized, "invalid or expired refresh token")
	}
	if err != nil {
		return err
	}
	return c.JSON(tokenResponse{TokenPair: pair, User: models.NewUserResponse(user)})
}

// Logout revokes the given refresh token. The app should also discard its
// access token locally.
// POST /api/v1/auth/logout
func (h *AuthAPIHandler) Logout(c fiber.Ctx) error {
	var req refreshRequest
	if err := c.Bind().JSON(&req); err != nil || req.RefreshToken == "" {
		return fiber.NewError(fiber.StatusBadRequest, "refresh_token is required")
	}
	if err := h.Auth.Logout(c.Context(), req.RefreshToken); err != nil {
		return err
	}
	return c.SendStatus(fiber.StatusNoContent)
}

// Me returns the authenticated user's profile.
// GET /api/v1/me
func (h *AuthAPIHandler) Me(c fiber.Ctx) error {
	return c.JSON(models.NewUserResponse(middleware.CurrentUser(c)))
}
