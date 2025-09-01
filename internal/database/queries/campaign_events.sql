-- name: CreateCampaignEvent :one
INSERT INTO campaign_events (
    campaign_id, event_id, is_deleted
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: GetCampaignEvent :one
SELECT * FROM campaign_events WHERE id = $1 AND is_deleted = FALSE;

-- name: GetCampaignEventsByCampaign :many
SELECT * FROM campaign_events 
WHERE campaign_id = $1 AND is_deleted = FALSE 
ORDER BY id DESC;

-- name: GetCampaignEventsByEvent :one
SELECT * FROM campaign_events WHERE event_id = $1 AND is_deleted = FALSE;

-- name: GetCampaignEventsWithDetails :many
SELECT 
    ce.*,
    e.title as event_title,
    e.description as event_description,
    e.start_date,
    e.end_date
FROM campaign_events ce
JOIN events e ON ce.event_id = e.id
WHERE ce.campaign_id = $1 AND ce.is_deleted = FALSE 
ORDER BY e.start_date DESC;

-- name: ListCampaignEvents :many
SELECT * FROM campaign_events 
WHERE is_deleted = FALSE 
ORDER BY id DESC;

-- name: ListCampaignEventsByDateRange :many
SELECT ce.* FROM campaign_events ce
JOIN events e ON ce.event_id = e.id
WHERE e.start_date >= $1 AND e.start_date <= $2 
AND ce.is_deleted = FALSE 
ORDER BY e.start_date DESC;

-- name: ListCampaignEventsByType :many
SELECT ce.* FROM campaign_events ce
JOIN events e ON ce.event_id = e.id
WHERE ce.is_deleted = FALSE 
ORDER BY e.start_date DESC;

-- name: SearchCampaignEvents :many
SELECT ce.* FROM campaign_events ce
JOIN events e ON ce.event_id = e.id
WHERE (e.title ILIKE $1 OR e.description ILIKE $1) 
AND ce.is_deleted = FALSE 
ORDER BY e.start_date DESC;

-- name: UpdateCampaignEvent :one
UPDATE campaign_events SET
    campaign_id = $2, event_id = $3, is_deleted = $4, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCampaignEvent :exec
UPDATE campaign_events SET is_deleted = TRUE, updated_at = NOW() WHERE id = $1;

-- name: HardDeleteCampaignEvent :exec
DELETE FROM campaign_events WHERE id = $1;

-- name: GetCampaignEventCount :one
SELECT COUNT(*) FROM campaign_events WHERE campaign_id = $1 AND is_deleted = FALSE;

-- name: GetCampaignEventStats :many
SELECT 
    'All Events' as event_type,
    COUNT(ce.id) as event_count
FROM campaign_events ce
WHERE ce.campaign_id = $1 AND ce.is_deleted = FALSE
GROUP BY event_type
ORDER BY event_type;

-- name: GetCampaignEventSummary :many
SELECT 
    c.id as campaign_id,
    c.name as campaign_name,
    COUNT(ce.id) as event_count,
    STRING_AGG(e.title, ', ') as event_titles
FROM campaigns c
LEFT JOIN campaign_events ce ON c.id = ce.campaign_id AND ce.is_deleted = FALSE
LEFT JOIN events e ON ce.event_id = e.id
WHERE c.is_active = $1
GROUP BY c.id, c.name
ORDER BY c.start_date DESC;
