-- name: CreateMembership :one
INSERT INTO memberships (
    contact_id, membership_type_id, status_id, join_date, start_date, end_date,
    source, is_override, status_override_end_date, is_pay_later, contribution_id,
    campaign_id, is_test, num_terms, max_related_contacts
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15
) RETURNING *;

-- name: GetMembership :one
SELECT * FROM memberships WHERE id = $1;

-- name: GetMembershipByContact :many
SELECT * FROM memberships WHERE contact_id = $1 ORDER BY start_date DESC;

-- name: GetActiveMembershipByContact :one
SELECT * FROM memberships 
WHERE contact_id = $1 AND status_id IN (
    SELECT id FROM membership_status WHERE is_current_member = TRUE
) ORDER BY start_date DESC LIMIT 1;

-- name: ListMemberships :many
SELECT * FROM memberships 
WHERE is_test = $1 
ORDER BY start_date DESC;

-- name: ListMembershipsByType :many
SELECT * FROM memberships 
WHERE membership_type_id = $1 AND is_test = $2 
ORDER BY start_date DESC;

-- name: ListMembershipsByStatus :many
SELECT * FROM memberships 
WHERE status_id = $1 AND is_test = $2 
ORDER BY start_date DESC;

-- name: ListMembershipsByDateRange :many
SELECT * FROM memberships 
WHERE start_date >= $1 AND start_date <= $2 AND is_test = $3 
ORDER BY start_date DESC;

-- name: ListExpiringMemberships :many
SELECT * FROM memberships 
WHERE end_date >= $1 AND end_date <= $2 AND is_test = $3 
ORDER BY end_date ASC;

-- name: ListMembershipsByCampaign :many
SELECT * FROM memberships 
WHERE campaign_id = $1 AND is_test = $2 
ORDER BY start_date DESC;

-- name: SearchMemberships :many
SELECT m.* FROM memberships m
JOIN contacts c ON m.contact_id = c.id
WHERE (c.first_name ILIKE $1 OR c.last_name ILIKE $1 OR c.organization_name ILIKE $1)
AND m.is_test = $2 
ORDER BY m.start_date DESC;

-- name: UpdateMembership :one
UPDATE memberships SET
    contact_id = $2, membership_type_id = $3, status_id = $4, join_date = $5,
    start_date = $6, end_date = $7, source = $8, is_override = $9,
    status_override_end_date = $10, is_pay_later = $11, contribution_id = $12,
    campaign_id = $13, is_test = $14, num_terms = $15, max_related_contacts = $16,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteMembership :exec
DELETE FROM memberships WHERE id = $1;

-- name: UpdateMembershipStatusById :exec
UPDATE memberships SET status_id = $2, updated_at = NOW() WHERE id = $1;

-- name: ExtendMembership :exec
UPDATE memberships SET end_date = $2, updated_at = NOW() WHERE id = $1;

-- name: GetMembershipCount :one
SELECT COUNT(*) FROM memberships WHERE contact_id = $1 AND is_test = $2;

-- name: GetMembershipStats :many
SELECT 
    mt.name as membership_type,
    ms.name as status,
    COUNT(*) as count
FROM memberships m
JOIN membership_types mt ON m.membership_type_id = mt.id
JOIN membership_status ms ON m.status_id = ms.id
WHERE m.is_test = $1
GROUP BY mt.name, ms.name
ORDER BY mt.name, ms.name;
