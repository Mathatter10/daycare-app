// Package auth implements password hashing, JWT access tokens, rotating
// refresh tokens (mobile) and cookie sessions (admin web).
package auth

import (
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"

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

// tempAlphabet omits look-alike characters (0/O, 1/l/I) so a password read
// aloud or copied by hand is not mistyped.
const tempAlphabet = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789"

// GenerateTempPassword returns a random 10-character password (~57 bits)
// for accounts created or reset by an admin.
func GenerateTempPassword() (string, error) {
	b := make([]byte, 10)
	max := big.NewInt(int64(len(tempAlphabet)))
	for i := range b {
		n, err := rand.Int(rand.Reader, max)
		if err != nil {
			return "", fmt.Errorf("generate password: %w", err)
		}
		b[i] = tempAlphabet[n.Int64()]
	}
	return string(b), nil
}
