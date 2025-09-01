-- name: CreateMembershipType :one
INSERT INTO membership_types (
    name, description, member_of_contact_id, financial_type_id, minimum_fee,
    duration_unit, duration_interval, period_type, fixed_period_start_day,
    fixed_period_rollover_day, relationship_type_id, relationship_direction,
    visibility, weight, is_active, is_reserved
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16
) RETURNING *;

-- name: GetMembershipType :one
SELECT * FROM membership_types WHERE id = $1;

-- name: GetMembershipTypeByName :one
SELECT * FROM membership_types WHERE name = $1;

-- name: ListMembershipTypes :many
SELECT * FROM membership_types 
WHERE is_active = $1 
ORDER BY weight, name;

-- name: ListMembershipTypesByVisibility :many
SELECT * FROM membership_types 
WHERE visibility = $1 AND is_active = $2 
ORDER BY weight, name;

-- name: ListMembershipTypesByPeriodType :many
SELECT * FROM membership_types 
WHERE period_type = $1 AND is_active = $2 
ORDER BY weight, name;

-- name: SearchMembershipTypes :many
SELECT * FROM membership_types 
WHERE (name ILIKE $1 OR description ILIKE $1) 
AND is_active = $2 
ORDER BY weight, name;

-- name: UpdateMembershipType :one
UPDATE membership_types SET
    name = $2, description = $3, member_of_contact_id = $4, financial_type_id = $5,
    minimum_fee = $6, duration_unit = $7, duration_interval = $8, period_type = $9,
    fixed_period_start_day = $10, fixed_period_rollover_day = $11,
    relationship_type_id = $12, relationship_direction = $13, visibility = $14,
    weight = $15, is_active = $16, is_reserved = $17, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteMembershipType :exec
DELETE FROM membership_types WHERE id = $1;

-- name: ActivateMembershipType :exec
UPDATE membership_types SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateMembershipType :exec
UPDATE membership_types SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateMembershipTypeWeight :exec
UPDATE membership_types SET weight = $2, updated_at = NOW() WHERE id = $1;
