-- name: CreateCase :one
INSERT INTO cases (
    case_type_id, subject, status_id, start_date, end_date, details, is_deleted
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetCase :one
SELECT * FROM cases WHERE id = $1 AND is_deleted = FALSE;

-- name: GetCaseWithDetails :one
SELECT 
    c.*,
    ct.name as case_type_name,
    ct.title as case_type_title,
    cs.name as status_name,
    cs.label as status_label,
    cs.grouping as status_grouping,
    cs.color as status_color
FROM cases c
JOIN case_types ct ON c.case_type_id = ct.id
JOIN case_status cs ON c.status_id = cs.id
WHERE c.id = $1 AND c.is_deleted = FALSE;

-- name: ListCases :many
SELECT * FROM cases 
WHERE is_deleted = FALSE 
ORDER BY start_date DESC;

-- name: ListCasesByType :many
SELECT * FROM cases 
WHERE case_type_id = $1 AND is_deleted = FALSE 
ORDER BY start_date DESC;

-- name: ListCasesByStatus :many
SELECT * FROM cases 
WHERE status_id = $1 AND is_deleted = FALSE 
ORDER BY start_date DESC;

-- name: ListCasesByStatusGrouping :many
SELECT c.* FROM cases c
JOIN case_status cs ON c.status_id = cs.id
WHERE cs.grouping = $1 AND c.is_deleted = FALSE 
ORDER BY c.start_date DESC;

-- name: ListOpenCases :many
SELECT c.* FROM cases c
JOIN case_status cs ON c.status_id = cs.id
WHERE cs.grouping = 'Open' AND c.is_deleted = FALSE 
ORDER BY c.start_date DESC;

-- name: ListClosedCases :many
SELECT c.* FROM cases c
JOIN case_status cs ON c.status_id = cs.id
WHERE cs.grouping = 'Closed' AND c.is_deleted = FALSE 
ORDER BY c.start_date DESC;

-- name: ListCasesByDateRange :many
SELECT * FROM cases 
WHERE start_date >= $1 AND start_date <= $2 AND is_deleted = FALSE 
ORDER BY start_date DESC;

-- name: ListCasesByContact :many
SELECT c.* FROM cases c
JOIN case_contacts cc ON c.id = cc.case_id
WHERE cc.contact_id = $1 AND c.is_deleted = FALSE 
ORDER BY c.start_date DESC;

-- name: ListCasesByContactRole :many
SELECT c.* FROM cases c
JOIN case_contacts cc ON c.id = cc.case_id
WHERE cc.contact_id = $1 AND cc.role = $2 AND c.is_deleted = FALSE 
ORDER BY c.start_date DESC;

-- name: SearchCases :many
SELECT c.* FROM cases c
JOIN case_types ct ON c.case_type_id = ct.id
WHERE (c.subject ILIKE $1 OR c.details ILIKE $1 OR ct.name ILIKE $1) 
AND c.is_deleted = FALSE 
ORDER BY c.start_date DESC;

-- name: UpdateCase :one
UPDATE cases SET
    case_type_id = $2, subject = $3, status_id = $4, start_date = $5,
    end_date = $6, details = $7, is_deleted = $8, modified_date = NOW(),
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCase :exec
UPDATE cases SET is_deleted = TRUE, modified_date = NOW(), updated_at = NOW() WHERE id = $1;

-- name: HardDeleteCase :exec
DELETE FROM cases WHERE id = $1;

-- name: UpdateCaseStatusById :exec
UPDATE cases SET status_id = $2, modified_date = NOW(), updated_at = NOW() WHERE id = $1;

-- name: CloseCase :exec
UPDATE cases SET 
    status_id = (SELECT cs.id FROM case_status cs WHERE cs.grouping = 'Closed' AND cs.name = 'Closed' LIMIT 1),
    end_date = $2, modified_date = NOW(), updated_at = NOW() 
WHERE cases.id = $1;

-- name: GetCaseCount :one
SELECT COUNT(*) FROM cases WHERE is_deleted = FALSE;

-- name: GetCaseStats :many
SELECT 
    ct.name as case_type,
    cs.grouping as status_grouping,
    cs.name as status,
    COUNT(c.id) as case_count
FROM case_types ct
CROSS JOIN case_status cs
LEFT JOIN cases c ON ct.id = c.case_type_id AND cs.id = c.status_id AND c.is_deleted = FALSE
WHERE ct.is_active = $1 AND cs.is_active = $1
GROUP BY ct.name, cs.grouping, cs.name, ct.weight, cs.weight
ORDER BY ct.weight, ct.name, cs.weight, cs.name;
