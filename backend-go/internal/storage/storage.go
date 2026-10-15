// Package storage wraps S3-compatible object storage (Cloudflare R2, AWS S3,
// Supabase Storage, MinIO). Objects are private; clients only ever get
// short-lived presigned URLs (docs/SECURITY.md, "Media URLs").
package storage

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

// ErrNotFound is returned by Stat when the object does not exist.
var ErrNotFound = errors.New("object not found")

type Config struct {
	Endpoint        string // host[:port], e.g. <account>.r2.cloudflarestorage.com
	Region          string // "auto" for R2
	Bucket          string
	AccessKeyID     string
	SecretAccessKey string
	UseSSL          bool
}

// Configured reports whether enough settings are present to connect.
func (c Config) Configured() bool {
	return c.Endpoint != "" && c.Bucket != "" && c.AccessKeyID != "" && c.SecretAccessKey != ""
}

type ObjectInfo struct {
	Size        int64
	ContentType string
}

type Store struct {
	client *minio.Client
	bucket string
}

func New(cfg Config) (*Store, error) {
	client, err := minio.New(cfg.Endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(cfg.AccessKeyID, cfg.SecretAccessKey, ""),
		Secure: cfg.UseSSL,
		Region: cfg.Region,
	})
	if err != nil {
		return nil, fmt.Errorf("storage client: %w", err)
	}
	return &Store{client: client, bucket: cfg.Bucket}, nil
}

// Check verifies the bucket is reachable with the given credentials.
func (s *Store) Check(ctx context.Context) error {
	ok, err := s.client.BucketExists(ctx, s.bucket)
	if err != nil {
		return fmt.Errorf("storage bucket %q: %w", s.bucket, err)
	}
	if !ok {
		return fmt.Errorf("storage bucket %q does not exist", s.bucket)
	}
	return nil
}

func (s *Store) Put(ctx context.Context, key, contentType string, body io.Reader, size int64) error {
	_, err := s.client.PutObject(ctx, s.bucket, key, body, size, minio.PutObjectOptions{ContentType: contentType})
	if err != nil {
		return fmt.Errorf("put %s: %w", key, err)
	}
	return nil
}

// PresignPut returns a URL the client can PUT the object to. Content-Type
// is part of the signature, so the client must send exactly that header.
func (s *Store) PresignPut(ctx context.Context, key, contentType string, ttl time.Duration) (string, error) {
	u, err := s.client.PresignHeader(ctx, http.MethodPut, s.bucket, key, ttl, url.Values{},
		http.Header{"Content-Type": []string{contentType}})
	if err != nil {
		return "", fmt.Errorf("presign put %s: %w", key, err)
	}
	return u.String(), nil
}

// PresignGet returns a URL that can read the object until it expires.
func (s *Store) PresignGet(ctx context.Context, key string, ttl time.Duration) (string, error) {
	u, err := s.client.PresignedGetObject(ctx, s.bucket, key, ttl, url.Values{})
	if err != nil {
		return "", fmt.Errorf("presign get %s: %w", key, err)
	}
	return u.String(), nil
}

func (s *Store) Stat(ctx context.Context, key string) (ObjectInfo, error) {
	info, err := s.client.StatObject(ctx, s.bucket, key, minio.StatObjectOptions{})
	if err != nil {
		if minio.ToErrorResponse(err).StatusCode == http.StatusNotFound {
			return ObjectInfo{}, ErrNotFound
		}
		return ObjectInfo{}, fmt.Errorf("stat %s: %w", key, err)
	}
	return ObjectInfo{Size: info.Size, ContentType: info.ContentType}, nil
}

func (s *Store) Delete(ctx context.Context, keys ...string) error {
	var errs []error
	for _, key := range keys {
		if key == "" {
			continue
		}
		if err := s.client.RemoveObject(ctx, s.bucket, key, minio.RemoveObjectOptions{}); err != nil {
			errs = append(errs, fmt.Errorf("delete %s: %w", key, err))
		}
	}
	return errors.Join(errs...)
}
