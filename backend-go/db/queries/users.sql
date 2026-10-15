-- name: GetUserByEmail :one
SELECT * FROM users
WHERE lower(email) = lower(sqlc.arg(email));

-- name: GetUserByID :one
SELECT * FROM users
WHERE id = $1;

-- name: CreateUser :one
INSERT INTO users (email, password_hash, full_name, phone, role)
VALUES ($1, $2, $3, $4, $5)
RETURNING *;

-- Admin master data ----------------------------------------------------------

-- Lists caregivers or parents with their linked classes / children. Pass id
-- to fetch a single row in the same shape (for re-rendering one table row).
-- name: ListUsers :many
SELECT
    u.id, u.email, u.full_name, u.phone, u.role, u.is_active, u.created_at,
    COALESCE((SELECT string_agg(c.name, ', ' ORDER BY c.name)
              FROM class_caregivers cc JOIN classes c ON c.id = cc.class_id
              WHERE cc.caregiver_id = u.id), '')::text AS class_names,
    COALESCE((SELECT string_agg(ch.full_name, ', ' ORDER BY ch.full_name)
              FROM children ch
              WHERE ch.parent_id = u.id AND ch.is_active), '')::text AS child_names
FROM users u
WHERE u.role = sqlc.arg(role)::user_role
  AND (sqlc.narg(id)::uuid IS NULL OR u.id = sqlc.narg(id))
  AND (sqlc.arg(search)::text = ''
       OR u.full_name ILIKE '%' || sqlc.arg(search) || '%'
       OR u.email ILIKE '%' || sqlc.arg(search) || '%')
ORDER BY u.is_active DESC, u.full_name
LIMIT 500;

-- name: ListUserOptions :many
SELECT id, full_name, email FROM users
WHERE role = $1 AND is_active
ORDER BY full_name;

-- The role condition stops these admin queries from touching accounts of
-- another role (e.g. editing an admin through the parents page).
-- name: UpdateUserProfile :execrows
UPDATE users SET email = $2, full_name = $3, phone = $4
WHERE id = $1 AND role = $5;

-- name: SetUserActive :execrows
UPDATE users SET is_active = $2
WHERE id = $1 AND role = $3;

-- name: SetUserPassword :execrows
UPDATE users SET password_hash = $2
WHERE id = $1 AND role = $3;

-- name: DashboardCounts :one
SELECT
    (SELECT count(*) FROM children WHERE is_active)::int                         AS children,
    (SELECT count(*) FROM classes)::int                                          AS classes,
    (SELECT count(*) FROM users WHERE role = 'caregiver' AND is_active)::int     AS caregivers,
    (SELECT count(*) FROM users WHERE role = 'parent' AND is_active)::int        AS parents;
