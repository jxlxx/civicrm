-- name: CreateTagSet :one
INSERT INTO tag_sets (
    name, title, description, entity_table, is_active, is_reserved, weight
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetTagSet :one
SELECT * FROM tag_sets WHERE id = $1;

-- name: GetTagSetByName :one
SELECT * FROM tag_sets WHERE name = $1;

-- name: GetTagSetsByEntityTable :many
SELECT * FROM tag_sets 
WHERE entity_table = $1 AND is_active = $2 
ORDER BY weight, name;

-- name: ListTagSets :many
SELECT * FROM tag_sets 
WHERE is_active = $1 
ORDER BY weight, name;

-- name: ListActiveTagSets :many
SELECT * FROM tag_sets 
WHERE is_active = TRUE 
ORDER BY weight, name;

-- name: ListReservedTagSets :many
SELECT * FROM tag_sets 
WHERE is_reserved = TRUE AND is_active = $1 
ORDER BY weight, name;

-- name: SearchTagSets :many
SELECT * FROM tag_sets 
WHERE (name ILIKE $1 OR title ILIKE $1 OR description ILIKE $1) 
AND is_active = $2 
ORDER BY weight, name;

-- name: UpdateTagSet :one
UPDATE tag_sets SET
    name = $2, title = $3, description = $4, entity_table = $5,
    is_active = $6, is_reserved = $7, weight = $8, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteTagSet :exec
DELETE FROM tag_sets WHERE id = $1;

-- name: ActivateTagSet :exec
UPDATE tag_sets SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateTagSet :exec
UPDATE tag_sets SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateTagSetWeight :exec
UPDATE tag_sets SET weight = $2, updated_at = NOW() WHERE id = $1;

-- name: GetTagSetStats :many
SELECT 
    ts.name as tag_set_name,
    ts.entity_table,
    COUNT(t.id) as tag_count
FROM tag_sets ts
LEFT JOIN tags t ON ts.id = t.tag_set_id AND t.is_active = TRUE
WHERE ts.is_active = $1
GROUP BY ts.name, ts.entity_table, ts.weight
ORDER BY ts.weight, ts.name;
