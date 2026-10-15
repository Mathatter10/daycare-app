// Command createuser creates a user account directly in the database. Use it
// to bootstrap the first admin:
//
//	go run ./cmd/createuser -email admin@daycare.id -name "Admin" -role admin
//
// The password is prompted for (hidden) or read from CREATEUSER_PASSWORD.
// DATABASE_URL comes from the environment / .env, or from -database-url.
package main

import (
	"bufio"
	"context"
	"errors"
	"flag"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgtype"
	"github.com/joho/godotenv"
	"golang.org/x/term"

	"github.com/Mathatter10/daycare-app/backend-go/internal/auth"
	"github.com/Mathatter10/daycare-app/backend-go/internal/database"
	"github.com/Mathatter10/daycare-app/backend-go/internal/repository"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "error:", err)
		os.Exit(1)
	}
}

func run() error {
	_ = godotenv.Load()

	email := flag.String("email", "", "login email (required)")
	name := flag.String("name", "", "full name (required)")
	role := flag.String("role", "admin", "admin | caregiver | parent")
	phone := flag.String("phone", "", "phone number (optional)")
	dbURL := flag.String("database-url", os.Getenv("DATABASE_URL"), "PostgreSQL connection string")
	flag.Parse()

	*email = strings.TrimSpace(*email)
	if *email == "" || strings.TrimSpace(*name) == "" {
		flag.Usage()
		return errors.New("-email and -name are required")
	}
	userRole := repository.UserRole(*role)
	switch userRole {
	case repository.UserRoleAdmin, repository.UserRoleCaregiver, repository.UserRoleParent:
	default:
		return fmt.Errorf("invalid -role %q", *role)
	}
	if *dbURL == "" {
		return errors.New("DATABASE_URL is not set (use .env or -database-url)")
	}

	password, err := readPassword()
	if err != nil {
		return err
	}
	hash, err := auth.HashPassword(password)
	if err != nil {
		return err
	}

	ctx := context.Background()
	pool, err := database.Connect(ctx, *dbURL, 15*time.Second)
	if err != nil {
		return err
	}
	defer pool.Close()

	user, err := repository.New(pool).CreateUser(ctx, repository.CreateUserParams{
		Email:        *email,
		PasswordHash: hash,
		FullName:     strings.TrimSpace(*name),
		Phone:        pgtype.Text{String: *phone, Valid: *phone != ""},
		Role:         userRole,
	})
	if err != nil {
		return fmt.Errorf("create user: %w", err)
	}
	fmt.Printf("created %s user %s (id %s)\n", user.Role, user.Email, user.ID)
	return nil
}

func readPassword() (string, error) {
	if pw := os.Getenv("CREATEUSER_PASSWORD"); pw != "" {
		return pw, nil
	}
	fd := int(os.Stdin.Fd())
	if !term.IsTerminal(fd) {
		// e.g. Git Bash/mintty on Windows, where hidden input is unavailable.
		fmt.Fprint(os.Stderr, "Password (input will be visible): ")
		line, err := bufio.NewReader(os.Stdin).ReadString('\n')
		return strings.TrimRight(line, "\r\n"), err
	}

	fmt.Fprint(os.Stderr, "Password: ")
	first, err := term.ReadPassword(fd)
	fmt.Fprintln(os.Stderr)
	if err != nil {
		return "", err
	}
	fmt.Fprint(os.Stderr, "Repeat password: ")
	second, err := term.ReadPassword(fd)
	fmt.Fprintln(os.Stderr)
	if err != nil {
		return "", err
	}
	if string(first) != string(second) {
		return "", errors.New("passwords do not match")
	}
	return string(first), nil
}
