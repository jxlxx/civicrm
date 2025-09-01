-- name: CreateCampaign :one
INSERT INTO campaigns (
    name, title, description, campaign_type_id, status_id, parent_id,
    is_active, start_date, end_date, goal_revenue, goal_contacts,
    actual_revenue, actual_contacts, external_identifier
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
) RETURNING *;

-- name: GetCampaign :one
SELECT * FROM campaigns WHERE id = $1;

-- name: GetCampaignByName :one
SELECT * FROM campaigns WHERE name = $1;

-- name: GetCampaignByExternalId :one
SELECT * FROM campaigns WHERE external_identifier = $1;

-- name: GetCampaignsByParent :many
SELECT * FROM campaigns WHERE parent_id = $1 ORDER BY start_date DESC;

-- name: GetCampaignsByType :many
SELECT * FROM campaigns WHERE campaign_type_id = $1 ORDER BY start_date DESC;

-- name: GetCampaignsByStatus :many
SELECT * FROM campaigns WHERE status_id = $1 ORDER BY start_date DESC;

-- name: ListCampaigns :many
SELECT * FROM campaigns ORDER BY start_date DESC;

-- name: ListActiveCampaigns :many
SELECT * FROM campaigns WHERE is_active = TRUE ORDER BY start_date DESC;

-- name: ListCampaignsByDateRange :many
SELECT * FROM campaigns 
WHERE start_date >= $1 AND start_date <= $2 
ORDER BY start_date DESC;

-- name: ListExpiringCampaigns :many
SELECT * FROM campaigns 
WHERE end_date >= $1 AND end_date <= $2 
ORDER BY end_date ASC;

-- name: ListCampaignsByGoal :many
SELECT * FROM campaigns 
WHERE goal_revenue >= $1 AND goal_revenue <= $2 
ORDER BY goal_revenue DESC;

-- name: SearchCampaigns :many
SELECT * FROM campaigns 
WHERE (name ILIKE $1 OR title ILIKE $1 OR description ILIKE $1) 
ORDER BY start_date DESC;

-- name: UpdateCampaign :one
UPDATE campaigns SET
    name = $2, title = $3, description = $4, campaign_type_id = $5,
    status_id = $6, parent_id = $7, is_active = $8, start_date = $9,
    end_date = $10, goal_revenue = $11, goal_contacts = $12,
    actual_revenue = $13, actual_contacts = $14, external_identifier = $15,
    modified_date = NOW(), updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCampaign :exec
DELETE FROM campaigns WHERE id = $1;

-- name: ActivateCampaign :exec
UPDATE campaigns SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateCampaign :exec
UPDATE campaigns SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateCampaignStatusById :exec
UPDATE campaigns SET status_id = $2, updated_at = NOW() WHERE id = $1;

-- name: UpdateCampaignRevenue :exec
UPDATE campaigns SET actual_revenue = $2, updated_at = NOW() WHERE id = $1;

-- name: UpdateCampaignContacts :exec
UPDATE campaigns SET actual_contacts = $2, updated_at = NOW() WHERE id = $1;

-- name: GetCampaignStats :many
SELECT 
    ct.name as campaign_type,
    cs.grouping as status_grouping,
    cs.name as status,
    COUNT(c.id) as campaign_count,
    SUM(c.goal_revenue) as total_goal_revenue,
    SUM(c.actual_revenue) as total_actual_revenue
FROM campaigns c
LEFT JOIN campaign_types ct ON c.campaign_type_id = ct.id
LEFT JOIN campaign_status cs ON c.status_id = cs.id
WHERE c.is_active = $1
GROUP BY ct.name, cs.grouping, cs.name, ct.weight, cs.weight
ORDER BY ct.weight, ct.name, cs.weight, cs.name;

-- name: GetCampaignHierarchy :many
WITH RECURSIVE campaign_tree AS (
    SELECT id, name, title, parent_id, 0 as level
    FROM campaigns 
    WHERE parent_id IS NULL AND is_active = TRUE
    UNION ALL
    SELECT c.id, c.name, c.title, c.parent_id, ct.level + 1
    FROM campaigns c
    JOIN campaign_tree ct ON c.parent_id = ct.id
    WHERE c.is_active = TRUE
)
SELECT * FROM campaign_tree ORDER BY level, name;
