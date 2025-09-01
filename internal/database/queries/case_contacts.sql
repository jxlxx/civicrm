-- name: CreateCaseContact :one
INSERT INTO case_contacts (
    case_id, contact_id, role, start_date, end_date, is_active
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetCaseContact :one
SELECT * FROM case_contacts WHERE id = $1;

-- name: GetCaseContactsByCase :many
SELECT * FROM case_contacts 
WHERE case_id = $1 
ORDER BY start_date DESC;

-- name: GetCaseContactsByContact :many
SELECT * FROM case_contacts 
WHERE contact_id = $1 
ORDER BY start_date DESC;

-- name: GetCaseContactsByRole :many
SELECT * FROM case_contacts 
WHERE case_id = $1 AND role = $2 
ORDER BY start_date DESC;

-- name: GetActiveCaseContacts :many
SELECT * FROM case_contacts 
WHERE case_id = $1 AND is_active = TRUE 
ORDER BY start_date DESC;

-- name: GetCaseContactByCaseAndContact :one
SELECT * FROM case_contacts 
WHERE case_id = $1 AND contact_id = $2 
ORDER BY start_date DESC LIMIT 1;

-- name: ListCaseContacts :many
SELECT * FROM case_contacts 
ORDER BY start_date DESC;

-- name: ListCaseContactsByRole :many
SELECT * FROM case_contacts 
WHERE role = $1 
ORDER BY start_date DESC;

-- name: ListActiveCaseContacts :many
SELECT * FROM case_contacts 
WHERE is_active = TRUE 
ORDER BY start_date DESC;

-- name: ListCaseContactsByDateRange :many
SELECT * FROM case_contacts 
WHERE start_date >= $1 AND start_date <= $2 
ORDER BY start_date DESC;

-- name: SearchCaseContacts :many
SELECT cc.* FROM case_contacts cc
JOIN contacts c ON cc.contact_id = c.id
WHERE (c.first_name ILIKE $1 OR c.last_name ILIKE $1 OR c.organization_name ILIKE $1)
ORDER BY cc.start_date DESC;

-- name: UpdateCaseContact :one
UPDATE case_contacts SET
    case_id = $2, contact_id = $3, role = $4, start_date = $5,
    end_date = $6, is_active = $7, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCaseContact :exec
DELETE FROM case_contacts WHERE id = $1;

-- name: DeactivateCaseContact :exec
UPDATE case_contacts SET is_active = FALSE, end_date = NOW(), updated_at = NOW() WHERE id = $1;

-- name: ActivateCaseContact :exec
UPDATE case_contacts SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: UpdateCaseContactRole :exec
UPDATE case_contacts SET role = $2, updated_at = NOW() WHERE id = $1;

-- name: GetCaseContactStats :many
SELECT 
    cc.role,
    COUNT(*) as contact_count
FROM case_contacts cc
WHERE cc.is_active = $1
GROUP BY cc.role
ORDER BY cc.role;

-- name: GetCaseParticipantSummary :many
SELECT 
    c.id as case_id,
    c.subject as case_subject,
    COUNT(cc.id) as participant_count,
    STRING_AGG(cc.role, ', ') as roles
FROM cases c
LEFT JOIN case_contacts cc ON c.id = cc.case_id AND cc.is_active = TRUE
WHERE c.is_deleted = FALSE
GROUP BY c.id, c.subject
ORDER BY c.start_date DESC;
