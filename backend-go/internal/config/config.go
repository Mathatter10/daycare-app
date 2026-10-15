// Package config loads application settings from environment variables.
package config

import (
	"errors"
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	Env         string // development | production
	Port        string
	DatabaseURL string

	JWTSecret        string
	JWTAccessTTL     time.Duration
	JWTRefreshTTL    time.Duration
	SessionTTL       time.Duration
	CookieSecure     bool
	ShutdownTimeout  time.Duration
	DBConnectTimeout time.Duration
}

// Load reads a .env file if present (local development only) and then
// builds the Config from the process environment.
func Load() (*Config, error) {
	// A missing .env is fine: production injects real env vars.
	if err := godotenv.Load(); err != nil && !errors.Is(err, os.ErrNotExist) {
		return nil, fmt.Errorf("load .env: %w", err)
	}

	cfg := &Config{
		Env:              getEnv("APP_ENV", "development"),
		Port:             getEnv("PORT", "8080"),
		DatabaseURL:      os.Getenv("DATABASE_URL"),
		JWTSecret:        os.Getenv("JWT_SECRET"),
		JWTAccessTTL:     getDuration("JWT_ACCESS_TTL", 24*time.Hour),
		JWTRefreshTTL:    getDuration("JWT_REFRESH_TTL", 30*24*time.Hour),
		SessionTTL:       getDuration("SESSION_TTL", 12*time.Hour),
		ShutdownTimeout:  getDuration("SHUTDOWN_TIMEOUT", 10*time.Second),
		DBConnectTimeout: getDuration("DB_CONNECT_TIMEOUT", 10*time.Second),
	}
	cfg.CookieSecure = getBool("COOKIE_SECURE", cfg.IsProduction())

	if err := cfg.validate(); err != nil {
		return nil, err
	}
	return cfg, nil
}

func (c *Config) IsProduction() bool { return c.Env == "production" }

func (c *Config) validate() error {
	var errs []error
	if c.DatabaseURL == "" {
		errs = append(errs, errors.New("DATABASE_URL is required"))
	}
	if len(c.JWTSecret) < 32 {
		errs = append(errs, errors.New("JWT_SECRET must be at least 32 characters"))
	}
	return errors.Join(errs...)
}

func getEnv(key, fallback string) string {
	if v, ok := os.LookupEnv(key); ok && v != "" {
		return v
	}
	return fallback
}

func getDuration(key string, fallback time.Duration) time.Duration {
	if d, err := time.ParseDuration(os.Getenv(key)); err == nil {
		return d
	}
	return fallback
}

func getBool(key string, fallback bool) bool {
	if b, err := strconv.ParseBool(os.Getenv(key)); err == nil {
		return b
	}
	return fallback
}
