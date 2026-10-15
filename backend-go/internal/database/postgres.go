// Package database manages the PostgreSQL connection pool.
package database

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Connect creates a pgx pool and verifies connectivity. The timeout is
// generous because serverless Postgres (Neon) may cold-start.
func Connect(ctx context.Context, url string, timeout time.Duration) (*pgxpool.Pool, error) {
	poolCfg, err := pgxpool.ParseConfig(url)
	if err != nil {
		return nil, fmt.Errorf("parse DATABASE_URL: %w", err)
	}
	poolCfg.MaxConns = 10
	poolCfg.MaxConnIdleTime = 5 * time.Minute

	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()

	pool, err := pgxpool.NewWithConfig(ctx, poolCfg)
	if err != nil {
		return nil, fmt.Errorf("create pool: %w", err)
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("ping database: %w", err)
	}
	return pool, nil
}
