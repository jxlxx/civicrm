-- name: CreateTag :one
INSERT INTO tags (
    tag_set_id, name, description, color, icon, is_active, is_reserved, weight
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- name: GetTag :one
SELECT * FROM tags WHERE id = $1;

-- name: GetTagByName :one
SELECT * FROM tags WHERE name = $1;

-- name: GetTagsByTagSet :many
SELECT * FROM tags 
WHERE tag_set_id = $1 AND is_active = $2 
ORDER BY weight, name;

-- name: GetTagsByEntityTable :many
SELECT t.* FROM tags t
JOIN tag_sets ts ON t.tag_set_id = ts.id
WHERE ts.entity_table = $1 AND t.is_active = $2 
ORDER BY t.weight, t.name;

-- name: ListTags :many
SELECT * FROM tags 
WHERE is_active = $1 
ORDER BY weight, name;

-- name: ListActiveTags :many
SELECT * FROM tags 
WHERE is_active = TRUE 
ORDER BY weight, name;

-- name: ListReservedTags :many
SELECT * FROM tags 
WHERE is_reserved = TRUE AND is_active = $1 
ORDER BY weight, name;

-- name: ListTagsByColor :many
SELECT * FROM tags 
WHERE color = $1 AND is_active = $2 
ORDER BY weight, name;

-- name: SearchTags :many
SELECT * FROM tags 
WHERE (name ILIKE $1 OR description ILIKE $1) 
AND is_active = $2 
ORDER BY weight, name;

-- name: UpdateTag :one
UPDATE tags SET
    tag_set_id = $2, name = $3, description = $4, color = $5,
    icon = $6, is_active = $7, is_reserved = $8, weight = $9, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteTag :exec
DELETE FROM tags WHERE id = $1;

-- name: ActivateTag :exec
UPDATE tags SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateTag :exec
UPDATE tags SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateTagWeight :exec
UPDATE tags SET weight = $2, updated_at = NOW() WHERE id = $1;

-- name: UpdateTagColor :exec
UPDATE tags SET color = $2, updated_at = NOW() WHERE id = $1;

-- name: GetTagStats :many
SELECT 
    t.name as tag_name,
    ts.name as tag_set_name,
    ts.entity_table,
    COUNT(et.id) as usage_count
FROM tags t
JOIN tag_sets ts ON t.tag_set_id = ts.id
LEFT JOIN entity_tags et ON t.id = et.tag_id
WHERE t.is_active = $1
GROUP BY t.name, ts.name, ts.entity_table, t.weight, ts.weight
ORDER BY ts.weight, ts.name, t.weight, t.name;
