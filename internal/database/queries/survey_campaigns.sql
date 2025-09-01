-- name: CreateSurveyCampaign :one
INSERT INTO survey_campaigns (
    survey_id, campaign_id, is_active
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: GetSurveyCampaign :one
SELECT * FROM survey_campaigns WHERE id = $1;

-- name: GetSurveyCampaignsBySurvey :many
SELECT * FROM survey_campaigns 
WHERE survey_id = $1 
ORDER BY id;

-- name: GetSurveyCampaignsByCampaign :many
SELECT * FROM survey_campaigns 
WHERE campaign_id = $1 
ORDER BY id;

-- name: GetActiveSurveyCampaigns :many
SELECT * FROM survey_campaigns 
WHERE survey_id = $1 AND is_active = TRUE 
ORDER BY id;

-- name: GetSurveyCampaignBySurveyAndCampaign :one
SELECT * FROM survey_campaigns 
WHERE survey_id = $1 AND campaign_id = $2 
ORDER BY id LIMIT 1;

-- name: ListSurveyCampaigns :many
SELECT * FROM survey_campaigns 
ORDER BY id;

-- name: ListActiveSurveyCampaigns :many
SELECT * FROM survey_campaigns 
WHERE is_active = TRUE 
ORDER BY id;

-- name: SearchSurveyCampaigns :many
SELECT sc.* FROM survey_campaigns sc
JOIN surveys s ON sc.survey_id = s.id
JOIN campaigns c ON sc.campaign_id = c.id
WHERE (s.title ILIKE $1 OR c.name ILIKE $1)
ORDER BY sc.id;

-- name: UpdateSurveyCampaign :one
UPDATE survey_campaigns SET
    survey_id = $2, campaign_id = $3, is_active = $4, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteSurveyCampaign :exec
DELETE FROM survey_campaigns WHERE id = $1;

-- name: DeactivateSurveyCampaign :exec
UPDATE survey_campaigns SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: ActivateSurveyCampaign :exec
UPDATE survey_campaigns SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: GetSurveyCampaignStats :many
SELECT 
    c.name as campaign_name,
    COUNT(sc.id) as survey_count
FROM survey_campaigns sc
JOIN campaigns c ON sc.campaign_id = c.id
WHERE sc.is_active = $1
GROUP BY c.name
ORDER BY c.name;

-- name: GetSurveyCampaignSummary :many
SELECT 
    s.title as survey_title,
    COUNT(sc.id) as campaign_count,
    STRING_AGG(c.name, ', ') as campaign_names
FROM surveys s
LEFT JOIN survey_campaigns sc ON s.id = sc.survey_id AND sc.is_active = TRUE
LEFT JOIN campaigns c ON sc.campaign_id = c.id
WHERE s.is_active = $1
GROUP BY s.id, s.title
ORDER BY s.created_date DESC;
