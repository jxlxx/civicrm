-- name: CreateEntityTag :one
INSERT INTO entity_tags (
    entity_table, entity_id, tag_id
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: GetEntityTag :one
SELECT * FROM entity_tags WHERE id = $1;

-- name: GetEntityTagsByEntity :many
SELECT * FROM entity_tags 
WHERE entity_table = $1 AND entity_id = $2 
ORDER BY id;

-- name: GetEntityTagsByTag :many
SELECT * FROM entity_tags 
WHERE tag_id = $1 
ORDER BY id;

-- name: GetEntityTagsByTable :many
SELECT * FROM entity_tags 
WHERE entity_table = $1 
ORDER BY id;

-- name: GetEntityTagsWithDetails :many
SELECT 
    et.*,
    t.name as tag_name,
    t.description as tag_description,
    t.color as tag_color,
    t.icon as tag_icon,
    ts.name as tag_set_name,
    ts.entity_table as tag_set_entity_table
FROM entity_tags et
JOIN tags t ON et.tag_id = t.id
JOIN tag_sets ts ON t.tag_set_id = ts.id
WHERE et.entity_table = $1 AND et.entity_id = $2 
ORDER BY t.weight, t.name;

-- name: ListEntityTags :many
SELECT * FROM entity_tags 
ORDER BY id;

-- name: ListEntityTagsByTable :many
SELECT * FROM entity_tags 
WHERE entity_table = $1 
ORDER BY id;

-- name: ListEntityTagsByTagSet :many
SELECT et.* FROM entity_tags et
JOIN tags t ON et.tag_id = t.id
WHERE t.tag_set_id = $1 
ORDER BY et.id;

-- name: SearchEntityTags :many
SELECT et.* FROM entity_tags et
JOIN tags t ON et.tag_id = t.id
WHERE t.name ILIKE $1 
ORDER BY et.id;

-- name: UpdateEntityTag :one
UPDATE entity_tags SET
    entity_table = $2, entity_id = $3, tag_id = $4, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteEntityTag :exec
DELETE FROM entity_tags WHERE id = $1;

-- name: DeleteEntityTagsByEntity :exec
DELETE FROM entity_tags WHERE entity_table = $1 AND entity_id = $2;

-- name: DeleteEntityTagsByTag :exec
DELETE FROM entity_tags WHERE tag_id = $1;

-- name: GetEntityTagCount :one
SELECT COUNT(*) FROM entity_tags WHERE entity_table = $1 AND entity_id = $2;

-- name: GetEntityTagStats :many
SELECT 
    et.entity_table,
    COUNT(et.id) as tag_count
FROM entity_tags et
GROUP BY et.entity_table
ORDER BY et.entity_table;

-- name: GetTaggedEntities :many
SELECT 
    et.entity_table,
    et.entity_id,
    STRING_AGG(t.name, ', ') as tag_names,
    STRING_AGG(t.color, ', ') as tag_colors
FROM entity_tags et
JOIN tags t ON et.tag_id = t.id
WHERE et.entity_table = $1
GROUP BY et.entity_table, et.entity_id
ORDER BY et.entity_id;

-- name: GetPopularTags :many
SELECT 
    t.name as tag_name,
    t.color as tag_color,
    COUNT(et.id) as usage_count
FROM tags t
JOIN entity_tags et ON t.id = et.tag_id
WHERE t.is_active = $1
GROUP BY t.name, t.color, t.weight
ORDER BY usage_count DESC, t.weight, t.name
LIMIT $2;
