-- name: CreateMembershipStatus :one
INSERT INTO membership_status (
    name, label, start_event, end_event, is_current_member,
    is_admin, weight, is_active, is_reserved
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetMembershipStatus :one
SELECT * FROM membership_status WHERE id = $1;

-- name: GetMembershipStatusByName :one
SELECT * FROM membership_status WHERE name = $1;

-- name: ListMembershipStatus :many
SELECT * FROM membership_status 
WHERE is_active = $1 
ORDER BY weight, name;

-- name: ListCurrentMemberStatuses :many
SELECT * FROM membership_status 
WHERE is_current_member = TRUE AND is_active = $1 
ORDER BY weight, name;

-- name: ListAdminStatuses :many
SELECT * FROM membership_status 
WHERE is_admin = TRUE AND is_active = $1 
ORDER BY weight, name;

-- name: ListMembershipStatusByEvent :many
SELECT * FROM membership_status 
WHERE (start_event = $1 OR end_event = $1) AND is_active = $2 
ORDER BY weight, name;

-- name: SearchMembershipStatus :many
SELECT * FROM membership_status 
WHERE (name ILIKE $1 OR label ILIKE $1) 
AND is_active = $2 
ORDER BY weight, name;

-- name: UpdateMembershipStatus :one
UPDATE membership_status SET
    name = $2, label = $3, start_event = $4, end_event = $5,
    is_current_member = $6, is_admin = $7, weight = $8, 
    is_active = $9, is_reserved = $10, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteMembershipStatus :exec
DELETE FROM membership_status WHERE id = $1;

-- name: ActivateMembershipStatus :exec
UPDATE membership_status SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateMembershipStatus :exec
UPDATE membership_status SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateMembershipStatusWeight :exec
UPDATE membership_status SET weight = $2, updated_at = NOW() WHERE id = $1;
