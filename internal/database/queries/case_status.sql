-- name: CreateCaseStatus :one
INSERT INTO case_status (
    name, label, grouping, weight, is_active, is_reserved, color
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetCaseStatus :one
SELECT * FROM case_status WHERE id = $1;

-- name: GetCaseStatusByName :one
SELECT * FROM case_status WHERE name = $1;

-- name: ListCaseStatus :many
SELECT * FROM case_status 
WHERE is_active = $1 
ORDER BY weight, name;

-- name: ListActiveCaseStatus :many
SELECT * FROM case_status 
WHERE is_active = TRUE 
ORDER BY weight, name;

-- name: ListCaseStatusByGrouping :many
SELECT * FROM case_status 
WHERE grouping = $1 AND is_active = $2 
ORDER BY weight, name;

-- name: ListOpenCaseStatus :many
SELECT * FROM case_status 
WHERE grouping = 'Open' AND is_active = $1 
ORDER BY weight, name;

-- name: ListClosedCaseStatus :many
SELECT * FROM case_status 
WHERE grouping = 'Closed' AND is_active = $1 
ORDER BY weight, name;

-- name: ListReservedCaseStatus :many
SELECT * FROM case_status 
WHERE is_reserved = TRUE AND is_active = $1 
ORDER BY weight, name;

-- name: SearchCaseStatus :many
SELECT * FROM case_status 
WHERE (name ILIKE $1 OR label ILIKE $1) 
AND is_active = $2 
ORDER BY weight, name;

-- name: UpdateCaseStatus :one
UPDATE case_status SET
    name = $2, label = $3, grouping = $4, weight = $5,
    is_active = $6, is_reserved = $7, color = $8, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCaseStatus :exec
DELETE FROM case_status WHERE id = $1;

-- name: ActivateCaseStatus :exec
UPDATE case_status SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateCaseStatus :exec
UPDATE case_status SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateCaseStatusWeight :exec
UPDATE case_status SET weight = $2, updated_at = NOW() WHERE id = $1;

-- name: GetCaseStatusStats :many
SELECT 
    cs.grouping,
    cs.name as status,
    COUNT(c.id) as case_count
FROM case_status cs
LEFT JOIN cases c ON cs.id = c.status_id AND c.is_deleted = FALSE
WHERE cs.is_active = $1
GROUP BY cs.grouping, cs.name, cs.weight
ORDER BY cs.grouping, cs.weight, cs.name;
