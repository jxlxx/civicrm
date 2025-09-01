-- name: CreateDomain :one
INSERT INTO domains (
    name, description, is_active
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: GetDomain :one
SELECT * FROM domains WHERE id = $1;

-- name: GetDomainByName :one
SELECT * FROM domains WHERE name = $1;

-- name: ListDomains :many
SELECT * FROM domains 
ORDER BY name ASC;

-- name: ListActiveDomains :many
SELECT * FROM domains 
WHERE is_active = TRUE 
ORDER BY name ASC;

-- name: UpdateDomain :one
UPDATE domains 
SET 
    name = $2,
    description = $3,
    is_active = $4,
    updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- name: DeleteDomain :exec
DELETE FROM domains WHERE id = $1;

-- name: CountDomains :one
SELECT COUNT(*) FROM domains;

-- name: CountActiveDomains :one
SELECT COUNT(*) FROM domains WHERE is_active = TRUE;

-- name: GetDomainSettings :many
SELECT s.* FROM settings s
INNER JOIN domains d ON s.domain_id = d.id
WHERE d.id = $1
ORDER BY s.name ASC;

-- name: GetDomainNavigation :many
SELECT n.* FROM navigation n
INNER JOIN domains d ON n.domain_id = d.id
WHERE d.id = $1 AND n.parent_id IS NULL
ORDER BY n.weight ASC, n.name ASC;

-- name: GetDomainUsers :many
SELECT u.* FROM users u
INNER JOIN domains d ON u.domain_id = d.id
WHERE d.id = $1
ORDER BY u.username ASC;
