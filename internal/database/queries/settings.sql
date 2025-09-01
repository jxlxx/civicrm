-- name: CreateSetting :one
INSERT INTO settings (
    domain_id, name, value, description, is_system, is_public
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetSetting :one
SELECT * FROM settings WHERE id = $1;

-- name: GetSettingByName :one
SELECT * FROM settings WHERE domain_id = $1 AND name = $2;

-- name: GetSettingValue :one
SELECT value FROM settings WHERE domain_id = $1 AND name = $2;

-- name: GetSettingsByDomain :many
SELECT * FROM settings 
WHERE domain_id = $1 
ORDER BY name ASC;

-- name: GetPublicSettingsByDomain :many
SELECT * FROM settings 
WHERE domain_id = $1 AND is_public = TRUE 
ORDER BY name ASC;

-- name: GetSystemSettingsByDomain :many
SELECT * FROM settings 
WHERE domain_id = $1 AND is_system = TRUE 
ORDER BY name ASC;

-- name: ListAllSettings :many
SELECT s.*, d.name as domain_name FROM settings s
INNER JOIN domains d ON s.domain_id = d.id
ORDER BY d.name ASC, s.name ASC;

-- name: UpdateSetting :one
UPDATE settings 
SET 
    value = $3,
    description = $4,
    is_system = $5,
    is_public = $6,
    updated_at = NOW()
WHERE domain_id = $1 AND name = $2 
RETURNING *;

-- name: UpdateSettingValue :one
UPDATE settings 
SET 
    value = $3,
    updated_at = NOW()
WHERE domain_id = $1 AND name = $2 
RETURNING *;

-- name: DeleteSetting :exec
DELETE FROM settings WHERE domain_id = $1 AND name = $2;

-- name: DeleteSettingsByDomain :exec
DELETE FROM settings WHERE domain_id = $1;

-- name: CountSettingsByDomain :one
SELECT COUNT(*) FROM settings WHERE domain_id = $1;

-- name: CountSystemSettingsByDomain :one
SELECT COUNT(*) FROM settings WHERE domain_id = $1 AND is_system = TRUE;

-- name: SearchSettings :many
SELECT s.*, d.name as domain_name FROM settings s
INNER JOIN domains d ON s.domain_id = d.id
WHERE s.name ILIKE $1 OR s.description ILIKE $1
ORDER BY d.name ASC, s.name ASC
LIMIT $2 OFFSET $3;

-- name: GetSettingsByPrefix :many
SELECT * FROM settings 
WHERE domain_id = $1 AND name LIKE $2 || '%'
ORDER BY name ASC;

-- name: BulkUpdateSettings :many
UPDATE settings 
SET 
    value = CASE 
        WHEN name = ANY($3) THEN $4
        WHEN name = ANY($5) THEN $6
        WHEN name = ANY($7) THEN $8
        ELSE value
    END,
    updated_at = NOW()
WHERE domain_id = $1 AND name = ANY($2)
RETURNING *;
