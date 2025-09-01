-- name: CreateUFField :one
INSERT INTO uf_fields (
    uf_group_id, name, label, field_type, is_required, weight, help_pre, help_post, options, validation_rules
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: GetUFField :one
SELECT * FROM uf_fields WHERE id = $1;

-- name: GetUFFieldByName :one
SELECT * FROM uf_fields WHERE uf_group_id = $1 AND name = $2;

-- name: ListUFFieldsByGroup :many
SELECT * FROM uf_fields 
WHERE uf_group_id = $1 
ORDER BY weight ASC, name ASC;

-- name: ListActiveUFFieldsByGroup :many
SELECT * FROM uf_fields 
WHERE uf_group_id = $1 AND is_active = TRUE 
ORDER BY weight ASC, name ASC;

-- name: ListUFFieldsByType :many
SELECT * FROM uf_fields 
WHERE uf_group_id = $1 AND field_type = $2 
ORDER BY weight ASC, name ASC;

-- name: ListRequiredUFFields :many
SELECT * FROM uf_fields 
WHERE uf_group_id = $1 AND is_required = TRUE 
ORDER BY weight ASC, name ASC;

-- name: ListAllUFFields :many
SELECT uff.*, ufg.title as group_title, d.name as domain_name FROM uf_fields uff
INNER JOIN uf_groups ufg ON uff.uf_group_id = ufg.id
INNER JOIN domains d ON ufg.domain_id = d.id
ORDER BY d.name ASC, ufg.title ASC, uff.weight ASC;

-- name: UpdateUFField :one
UPDATE uf_fields 
SET 
    name = $3,
    label = $4,
    field_type = $5,
    is_required = $6,
    weight = $7,
    help_pre = $8,
    help_post = $9,
    options = $10,
    validation_rules = $11,
    is_active = $12,
    updated_at = NOW()
WHERE id = $1 AND uf_group_id = $2 
RETURNING *;

-- name: UpdateUFFieldWeight :one
UPDATE uf_fields 
SET 
    weight = $3,
    updated_at = NOW()
WHERE id = $1 AND uf_group_id = $2 
RETURNING *;

-- name: UpdateUFFieldStatus :one
UPDATE uf_fields 
SET 
    is_active = $3,
    updated_at = NOW()
WHERE id = $1 AND uf_group_id = $2 
RETURNING *;

-- name: DeleteUFField :exec
DELETE FROM uf_fields WHERE id = $1 AND uf_group_id = $2;

-- name: DeleteUFFieldsByGroup :exec
DELETE FROM uf_fields WHERE uf_group_id = $1;

-- name: CountUFFieldsByGroup :one
SELECT COUNT(*) FROM uf_fields WHERE uf_group_id = $1;

-- name: CountActiveUFFieldsByGroup :one
SELECT COUNT(*) FROM uf_fields WHERE uf_group_id = $1 AND is_active = TRUE;

-- name: CountRequiredUFFieldsByGroup :one
SELECT COUNT(*) FROM uf_fields WHERE uf_group_id = $1 AND is_required = TRUE;

-- name: SearchUFFields :many
SELECT uff.*, ufg.title as group_title, d.name as domain_name FROM uf_fields uff
INNER JOIN uf_groups ufg ON uff.uf_group_id = ufg.id
INNER JOIN domains d ON ufg.domain_id = d.id
WHERE uff.name ILIKE $1 OR uff.label ILIKE $1 OR uff.help_pre ILIKE $1 OR uff.help_post ILIKE $1
ORDER BY d.name ASC, ufg.title ASC, uff.weight ASC
LIMIT $2 OFFSET $3;

-- name: GetUFFieldWithGroup :one
SELECT uff.*, ufg.title as group_title, ufg.name as group_name, d.name as domain_name FROM uf_fields uff
INNER JOIN uf_groups ufg ON uff.uf_group_id = ufg.id
INNER JOIN domains d ON ufg.domain_id = d.id
WHERE uff.id = $1;

-- name: ReorderUFFields :many
UPDATE uf_fields 
SET 
    weight = CASE 
        WHEN uf_fields.id = $1 THEN $2
        WHEN uf_fields.id = $3 THEN $4
        WHEN uf_fields.id = $5 THEN $6
        ELSE weight
    END,
    updated_at = NOW()
WHERE uf_group_id = $7 AND uf_fields.id IN ($1, $3, $5)
RETURNING *;

-- name: GetUFFieldsByEntity :many
SELECT uff.*, ufg.title as group_title FROM uf_fields uff
INNER JOIN uf_groups ufg ON uff.uf_group_id = ufg.id
INNER JOIN uf_joins ufj ON ufg.id = ufj.uf_group_id
WHERE ufj.entity_table = $1 AND ufj.entity_id = $2 AND uff.is_active = TRUE
ORDER BY ufj.weight ASC, uff.weight ASC, uff.name ASC;

-- name: ValidateUFFieldName :one
SELECT COUNT(*) > 0 as exists FROM uf_fields 
WHERE uf_group_id = $1 AND name = $2 AND id != $3;
