-- name: CreateSurveyResponseAnswer :one
INSERT INTO survey_response_answers (
    survey_response_id, survey_question_id, answer_text, answer_numeric, answer_date, answer_boolean
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetSurveyResponseAnswer :one
SELECT * FROM survey_response_answers WHERE id = $1;

-- name: GetSurveyResponseAnswersByResponse :many
SELECT * FROM survey_response_answers 
WHERE survey_response_id = $1 
ORDER BY id;

-- name: GetSurveyResponseAnswersByQuestion :many
SELECT * FROM survey_response_answers 
WHERE survey_question_id = $1 
ORDER BY id;

-- name: GetSurveyResponseAnswersWithDetails :many
SELECT 
    sra.*,
    sq.question_text,
    sq.question_type,
    sq.question_options,
    sq.is_required
FROM survey_response_answers sra
JOIN survey_questions sq ON sra.survey_question_id = sq.id
WHERE sra.survey_response_id = $1 
ORDER BY sq.weight, sq.id;

-- name: ListSurveyResponseAnswers :many
SELECT * FROM survey_response_answers 
ORDER BY id;

-- name: ListSurveyResponseAnswersByQuestionType :many
SELECT sra.* FROM survey_response_answers sra
JOIN survey_questions sq ON sra.survey_question_id = sq.id
WHERE sq.question_type = $1 
ORDER BY sra.id;

-- name: SearchSurveyResponseAnswers :many
SELECT sra.* FROM survey_response_answers sra
JOIN survey_questions sq ON sra.survey_question_id = sq.id
WHERE sq.question_text ILIKE $1 
ORDER BY sra.id;

-- name: UpdateSurveyResponseAnswer :one
UPDATE survey_response_answers SET
    survey_response_id = $2, survey_question_id = $3, answer_text = $4,
    answer_numeric = $5, answer_date = $6, answer_boolean = $7, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteSurveyResponseAnswer :exec
DELETE FROM survey_response_answers WHERE id = $1;

-- name: DeleteSurveyResponseAnswersByResponse :exec
DELETE FROM survey_response_answers WHERE survey_response_id = $1;

-- name: GetSurveyResponseAnswerCount :one
SELECT COUNT(*) FROM survey_response_answers WHERE survey_response_id = $1;

-- name: GetSurveyResponseAnswerStats :many
SELECT 
    sq.question_type,
    COUNT(sra.id) as answer_count
FROM survey_response_answers sra
JOIN survey_questions sq ON sra.survey_question_id = sq.id
WHERE sra.survey_response_id = $1
GROUP BY sq.question_type
ORDER BY sq.question_type;

-- name: GetSurveyAnalytics :many
SELECT 
    sq.question_text,
    sq.question_type,
    sq.question_options,
    COUNT(sra.id) as response_count,
    STRING_AGG(DISTINCT sra.answer_text, '; ') as text_answers,
    AVG(sra.answer_numeric) as avg_numeric,
    MIN(sra.answer_numeric) as min_numeric,
    MAX(sra.answer_numeric) as max_numeric
FROM survey_questions sq
LEFT JOIN survey_response_answers sra ON sq.id = sra.survey_question_id
LEFT JOIN survey_responses sr ON sra.survey_response_id = sr.id
WHERE sq.survey_id = $1 AND sq.is_active = TRUE AND sr.status = 'Completed'
GROUP BY sq.id, sq.question_text, sq.question_type, sq.question_options, sq.weight
ORDER BY sq.weight, sq.id;

-- name: GetSurveyResponseSummary :many
SELECT 
    sr.id as response_id,
    sr.response_date,
    sr.status,
    COUNT(sra.id) as answered_questions,
    COUNT(sq.id) as total_questions,
    ROUND(
        (COUNT(sra.id)::DECIMAL / NULLIF(COUNT(sq.id), 0)::DECIMAL) * 100, 2
    ) as completion_percentage
FROM survey_responses sr
LEFT JOIN survey_response_answers sra ON sr.id = sra.survey_response_id
LEFT JOIN survey_questions sq ON sr.survey_id = sq.survey_id AND sq.is_active = TRUE
WHERE sr.survey_id = $1
GROUP BY sr.id, sr.response_date, sr.status
ORDER BY sr.response_date DESC;
