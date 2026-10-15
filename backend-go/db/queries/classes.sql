-- name: ListClasses :many
SELECT
    c.id, c.name, c.description,
    (SELECT count(*) FROM children ch
     WHERE ch.class_id = c.id AND ch.is_active)::int AS child_count,
    COALESCE((SELECT string_agg(u.full_name, ', ' ORDER BY u.full_name)
              FROM class_caregivers cc JOIN users u ON u.id = cc.caregiver_id
              WHERE cc.class_id = c.id), '')::text AS caregiver_names
FROM classes c
WHERE sqlc.narg(id)::uuid IS NULL OR c.id = sqlc.narg(id)
ORDER BY c.name;

-- name: ListClassOptions :many
SELECT id, name FROM classes ORDER BY name;

-- name: GetClass :one
SELECT * FROM classes WHERE id = $1;

-- name: CreateClass :one
INSERT INTO classes (name, description)
VALUES ($1, $2)
RETURNING id;

-- name: UpdateClass :execrows
UPDATE classes SET name = $2, description = $3
WHERE id = $1;

-- name: DeleteClass :execrows
DELETE FROM classes WHERE id = $1;

-- name: ListClassCaregiverIDs :many
SELECT caregiver_id FROM class_caregivers WHERE class_id = $1;

-- name: ClearClassCaregivers :exec
DELETE FROM class_caregivers WHERE class_id = $1;

-- name: AssignCaregiverToClass :exec
INSERT INTO class_caregivers (class_id, caregiver_id)
VALUES ($1, $2)
ON CONFLICT DO NOTHING;
