-- name: CreateSurvey :one
INSERT INTO surveys (
    title, description, instructions, thank_you_text, is_active, is_default
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetSurvey :one
SELECT * FROM surveys WHERE id = $1;

-- name: GetSurveyByTitle :one
SELECT * FROM surveys WHERE title = $1;

-- name: GetDefaultSurvey :one
SELECT * FROM surveys WHERE is_default = TRUE AND is_active = TRUE LIMIT 1;

-- name: ListSurveys :many
SELECT * FROM surveys 
ORDER BY created_date DESC;

-- name: ListActiveSurveys :many
SELECT * FROM surveys 
WHERE is_active = TRUE 
ORDER BY created_date DESC;

-- name: ListSurveysByDateRange :many
SELECT * FROM surveys 
WHERE created_date >= $1 AND created_date <= $2 
ORDER BY created_date DESC;

-- name: SearchSurveys :many
SELECT * FROM surveys 
WHERE (title ILIKE $1 OR description ILIKE $1 OR instructions ILIKE $1) 
ORDER BY created_date DESC;

-- name: UpdateSurvey :one
UPDATE surveys SET
    title = $2, description = $3, instructions = $4, thank_you_text = $5,
    is_active = $6, is_default = $7, modified_date = NOW(), updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteSurvey :exec
DELETE FROM surveys WHERE id = $1;

-- name: ActivateSurvey :exec
UPDATE surveys SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateSurvey :exec
UPDATE surveys SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: SetDefaultSurvey :exec
UPDATE surveys SET is_default = FALSE, updated_at = NOW();
UPDATE surveys SET is_default = TRUE, updated_at = NOW() WHERE id = $1;

-- name: GetSurveyStats :many
SELECT 
    s.title as survey_title,
    COUNT(sr.id) as response_count,
    COUNT(CASE WHEN sr.status = 'Completed' THEN 1 END) as completed_count,
    COUNT(CASE WHEN sr.status = 'Partial' THEN 1 END) as partial_count,
    COUNT(CASE WHEN sr.status = 'Abandoned' THEN 1 END) as abandoned_count
FROM surveys s
LEFT JOIN survey_responses sr ON s.id = sr.survey_id
WHERE s.is_active = $1
GROUP BY s.id, s.title, s.created_date
ORDER BY s.created_date DESC;

-- name: GetSurveyResponseRate :many
SELECT 
    s.title as survey_title,
    COUNT(sr.id) as total_responses,
    COUNT(CASE WHEN sr.status = 'Completed' THEN 1 END) as completed_responses,
    ROUND(
        (COUNT(CASE WHEN sr.status = 'Completed' THEN 1 END)::DECIMAL / 
         NULLIF(COUNT(sr.id), 0)::DECIMAL) * 100, 2
    ) as completion_rate
FROM surveys s
LEFT JOIN survey_responses sr ON s.id = sr.survey_id
WHERE s.is_active = $1
GROUP BY s.id, s.title
ORDER BY completion_rate DESC;
