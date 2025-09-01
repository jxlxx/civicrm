-- name: CreateActivityType :one
INSERT INTO activity_types (
    name, label, description, icon, is_active, is_reserved,
    is_target, is_multi_record, is_component
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetActivityType :one
SELECT * FROM activity_types WHERE id = $1;

-- name: GetActivityTypeByName :one
SELECT * FROM activity_types WHERE name = $1;

-- name: GetActivityTypeByLabel :one
SELECT * FROM activity_types WHERE label = $1;

-- name: ListActivityTypes :many
SELECT * FROM activity_types 
ORDER BY name;

-- name: ListActiveActivityTypes :many
SELECT * FROM activity_types 
WHERE is_active = TRUE
ORDER BY name;

-- name: ListReservedActivityTypes :many
SELECT * FROM activity_types 
WHERE is_reserved = TRUE
ORDER BY name;

-- name: ListTargetActivityTypes :many
SELECT * FROM activity_types 
WHERE is_target = TRUE AND is_active = TRUE
ORDER BY name;

-- name: ListMultiRecordActivityTypes :many
SELECT * FROM activity_types 
WHERE is_multi_record = TRUE AND is_active = TRUE
ORDER BY name;

-- name: SearchActivityTypes :many
SELECT * FROM activity_types 
WHERE (name ILIKE $1 OR label ILIKE $1 OR description ILIKE $1)
ORDER BY name;

-- name: UpdateActivityType :one
UPDATE activity_types SET
    name = $2, label = $3, description = $4, icon = $5, is_active = $6,
    is_reserved = $7, is_target = $8, is_multi_record = $9, is_component = $10,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteActivityType :exec
DELETE FROM activity_types WHERE id = $1;

-- name: CountActivityTypes :one
SELECT COUNT(*) FROM activity_types;

-- name: CountActiveActivityTypes :one
SELECT COUNT(*) FROM activity_types WHERE is_active = TRUE;

-- name: CountReservedActivityTypes :one
SELECT COUNT(*) FROM activity_types WHERE is_reserved = TRUE;
