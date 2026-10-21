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

-- Admin: one child's day, for incident reports ----------------------------------

-- name: GetChildReportHeader :one
SELECT
    ch.id, ch.full_name, ch.nickname, ch.date_of_birth, ch.allergies,
    ch.medical_notes, ch.is_active,
    COALESCE(c.name, '')::text AS class_name,
    p.full_name AS parent_name,
    p.phone     AS parent_phone
FROM children ch
JOIN users p        ON p.id = ch.parent_id
LEFT JOIN classes c ON c.id = ch.class_id
WHERE ch.id = $1;

-- name: GetAttendanceReport :one
SELECT
    a.check_in_at, a.check_out_at, a.picked_up_by, a.notes,
    cin.full_name  AS check_in_by_name,
    cout.full_name AS check_out_by_name
FROM attendance a
JOIN users cin       ON cin.id = a.check_in_by
LEFT JOIN users cout ON cout.id = a.check_out_by
WHERE a.child_id = $1 AND a.attendance_date = $2;

-- Includes deleted activities: a report must show what was removed.
-- name: ListChildDayActivitiesReport :many
SELECT
    a.id, a.type, a.started_at, a.ended_at, a.details, a.notes,
    a.created_at, a.updated_at, a.deleted_at,
    cg.full_name AS caregiver_name,
    d.full_name  AS deleted_by_name
FROM activities a
JOIN users cg     ON cg.id = a.caregiver_id
LEFT JOIN users d ON d.id = a.deleted_by
WHERE a.child_id = $1
  AND a.started_at >= sqlc.arg(from_time)
  AND a.started_at <  sqlc.arg(to_time)
ORDER BY a.started_at, a.created_at;

-- name: ListChildDayMediaReport :many
SELECT sqlc.embed(m), u.full_name AS uploaded_by_name
FROM media m
JOIN users u ON u.id = m.uploaded_by
WHERE m.child_id = $1
  AND m.status = 'ready'
  AND m.deleted_at IS NULL
  AND m.taken_at >= sqlc.arg(from_time)
  AND m.taken_at <  sqlc.arg(to_time)
ORDER BY m.taken_at;
