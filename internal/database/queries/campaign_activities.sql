-- name: CreateCampaignActivity :one
INSERT INTO campaign_activities (
    campaign_id, activity_id, is_deleted
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: GetCampaignActivity :one
SELECT * FROM campaign_activities WHERE id = $1 AND is_deleted = FALSE;

-- name: GetCampaignActivitiesByCampaign :many
SELECT * FROM campaign_activities 
WHERE campaign_id = $1 AND is_deleted = FALSE 
ORDER BY id DESC;

-- name: GetCampaignActivitiesByActivity :one
SELECT * FROM campaign_activities WHERE activity_id = $1 AND is_deleted = FALSE;

-- name: GetCampaignActivitiesWithDetails :many
SELECT 
    ca.*,
    a.activity_type_id,
    a.subject,
    a.activity_date_time,
    a.duration,
    a.location,
    a.details,
    at.name as activity_type_name
FROM campaign_activities ca
JOIN activities a ON ca.activity_id = a.id
JOIN activity_types at ON a.activity_type_id = at.id
WHERE ca.campaign_id = $1 AND ca.is_deleted = FALSE 
ORDER BY a.activity_date_time DESC;

-- name: ListCampaignActivities :many
SELECT * FROM campaign_activities 
WHERE is_deleted = FALSE 
ORDER BY id DESC;

-- name: ListCampaignActivitiesByType :many
SELECT ca.* FROM campaign_activities ca
JOIN activities a ON ca.activity_id = a.id
WHERE a.activity_type_id = $1 AND ca.is_deleted = FALSE 
ORDER BY a.activity_date_time DESC;

-- name: ListCampaignActivitiesByDateRange :many
SELECT ca.* FROM campaign_activities ca
JOIN activities a ON ca.activity_id = a.id
WHERE a.activity_date_time >= $1 AND a.activity_date_time <= $2 
AND ca.is_deleted = FALSE 
ORDER BY a.activity_date_time DESC;

-- name: SearchCampaignActivities :many
SELECT ca.* FROM campaign_activities ca
JOIN activities a ON ca.activity_id = a.id
WHERE (a.subject ILIKE $1 OR a.details ILIKE $1) 
AND ca.is_deleted = FALSE 
ORDER BY a.activity_date_time DESC;

-- name: UpdateCampaignActivity :one
UPDATE campaign_activities SET
    campaign_id = $2, activity_id = $3, is_deleted = $4, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCampaignActivity :exec
UPDATE campaign_activities SET is_deleted = TRUE, updated_at = NOW() WHERE id = $1;

-- name: HardDeleteCampaignActivity :exec
DELETE FROM campaign_activities WHERE id = $1;

-- name: GetCampaignActivityCount :one
SELECT COUNT(*) FROM campaign_activities WHERE campaign_id = $1 AND is_deleted = FALSE;

-- name: GetCampaignActivityStats :many
SELECT 
    at.name as activity_type,
    COUNT(ca.id) as activity_count
FROM campaign_activities ca
JOIN activities a ON ca.activity_id = a.id
JOIN activity_types at ON a.activity_type_id = at.id
WHERE ca.campaign_id = $1 AND ca.is_deleted = FALSE
GROUP BY at.name
ORDER BY at.name;

-- name: GetCampaignTimeline :many
SELECT 
    ca.id as campaign_activity_id,
    a.activity_date_time,
    a.subject,
    a.details,
    at.name as activity_type,
    c.first_name, c.last_name
FROM campaign_activities ca
JOIN activities a ON ca.activity_id = a.id
JOIN activity_types at ON a.activity_type_id = at.id
LEFT JOIN activity_contacts ac ON a.id = ac.activity_id AND ac.record_type = 'Activity'
LEFT JOIN contacts c ON ac.contact_id = c.id
WHERE ca.campaign_id = $1 AND ca.is_deleted = FALSE
ORDER BY a.activity_date_time DESC;
