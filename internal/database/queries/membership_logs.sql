-- name: CreateMembershipLog :one
INSERT INTO membership_logs (
    membership_id, modified_date, modified_by_contact_id, status_id,
    start_date, end_date, membership_type_id, is_override,
    status_override_end_date, log_type, description
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
) RETURNING *;

-- name: GetMembershipLog :one
SELECT * FROM membership_logs WHERE id = $1;

-- name: GetMembershipLogsByMembership :many
SELECT * FROM membership_logs 
WHERE membership_id = $1 
ORDER BY modified_date DESC;

-- name: GetMembershipLogsByContact :many
SELECT ml.* FROM membership_logs ml
JOIN memberships m ON ml.membership_id = m.id
WHERE m.contact_id = $1 
ORDER BY ml.modified_date DESC;

-- name: ListMembershipLogs :many
SELECT * FROM membership_logs 
ORDER BY modified_date DESC;

-- name: ListMembershipLogsByType :many
SELECT * FROM membership_logs 
WHERE log_type = $1 
ORDER BY modified_date DESC;

-- name: ListMembershipLogsByStatus :many
SELECT * FROM membership_logs 
WHERE status_id = $1 
ORDER BY modified_date DESC;

-- name: ListMembershipLogsByDateRange :many
SELECT * FROM membership_logs 
WHERE modified_date >= $1 AND modified_date <= $2 
ORDER BY modified_date DESC;

-- name: ListMembershipLogsByModifier :many
SELECT * FROM membership_logs 
WHERE modified_by_contact_id = $1 
ORDER BY modified_date DESC;

-- name: SearchMembershipLogs :many
SELECT ml.* FROM membership_logs ml
JOIN memberships m ON ml.membership_id = m.id
JOIN contacts c ON m.contact_id = c.id
WHERE (c.first_name ILIKE $1 OR c.last_name ILIKE $1 OR c.organization_name ILIKE $1)
ORDER BY ml.modified_date DESC;

-- name: UpdateMembershipLog :one
UPDATE membership_logs SET
    membership_id = $2, modified_date = $3, modified_by_contact_id = $4,
    status_id = $5, start_date = $6, end_date = $7, membership_type_id = $8,
    is_override = $9, status_override_end_date = $10, log_type = $11,
    description = $12, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteMembershipLog :exec
DELETE FROM membership_logs WHERE id = $1;

-- name: GetMembershipAuditTrail :many
SELECT 
    ml.*,
    ms.name as status_name,
    mt.name as membership_type_name,
    c.first_name, c.last_name
FROM membership_logs ml
LEFT JOIN membership_status ms ON ml.status_id = ms.id
LEFT JOIN membership_types mt ON ml.membership_type_id = mt.id
LEFT JOIN contacts c ON ml.modified_by_contact_id = c.id
WHERE ml.membership_id = $1 
ORDER BY ml.modified_date DESC;

-- name: GetMembershipChangeSummary :many
SELECT 
    log_type,
    COUNT(*) as change_count,
    MIN(modified_date) as first_change,
    MAX(modified_date) as last_change
FROM membership_logs 
WHERE membership_id = $1
GROUP BY log_type
ORDER BY log_type;
