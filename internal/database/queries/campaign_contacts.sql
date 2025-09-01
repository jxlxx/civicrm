-- name: CreateCampaignContact :one
INSERT INTO campaign_contacts (
    campaign_id, contact_id, role, status, join_date, end_date, is_active
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetCampaignContact :one
SELECT * FROM campaign_contacts WHERE id = $1;

-- name: GetCampaignContactsByCampaign :many
SELECT * FROM campaign_contacts 
WHERE campaign_id = $1 
ORDER BY join_date DESC;

-- name: GetCampaignContactsByContact :many
SELECT * FROM campaign_contacts 
WHERE contact_id = $1 
ORDER BY join_date DESC;

-- name: GetCampaignContactsByRole :many
SELECT * FROM campaign_contacts 
WHERE campaign_id = $1 AND role = $2 
ORDER BY join_date DESC;

-- name: GetCampaignContactsByStatus :many
SELECT * FROM campaign_contacts 
WHERE campaign_id = $1 AND status = $2 
ORDER BY join_date DESC;

-- name: GetActiveCampaignContacts :many
SELECT * FROM campaign_contacts 
WHERE campaign_id = $1 AND is_active = TRUE 
ORDER BY join_date DESC;

-- name: GetCampaignContactByCampaignAndContact :one
SELECT * FROM campaign_contacts 
WHERE campaign_id = $1 AND contact_id = $2 
ORDER BY join_date DESC LIMIT 1;

-- name: ListCampaignContacts :many
SELECT * FROM campaign_contacts 
ORDER BY join_date DESC;

-- name: ListCampaignContactsByRole :many
SELECT * FROM campaign_contacts 
WHERE role = $1 
ORDER BY join_date DESC;

-- name: ListCampaignContactsByStatus :many
SELECT * FROM campaign_contacts 
WHERE status = $1 
ORDER BY join_date DESC;

-- name: ListActiveCampaignContacts :many
SELECT * FROM campaign_contacts 
WHERE is_active = TRUE 
ORDER BY join_date DESC;

-- name: ListCampaignContactsByDateRange :many
SELECT * FROM campaign_contacts 
WHERE join_date >= $1 AND join_date <= $2 
ORDER BY join_date DESC;

-- name: SearchCampaignContacts :many
SELECT cc.* FROM campaign_contacts cc
JOIN contacts c ON cc.contact_id = c.id
WHERE (c.first_name ILIKE $1 OR c.last_name ILIKE $1 OR c.organization_name ILIKE $1)
ORDER BY cc.join_date DESC;

-- name: UpdateCampaignContact :one
UPDATE campaign_contacts SET
    campaign_id = $2, contact_id = $3, role = $4, status = $5,
    join_date = $6, end_date = $7, is_active = $8, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCampaignContact :exec
DELETE FROM campaign_contacts WHERE id = $1;

-- name: DeactivateCampaignContact :exec
UPDATE campaign_contacts SET is_active = FALSE, end_date = NOW(), updated_at = NOW() WHERE id = $1;

-- name: ActivateCampaignContact :exec
UPDATE campaign_contacts SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: UpdateCampaignContactRole :exec
UPDATE campaign_contacts SET role = $2, updated_at = NOW() WHERE id = $1;

-- name: UpdateCampaignContactStatus :exec
UPDATE campaign_contacts SET status = $2, updated_at = NOW() WHERE id = $1;

-- name: GetCampaignContactStats :many
SELECT 
    cc.role,
    cc.status,
    COUNT(*) as contact_count
FROM campaign_contacts cc
WHERE cc.is_active = $1
GROUP BY cc.role, cc.status
ORDER BY cc.role, cc.status;

-- name: GetCampaignParticipantSummary :many
SELECT 
    c.id as campaign_id,
    c.name as campaign_name,
    COUNT(cc.id) as participant_count,
    STRING_AGG(DISTINCT cc.role, ', ') as roles
FROM campaigns c
LEFT JOIN campaign_contacts cc ON c.id = cc.campaign_id AND cc.is_active = TRUE
WHERE c.is_active = $1
GROUP BY c.id, c.name
ORDER BY c.start_date DESC;
