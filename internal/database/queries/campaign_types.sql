-- name: CreateCampaignType :one
INSERT INTO campaign_types (
    name, label, description, is_active, is_reserved, weight
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetCampaignType :one
SELECT * FROM campaign_types WHERE id = $1;

-- name: GetCampaignTypeByName :one
SELECT * FROM campaign_types WHERE name = $1;

-- name: ListCampaignTypes :many
SELECT * FROM campaign_types 
WHERE is_active = $1 
ORDER BY weight, name;

-- name: ListActiveCampaignTypes :many
SELECT * FROM campaign_types 
WHERE is_active = TRUE 
ORDER BY weight, name;

-- name: ListReservedCampaignTypes :many
SELECT * FROM campaign_types 
WHERE is_reserved = TRUE AND is_active = $1 
ORDER BY weight, name;

-- name: SearchCampaignTypes :many
SELECT * FROM campaign_types 
WHERE (name ILIKE $1 OR label ILIKE $1 OR description ILIKE $1) 
AND is_active = $2 
ORDER BY weight, name;

-- name: UpdateCampaignType :one
UPDATE campaign_types SET
    name = $2, label = $3, description = $4, is_active = $5,
    is_reserved = $6, weight = $7, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCampaignType :exec
DELETE FROM campaign_types WHERE id = $1;

-- name: ActivateCampaignType :exec
UPDATE campaign_types SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateCampaignType :exec
UPDATE campaign_types SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateCampaignTypeWeight :exec
UPDATE campaign_types SET weight = $2, updated_at = NOW() WHERE id = $1;

-- name: GetCampaignTypeStats :many
SELECT 
    ct.name as campaign_type,
    COUNT(c.id) as campaign_count
FROM campaign_types ct
LEFT JOIN campaigns c ON ct.id = c.campaign_type_id AND c.is_active = TRUE
WHERE ct.is_active = $1
GROUP BY ct.name, ct.weight
ORDER BY ct.weight, ct.name;
