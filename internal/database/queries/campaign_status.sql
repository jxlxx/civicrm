-- name: CreateCampaignStatus :one
INSERT INTO campaign_status (
    name, label, grouping, weight, is_active, is_reserved, color
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetCampaignStatus :one
SELECT * FROM campaign_status WHERE id = $1;

-- name: GetCampaignStatusByName :one
SELECT * FROM campaign_status WHERE name = $1;

-- name: ListCampaignStatus :many
SELECT * FROM campaign_status 
WHERE is_active = $1 
ORDER BY weight, name;

-- name: ListActiveCampaignStatus :many
SELECT * FROM campaign_status 
WHERE is_active = TRUE 
ORDER BY weight, name;

-- name: ListCampaignStatusByGrouping :many
SELECT * FROM campaign_status 
WHERE grouping = $1 AND is_active = $2 
ORDER BY weight, name;

-- name: ListPlannedCampaignStatus :many
SELECT * FROM campaign_status 
WHERE grouping = 'Planned' AND is_active = $1 
ORDER BY weight, name;

-- name: ListActiveCampaignStatuses :many
SELECT * FROM campaign_status 
WHERE grouping = 'Active' AND is_active = $1 
ORDER BY weight, name;

-- name: ListCompletedCampaignStatus :many
SELECT * FROM campaign_status 
WHERE grouping = 'Completed' AND is_active = $1 
ORDER BY weight, name;

-- name: ListCancelledCampaignStatus :many
SELECT * FROM campaign_status 
WHERE grouping = 'Cancelled' AND is_active = $1 
ORDER BY weight, name;

-- name: ListReservedCampaignStatus :many
SELECT * FROM campaign_status 
WHERE is_reserved = TRUE AND is_active = $1 
ORDER BY weight, name;

-- name: SearchCampaignStatus :many
SELECT * FROM campaign_status 
WHERE (name ILIKE $1 OR label ILIKE $1) 
AND is_active = $2 
ORDER BY weight, name;

-- name: UpdateCampaignStatus :one
UPDATE campaign_status SET
    name = $2, label = $3, grouping = $4, weight = $5,
    is_active = $6, is_reserved = $7, color = $8, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCampaignStatus :exec
DELETE FROM campaign_status WHERE id = $1;

-- name: ActivateCampaignStatus :exec
UPDATE campaign_status SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateCampaignStatus :exec
UPDATE campaign_status SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateCampaignStatusWeight :exec
UPDATE campaign_status SET weight = $2, updated_at = NOW() WHERE id = $1;

-- name: GetCampaignStatusStats :many
SELECT 
    cs.grouping,
    cs.name as status,
    COUNT(c.id) as campaign_count
FROM campaign_status cs
LEFT JOIN campaigns c ON cs.id = c.status_id AND c.is_active = TRUE
WHERE cs.is_active = $1
GROUP BY cs.grouping, cs.name, cs.weight
ORDER BY cs.grouping, cs.weight, cs.name;
