-- name: CreateSurveyResponse :one
INSERT INTO survey_responses (
    survey_id, contact_id, response_date, status, ip_address, user_agent, is_test
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetSurveyResponse :one
SELECT * FROM survey_responses WHERE id = $1;

-- name: GetSurveyResponsesBySurvey :many
SELECT * FROM survey_responses 
WHERE survey_id = $1 
ORDER BY response_date DESC;

-- name: GetSurveyResponsesByContact :many
SELECT * FROM survey_responses 
WHERE contact_id = $1 
ORDER BY response_date DESC;

-- name: GetSurveyResponsesByStatus :many
SELECT * FROM survey_responses 
WHERE survey_id = $1 AND status = $2 
ORDER BY response_date DESC;

-- name: GetCompletedSurveyResponses :many
SELECT * FROM survey_responses 
WHERE survey_id = $1 AND status = 'Completed' 
ORDER BY response_date DESC;

-- name: GetSurveyResponseBySurveyAndContact :one
SELECT * FROM survey_responses 
WHERE survey_id = $1 AND contact_id = $2 
ORDER BY response_date DESC LIMIT 1;

-- name: ListSurveyResponses :many
SELECT * FROM survey_responses 
ORDER BY response_date DESC;

-- name: ListSurveyResponsesByDateRange :many
SELECT * FROM survey_responses 
WHERE response_date >= $1 AND response_date <= $2 
ORDER BY response_date DESC;

-- name: ListTestSurveyResponses :many
SELECT * FROM survey_responses 
WHERE is_test = $1 
ORDER BY response_date DESC;

-- name: SearchSurveyResponses :many
SELECT sr.* FROM survey_responses sr
JOIN contacts c ON sr.contact_id = c.id
WHERE (c.first_name ILIKE $1 OR c.last_name ILIKE $1 OR c.organization_name ILIKE $1)
ORDER BY sr.response_date DESC;

-- name: UpdateSurveyResponse :one
UPDATE survey_responses SET
    survey_id = $2, contact_id = $3, response_date = $4, status = $5,
    ip_address = $6, user_agent = $7, is_test = $8, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteSurveyResponse :exec
DELETE FROM survey_responses WHERE id = $1;

-- name: UpdateSurveyResponseStatus :exec
UPDATE survey_responses SET status = $2, updated_at = NOW() WHERE id = $1;

-- name: MarkSurveyResponseCompleted :exec
UPDATE survey_responses SET status = 'Completed', updated_at = NOW() WHERE id = $1;

-- name: MarkSurveyResponsePartial :exec
UPDATE survey_responses SET status = 'Partial', updated_at = NOW() WHERE id = $1;

-- name: MarkSurveyResponseAbandoned :exec
UPDATE survey_responses SET status = 'Abandoned', updated_at = NOW() WHERE id = $1;

-- name: GetSurveyResponseCount :one
SELECT COUNT(*) FROM survey_responses WHERE survey_id = $1;

-- name: GetSurveyResponseStats :many
SELECT 
    sr.status,
    COUNT(sr.id) as response_count
FROM survey_responses sr
WHERE sr.survey_id = $1
GROUP BY sr.status
ORDER BY sr.status;

-- name: GetSurveyResponseTrends :many
SELECT 
    DATE_TRUNC('day', sr.response_date) as response_date,
    COUNT(sr.id) as response_count,
    COUNT(CASE WHEN sr.status = 'Completed' THEN 1 END) as completed_count
FROM survey_responses sr
WHERE sr.survey_id = $1 AND sr.response_date >= $2
GROUP BY DATE_TRUNC('day', sr.response_date)
ORDER BY response_date DESC;
