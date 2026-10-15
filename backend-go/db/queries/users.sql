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
