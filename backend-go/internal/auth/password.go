// Package auth implements password hashing, JWT access tokens, rotating
// refresh tokens (mobile) and cookie sessions (admin web).
package auth

import (
	"errors"
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

const (
	bcryptCost        = 12
	MinPasswordLength = 8
	maxPasswordBytes  = 72 // bcrypt ignores anything longer
)

var ErrWeakPassword = fmt.Errorf("password must be %d-%d characters", MinPasswordLength, maxPasswordBytes)

// dummyHash is compared against when a user does not exist, so a login for
// an unknown email takes as long as one with a wrong password.
var dummyHash, _ = bcrypt.GenerateFromPassword([]byte("dummy-password-for-timing"), bcryptCost)

func HashPassword(password string) (string, error) {
	if len(password) < MinPasswordLength || len(password) > maxPasswordBytes {
		return "", ErrWeakPassword
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcryptCost)
	if err != nil {
		return "", fmt.Errorf("hash password: %w", err)
	}
	return string(hash), nil
}

// checkPassword reports whether password matches hash. Any error other than
// a mismatch (e.g. a malformed hash) is returned.
func checkPassword(hash, password string) (bool, error) {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	switch {
	case err == nil:
		return true, nil
	case errors.Is(err, bcrypt.ErrMismatchedHashAndPassword):
		return false, nil
	default:
		return false, err
	}
}
