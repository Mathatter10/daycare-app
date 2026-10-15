// Package models holds API request/response types, kept separate from the
// sqlc-generated database rows so internal columns never leak by accident.
package models

import (
	"github.com/google/uuid"

	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

type UserResponse struct {
	ID       uuid.UUID `json:"id"`
	Email    string    `json:"email"`
	FullName string    `json:"full_name"`
	Phone    *string   `json:"phone"`
	Role     string    `json:"role"`
}

func NewUserResponse(u repository.User) UserResponse {
	resp := UserResponse{
		ID:       u.ID,
		Email:    u.Email,
		FullName: u.FullName,
		Role:     string(u.Role),
	}
	if u.Phone.Valid {
		resp.Phone = &u.Phone.String
	}
	return resp
}
