-- Pass id to fetch a single row in the list shape (set include_inactive).
-- name: ListChildren :many
SELECT
    ch.id, ch.full_name, ch.nickname, ch.date_of_birth, ch.gender,
    ch.class_id, ch.allergies, ch.is_active,
    COALESCE(c.name, '')::text AS class_name,
    p.full_name AS parent_name,
    p.email     AS parent_email
FROM children ch
JOIN users p        ON p.id = ch.parent_id
LEFT JOIN classes c ON c.id = ch.class_id
WHERE (sqlc.narg(id)::uuid IS NULL OR ch.id = sqlc.narg(id))
  AND (sqlc.narg(class_id)::uuid IS NULL OR ch.class_id = sqlc.narg(class_id))
  AND (sqlc.arg(include_inactive)::bool OR ch.is_active)
  AND (sqlc.arg(search)::text = ''
       OR ch.full_name ILIKE '%' || sqlc.arg(search) || '%'
       OR ch.nickname  ILIKE '%' || sqlc.arg(search) || '%'
       OR p.full_name  ILIKE '%' || sqlc.arg(search) || '%')
ORDER BY ch.is_active DESC, ch.full_name
LIMIT 500;

-- name: GetChildForEdit :one
SELECT ch.*, p.email AS parent_email
FROM children ch
JOIN users p ON p.id = ch.parent_id
WHERE ch.id = $1;

-- name: CreateChild :one
INSERT INTO children (
    full_name, nickname, date_of_birth, gender, class_id, parent_id,
    allergies, medical_notes, emergency_contact
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
RETURNING id;

-- name: UpdateChild :execrows
UPDATE children SET
    full_name = $2, nickname = $3, date_of_birth = $4, gender = $5,
    class_id = $6, parent_id = $7, allergies = $8, medical_notes = $9,
    emergency_contact = $10
WHERE id = $1;

-- name: SetChildActive :execrows
UPDATE children SET is_active = $2 WHERE id = $1;
