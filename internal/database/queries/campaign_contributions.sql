-- name: CreateCampaignContribution :one
INSERT INTO campaign_contributions (
    campaign_id, contribution_id, is_deleted
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: GetCampaignContribution :one
SELECT * FROM campaign_contributions WHERE id = $1 AND is_deleted = FALSE;

-- name: GetCampaignContributionsByCampaign :many
SELECT * FROM campaign_contributions 
WHERE campaign_id = $1 AND is_deleted = FALSE 
ORDER BY id DESC;

-- name: GetCampaignContributionsByContribution :one
SELECT * FROM campaign_contributions WHERE contribution_id = $1 AND is_deleted = FALSE;

-- name: GetCampaignContributionsWithDetails :many
SELECT 
    cc.*,
    co.contact_id,
    co.contribution_type,
    co.amount,
    co.currency,
    co.received_date,
    co.status,
    c.first_name, c.last_name
FROM campaign_contributions cc
JOIN contributions co ON cc.contribution_id = co.id
JOIN contacts c ON co.contact_id = c.id
WHERE cc.campaign_id = $1 AND cc.is_deleted = FALSE 
ORDER BY co.received_date DESC;

-- name: ListCampaignContributions :many
SELECT * FROM campaign_contributions 
WHERE is_deleted = FALSE 
ORDER BY id DESC;

-- name: ListCampaignContributionsByDateRange :many
SELECT cc.* FROM campaign_contributions cc
JOIN contributions co ON cc.contribution_id = co.id
WHERE co.received_date >= $1 AND co.received_date <= $2 
AND cc.is_deleted = FALSE 
ORDER BY co.received_date DESC;

-- name: ListCampaignContributionsByAmount :many
SELECT cc.* FROM campaign_contributions cc
JOIN contributions co ON cc.contribution_id = co.id
WHERE co.amount >= $1 AND co.amount <= $2 
AND cc.is_deleted = FALSE 
ORDER BY co.amount DESC;

-- name: SearchCampaignContributions :many
SELECT cc.* FROM campaign_contributions cc
JOIN contributions co ON cc.contribution_id = co.id
JOIN contacts c ON co.contact_id = c.id
WHERE (c.first_name ILIKE $1 OR c.last_name ILIKE $1 OR c.organization_name ILIKE $1) 
AND cc.is_deleted = FALSE 
ORDER BY co.received_date DESC;

-- name: UpdateCampaignContribution :one
UPDATE campaign_contributions SET
    campaign_id = $2, contribution_id = $3, is_deleted = $4, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCampaignContribution :exec
UPDATE campaign_contributions SET is_deleted = TRUE, updated_at = NOW() WHERE id = $1;

-- name: HardDeleteCampaignContribution :exec
DELETE FROM campaign_contributions WHERE id = $1;

-- name: GetCampaignContributionCount :one
SELECT COUNT(*) FROM campaign_contributions WHERE campaign_id = $1 AND is_deleted = FALSE;

-- name: GetCampaignContributionStats :many
SELECT 
    co.contribution_type,
    COUNT(cc.id) as contribution_count,
    SUM(co.amount) as total_amount
FROM campaign_contributions cc
JOIN contributions co ON cc.contribution_id = co.id
WHERE cc.campaign_id = $1 AND cc.is_deleted = FALSE
GROUP BY co.contribution_type
ORDER BY co.contribution_type;

-- name: GetCampaignRevenueSummary :many
SELECT 
    c.id as campaign_id,
    c.name as campaign_name,
    COUNT(cc.id) as contribution_count,
    SUM(co.amount) as total_revenue,
    AVG(co.amount) as average_contribution
FROM campaigns c
LEFT JOIN campaign_contributions cc ON c.id = cc.campaign_id AND cc.is_deleted = FALSE
LEFT JOIN contributions co ON cc.contribution_id = co.id
WHERE c.is_active = $1
GROUP BY c.id, c.name
ORDER BY c.start_date DESC;
