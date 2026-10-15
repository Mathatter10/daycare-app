-- name: GetMedia :one
SELECT * FROM media WHERE id = $1;

-- Idempotent create by client-generated id: a retry returns no row and the
-- caller reads the existing one.
-- name: CreateMedia :one
INSERT INTO media (id, child_id, activity_id, uploaded_by, kind, storage_key, mime_type, size_bytes, taken_at, status)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'pending')
ON CONFLICT (id) DO NOTHING
RETURNING *;

-- name: SetMediaPending :exec
UPDATE media SET status = 'pending' WHERE id = $1;

-- name: MarkPhotoReady :exec
UPDATE media SET
    status = 'ready', thumb_key = $2, mime_type = 'image/jpeg',
    size_bytes = $3, width = $4, height = $5
WHERE id = $1;

-- name: MarkVideoReady :exec
UPDATE media SET status = 'ready', size_bytes = $2
WHERE id = $1;

-- name: MarkMediaFailed :exec
UPDATE media SET status = 'failed' WHERE id = $1;

-- name: DeletePendingMedia :exec
DELETE FROM media WHERE id = $1 AND status = 'pending';

-- name: SoftDeleteMedia :exec
UPDATE media SET deleted_at = now()
WHERE id = $1 AND deleted_at IS NULL;

-- name: ListChildMedia :many
SELECT * FROM media
WHERE child_id = $1
  AND status = 'ready'
  AND deleted_at IS NULL
  AND taken_at >= sqlc.arg(from_time)
  AND taken_at <  sqlc.arg(to_time)
ORDER BY taken_at DESC;

-- Push notifications ---------------------------------------------------------

-- name: GetChildNames :one
SELECT full_name, nickname FROM children WHERE id = $1;

-- name: ListParentDeviceTokens :many
SELECT dt.token
FROM children ch
JOIN users u          ON u.id = ch.parent_id AND u.is_active
JOIN device_tokens dt ON dt.user_id = u.id
WHERE ch.id = $1;

-- A token moves to whoever registered it last (shared / re-used phones).
-- name: UpsertDeviceToken :exec
INSERT INTO device_tokens (user_id, token, platform)
VALUES ($1, $2, $3)
ON CONFLICT (token) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    platform = EXCLUDED.platform,
    last_seen_at = now();

-- name: DeleteDeviceToken :exec
DELETE FROM device_tokens WHERE token = $1 AND user_id = $2;

-- name: DeleteDeviceTokenByValue :exec
DELETE FROM device_tokens WHERE token = $1;

-- name: DeleteDeviceTokensForUser :exec
DELETE FROM device_tokens WHERE user_id = $1;
