-- name: CreateSurveyQuestion :one
INSERT INTO survey_questions (
    survey_id, question_text, question_type, question_options, is_required, weight, help_text, is_active
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- name: GetSurveyQuestion :one
SELECT * FROM survey_questions WHERE id = $1;

-- name: GetSurveyQuestionsBySurvey :many
SELECT * FROM survey_questions 
WHERE survey_id = $1 AND is_active = $2 
ORDER BY weight, id;

-- name: GetActiveSurveyQuestionsBySurvey :many
SELECT * FROM survey_questions 
WHERE survey_id = $1 AND is_active = TRUE 
ORDER BY weight, id;

-- name: GetSurveyQuestionsByType :many
SELECT * FROM survey_questions 
WHERE survey_id = $1 AND question_type = $2 AND is_active = $3 
ORDER BY weight, id;

-- name: GetRequiredSurveyQuestions :many
SELECT * FROM survey_questions 
WHERE survey_id = $1 AND is_required = TRUE AND is_active = $2 
ORDER BY weight, id;

-- name: ListSurveyQuestions :many
SELECT * FROM survey_questions 
ORDER BY weight, id;

-- name: ListActiveSurveyQuestions :many
SELECT * FROM survey_questions 
WHERE is_active = TRUE 
ORDER BY weight, id;

-- name: ListSurveyQuestionsByType :many
SELECT * FROM survey_questions 
WHERE question_type = $1 AND is_active = $2 
ORDER BY weight, id;

-- name: SearchSurveyQuestions :many
SELECT * FROM survey_questions 
WHERE question_text ILIKE $1 AND is_active = $2 
ORDER BY weight, id;

-- name: UpdateSurveyQuestion :one
UPDATE survey_questions SET
    survey_id = $2, question_text = $3, question_type = $4, question_options = $5,
    is_required = $6, weight = $7, help_text = $8, is_active = $9, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteSurveyQuestion :exec
DELETE FROM survey_questions WHERE id = $1;

-- name: ActivateSurveyQuestion :exec
UPDATE survey_questions SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateSurveyQuestion :exec
UPDATE survey_questions SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateSurveyQuestionWeight :exec
UPDATE survey_questions SET weight = $2, updated_at = NOW() WHERE id = $1;

-- name: GetSurveyQuestionStats :many
SELECT 
    sq.question_type,
    COUNT(sq.id) as question_count
FROM survey_questions sq
WHERE sq.survey_id = $1 AND sq.is_active = $2
GROUP BY sq.question_type
ORDER BY sq.question_type;

-- name: GetSurveyQuestionSummary :many
SELECT 
    s.title as survey_title,
    COUNT(sq.id) as question_count,
    COUNT(CASE WHEN sq.is_required = TRUE THEN 1 END) as required_count,
    STRING_AGG(DISTINCT sq.question_type, ', ') as question_types
FROM surveys s
LEFT JOIN survey_questions sq ON s.id = sq.survey_id AND sq.is_active = TRUE
WHERE s.is_active = $1
GROUP BY s.id, s.title
ORDER BY s.created_date DESC;
