-- name: CreateUser :exec
INSERT INTO iam.users (
	id, nickname, email, password, slug, roles, platform_theme
) VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: GetUserById :one
SELECT *
FROM iam.users
WHERE id = $1
LIMIT 1;
