-- name: CreateCampaignGroup :one
INSERT INTO campaign_groups (
    campaign_id, group_id, is_active
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: GetCampaignGroup :one
SELECT * FROM campaign_groups WHERE id = $1;

-- name: GetCampaignGroupsByCampaign :many
SELECT * FROM campaign_groups 
WHERE campaign_id = $1 
ORDER BY id;

-- name: GetCampaignGroupsByGroup :many
SELECT * FROM campaign_groups 
WHERE group_id = $1 
ORDER BY id;

-- name: GetActiveCampaignGroups :many
SELECT * FROM campaign_groups 
WHERE campaign_id = $1 AND is_active = TRUE 
ORDER BY id;

-- name: GetCampaignGroupByCampaignAndGroup :one
SELECT * FROM campaign_groups 
WHERE campaign_id = $1 AND group_id = $2 
ORDER BY id LIMIT 1;

-- name: ListCampaignGroups :many
SELECT * FROM campaign_groups 
ORDER BY id;

-- name: ListActiveCampaignGroups :many
SELECT * FROM campaign_groups 
WHERE is_active = TRUE 
ORDER BY id;

-- name: SearchCampaignGroups :many
SELECT cg.* FROM campaign_groups cg
JOIN groups g ON cg.group_id = g.id
WHERE g.title ILIKE $1
ORDER BY cg.id;

-- name: UpdateCampaignGroup :one
UPDATE campaign_groups SET
    campaign_id = $2, group_id = $3, is_active = $4, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCampaignGroup :exec
DELETE FROM campaign_groups WHERE id = $1;

-- name: DeactivateCampaignGroup :exec
UPDATE campaign_groups SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: ActivateCampaignGroup :exec
UPDATE campaign_groups SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: GetCampaignGroupStats :many
SELECT 
    g.title as group_name,
    COUNT(cg.id) as campaign_count
FROM campaign_groups cg
JOIN groups g ON cg.group_id = g.id
WHERE cg.is_active = $1
GROUP BY g.title
ORDER BY g.title;

-- name: GetCampaignTargetAudience :many
SELECT 
    c.id as campaign_id,
    c.name as campaign_name,
    COUNT(cg.id) as group_count,
    STRING_AGG(g.title, ', ') as target_groups
FROM campaigns c
LEFT JOIN campaign_groups cg ON c.id = cg.campaign_id AND cg.is_active = TRUE
LEFT JOIN groups g ON cg.group_id = g.id
WHERE c.is_active = $1
GROUP BY c.id, c.name
ORDER BY c.start_date DESC;
