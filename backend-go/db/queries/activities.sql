-- Admin: deleted activities (audit and restore) --------------------------------

-- name: ListDeletedActivities :many
SELECT
    a.id, a.type, a.started_at, a.ended_at, a.details, a.notes, a.deleted_at,
    ch.full_name AS child_name,
    COALESCE(ch.nickname, '')::text AS child_nickname,
    cg.full_name AS caregiver_name,
    d.full_name  AS deleted_by_name
FROM activities a
JOIN children ch    ON ch.id = a.child_id
JOIN users cg       ON cg.id = a.caregiver_id
LEFT JOIN users d   ON d.id = a.deleted_by
WHERE a.deleted_at IS NOT NULL
  AND a.deleted_at >= sqlc.arg(since)::timestamptz
ORDER BY a.deleted_at DESC
LIMIT 300;

-- Clearing deleted_at bumps updated_at (trigger), so /sync brings the
-- activity back on every device.
-- name: RestoreActivity :execrows
UPDATE activities SET deleted_at = NULL, deleted_by = NULL
WHERE id = $1 AND deleted_at IS NOT NULL;
