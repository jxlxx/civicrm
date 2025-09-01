-- name: CreateUFGroup :one
INSERT INTO uf_groups (
    domain_id, name, title, description, is_active, is_reserved
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetUFGroup :one
SELECT * FROM uf_groups WHERE id = $1;

-- name: GetUFGroupByName :one
SELECT * FROM uf_groups WHERE domain_id = $1 AND name = $2;

-- name: GetUFGroupByTitle :one
SELECT * FROM uf_groups WHERE domain_id = $1 AND title = $2;

-- name: ListUFGroupsByDomain :many
SELECT * FROM uf_groups 
WHERE domain_id = $1 
ORDER BY title ASC;

-- name: ListActiveUFGroupsByDomain :many
SELECT * FROM uf_groups 
WHERE domain_id = $1 AND is_active = TRUE 
ORDER BY title ASC;

-- name: ListReservedUFGroupsByDomain :many
SELECT * FROM uf_groups 
WHERE domain_id = $1 AND is_reserved = TRUE 
ORDER BY title ASC;

-- name: ListAllUFGroups :many
SELECT ufg.*, d.name as domain_name FROM uf_groups ufg
INNER JOIN domains d ON ufg.domain_id = d.id
ORDER BY d.name ASC, ufg.title ASC;

-- name: UpdateUFGroup :one
UPDATE uf_groups 
SET 
    name = $3,
    title = $4,
    description = $5,
    is_active = $6,
    is_reserved = $7,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: UpdateUFGroupStatus :one
UPDATE uf_groups 
SET 
    is_active = $3,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: DeleteUFGroup :exec
DELETE FROM uf_groups WHERE id = $1 AND domain_id = $2;

-- name: DeleteUFGroupsByDomain :exec
DELETE FROM uf_groups WHERE domain_id = $1;

-- name: CountUFGroupsByDomain :one
SELECT COUNT(*) FROM uf_groups WHERE domain_id = $1;

-- name: CountActiveUFGroupsByDomain :one
SELECT COUNT(*) FROM uf_groups WHERE domain_id = $1 AND is_active = TRUE;

-- name: SearchUFGroups :many
SELECT ufg.*, d.name as domain_name FROM uf_groups ufg
INNER JOIN domains d ON ufg.domain_id = d.id
WHERE ufg.name ILIKE $1 OR ufg.title ILIKE $1 OR ufg.description ILIKE $1
ORDER BY d.name ASC, ufg.title ASC
LIMIT $2 OFFSET $3;

-- name: GetUFGroupWithFields :many
SELECT ufg.*, uff.* FROM uf_groups ufg
LEFT JOIN uf_fields uff ON ufg.id = uff.uf_group_id
WHERE ufg.id = $1
ORDER BY uff.weight ASC, uff.name ASC;

-- name: GetUFGroupWithJoins :many
SELECT ufg.*, ufj.* FROM uf_groups ufg
LEFT JOIN uf_joins ufj ON ufg.id = ufj.uf_group_id
WHERE ufg.id = $1
ORDER BY ufj.weight ASC;

-- name: GetUFGroupsByEntity :many
SELECT ufg.* FROM uf_groups ufg
INNER JOIN uf_joins ufj ON ufg.id = ufj.uf_group_id
WHERE ufj.entity_table = $1 AND ufj.entity_id = $2 AND ufg.is_active = TRUE
ORDER BY ufj.weight ASC, ufg.title ASC;
