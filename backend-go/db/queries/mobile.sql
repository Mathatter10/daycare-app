-- Mobile API queries. Access rules (docs/SECURITY.md):
--   caregiver: active children whose class the caregiver is assigned to
--   parent:    children where parent_id = the parent's user id

-- name: ListAccessibleChildren :many
SELECT
    ch.id, ch.full_name, ch.nickname, ch.date_of_birth, ch.gender,
    ch.class_id, COALESCE(c.name, '')::text AS class_name,
    ch.allergies, ch.medical_notes, ch.updated_at,
    a.check_in_at, a.check_out_at
FROM children ch
LEFT JOIN classes c    ON c.id = ch.class_id
LEFT JOIN attendance a ON a.child_id = ch.id AND a.attendance_date = sqlc.arg(today)::date
WHERE ch.is_active
  AND (
       (sqlc.arg(role)::user_role = 'parent' AND ch.parent_id = sqlc.arg(user_id)::uuid)
    OR (sqlc.arg(role)::user_role = 'caregiver' AND EXISTS (
            SELECT 1 FROM class_caregivers cc
            WHERE cc.class_id = ch.class_id AND cc.caregiver_id = sqlc.arg(user_id)::uuid))
  )
ORDER BY class_name, ch.full_name;

-- Parents keep read access to an inactive child's history; caregivers only
-- see active children in their classes.
-- name: CanAccessChild :one
SELECT EXISTS (
    SELECT 1 FROM children ch
    WHERE ch.id = sqlc.arg(child_id)::uuid
      AND (
           (sqlc.arg(role)::user_role = 'parent' AND ch.parent_id = sqlc.arg(user_id)::uuid)
        OR (sqlc.arg(role)::user_role = 'caregiver' AND ch.is_active AND EXISTS (
                SELECT 1 FROM class_caregivers cc
                WHERE cc.class_id = ch.class_id AND cc.caregiver_id = sqlc.arg(user_id)::uuid))
      )
) AS ok;

-- Attendance -------------------------------------------------------------------

-- name: GetAttendance :one
SELECT * FROM attendance
WHERE child_id = $1 AND attendance_date = $2;

-- Idempotent: replaying a check-in keeps the earliest time, so an offline
-- queue can safely resend it.
-- name: CheckIn :one
INSERT INTO attendance (child_id, attendance_date, check_in_at, check_in_by)
VALUES ($1, $2, $3, $4)
ON CONFLICT (child_id, attendance_date) DO UPDATE SET
    check_in_by = CASE WHEN EXCLUDED.check_in_at < attendance.check_in_at
                       THEN EXCLUDED.check_in_by ELSE attendance.check_in_by END,
    check_in_at = LEAST(attendance.check_in_at, EXCLUDED.check_in_at)
RETURNING *;

-- name: CheckOut :one
UPDATE attendance SET
    check_out_at = $3,
    check_out_by = $4,
    picked_up_by = COALESCE(sqlc.narg(picked_up_by), picked_up_by)
WHERE child_id = $1 AND attendance_date = $2
RETURNING *;

-- Activities -------------------------------------------------------------------

-- name: GetActivity :one
SELECT * FROM activities WHERE id = $1;

-- Create or update by client-generated id. The WHERE stops an id from being
-- reused for another child and leaves deleted activities deleted; in both
-- cases no row is returned.
-- name: UpsertActivity :one
INSERT INTO activities (id, child_id, caregiver_id, type, started_at, ended_at, details, notes)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
ON CONFLICT (id) DO UPDATE SET
    type       = EXCLUDED.type,
    started_at = EXCLUDED.started_at,
    ended_at   = EXCLUDED.ended_at,
    details    = EXCLUDED.details,
    notes      = EXCLUDED.notes
WHERE activities.child_id = EXCLUDED.child_id
  AND activities.deleted_at IS NULL
RETURNING id;

-- name: SoftDeleteActivity :exec
UPDATE activities SET deleted_at = now()
WHERE id = $1 AND deleted_at IS NULL;

-- name: GetActivityView :one
SELECT a.*, u.full_name AS caregiver_name
FROM activities a
JOIN users u ON u.id = a.caregiver_id
WHERE a.id = $1;

-- name: ListChildActivities :many
SELECT a.*, u.full_name AS caregiver_name
FROM activities a
JOIN users u ON u.id = a.caregiver_id
WHERE a.child_id = $1
  AND a.deleted_at IS NULL
  AND a.started_at >= sqlc.arg(from_time)
  AND a.started_at <  sqlc.arg(to_time)
ORDER BY a.started_at DESC;

-- Sync (keyset pagination on updated_at, id; includes soft-deleted rows) -------

-- name: SyncActivities :many
SELECT a.*, u.full_name AS caregiver_name
FROM activities a
JOIN users u ON u.id = a.caregiver_id
WHERE a.child_id = ANY(sqlc.arg(child_ids)::uuid[])
  AND a.started_at >= sqlc.arg(window_start)
  AND (a.updated_at, a.id) > (sqlc.arg(after_time)::timestamptz, sqlc.arg(after_id)::uuid)
ORDER BY a.updated_at, a.id
LIMIT sqlc.arg(max_rows);

-- name: SyncAttendance :many
SELECT * FROM attendance
WHERE child_id = ANY(sqlc.arg(child_ids)::uuid[])
  AND attendance_date >= sqlc.arg(window_start)::date
  AND (updated_at, id) > (sqlc.arg(after_time)::timestamptz, sqlc.arg(after_id)::uuid)
ORDER BY updated_at, id
LIMIT sqlc.arg(max_rows);
