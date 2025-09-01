-- name: CreateCaseType :one
INSERT INTO case_types (
    name, title, description, is_active, is_reserved, weight, definition
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetCaseType :one
SELECT * FROM case_types WHERE id = $1;

-- name: GetCaseTypeByName :one
SELECT * FROM case_types WHERE name = $1;

-- name: ListCaseTypes :many
SELECT * FROM case_types 
WHERE is_active = $1 
ORDER BY weight, name;

-- name: ListActiveCaseTypes :many
SELECT * FROM case_types 
WHERE is_active = TRUE 
ORDER BY weight, name;

-- name: ListReservedCaseTypes :many
SELECT * FROM case_types 
WHERE is_reserved = TRUE AND is_active = $1 
ORDER BY weight, name;

-- name: SearchCaseTypes :many
SELECT * FROM case_types 
WHERE (name ILIKE $1 OR title ILIKE $1 OR description ILIKE $1) 
AND is_active = $2 
ORDER BY weight, name;

-- name: UpdateCaseType :one
UPDATE case_types SET
    name = $2, title = $3, description = $4, is_active = $5,
    is_reserved = $6, weight = $7, definition = $8, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCaseType :exec
DELETE FROM case_types WHERE id = $1;

-- name: ActivateCaseType :exec
UPDATE case_types SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateCaseType :exec
UPDATE case_types SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateCaseTypeWeight :exec
UPDATE case_types SET weight = $2, updated_at = NOW() WHERE id = $1;

-- name: GetCaseTypeStats :many
SELECT 
    ct.name as case_type,
    COUNT(c.id) as case_count
FROM case_types ct
LEFT JOIN cases c ON ct.id = c.case_type_id AND c.is_deleted = FALSE
WHERE ct.is_active = $1
GROUP BY ct.name, ct.weight
ORDER BY ct.weight, ct.name;
