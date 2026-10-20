// Package config loads application settings from environment variables.
package config

import (
	"errors"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/joho/godotenv"

	"github.com/Mathatter10/daycare-app/backend-go/internal/storage"
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

	// Location is the daycare's time zone; it decides which calendar day an
	// attendance or activity belongs to.
	Location *time.Location
	// AutoMigrate applies pending database migrations at startup.
	AutoMigrate bool

	// Storage holds S3-compatible object storage settings (Cloudflare R2,
	// AWS S3, Supabase, MinIO). Media endpoints answer 503 until set.
	Storage storage.Config

	// FCMCredentials is a Firebase service-account JSON key. When empty,
	// push notifications are logged instead of sent.
	// FCMCredentialsFile, when set, is read at startup instead.
	FCMCredentials     []byte
	FCMCredentialsFile string
	FCMEndpoint        string
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
	cfg.AutoMigrate = getBool("AUTO_MIGRATE", true)

	tz := getEnv("DAYCARE_TIMEZONE", "Asia/Jakarta")
	loc, err := time.LoadLocation(tz)
	if err != nil {
		return nil, fmt.Errorf("DAYCARE_TIMEZONE %q: %w", tz, err)
	}
	cfg.Location = loc

	cfg.Storage = storage.Config{
		Endpoint:        storageEndpoint(os.Getenv("S3_ENDPOINT")),
		Region:          getEnv("S3_REGION", "auto"),
		Bucket:          os.Getenv("S3_BUCKET"),
		AccessKeyID:     os.Getenv("S3_ACCESS_KEY_ID"),
		SecretAccessKey: os.Getenv("S3_SECRET_ACCESS_KEY"),
		UseSSL:          getBool("S3_USE_SSL", true),
	}

	cfg.FCMEndpoint = getEnv("FCM_ENDPOINT", "https://fcm.googleapis.com")
	cfg.FCMCredentialsFile = os.Getenv("FCM_CREDENTIALS_FILE")
	if cfg.FCMCredentialsFile == "" {
		cfg.FCMCredentials = []byte(os.Getenv("FCM_CREDENTIALS_JSON"))
	}

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

// storageEndpoint accepts the endpoint as shown in provider dashboards: with
// scheme, trailing slash, or a bucket path (Cloudflare shows
// https://<id>.r2.cloudflarestorage.com/<bucket>). The client wants a bare
// host[:port].
func storageEndpoint(raw string) string {
	ep := strings.TrimSpace(raw)
	ep = strings.TrimPrefix(strings.TrimPrefix(ep, "https://"), "http://")
	host, _, _ := strings.Cut(ep, "/")
	return host
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
