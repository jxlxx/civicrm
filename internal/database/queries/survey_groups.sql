-- name: CreateSurveyGroup :one
INSERT INTO survey_groups (
    survey_id, group_id, is_active
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: GetSurveyGroup :one
SELECT * FROM survey_groups WHERE id = $1;

-- name: GetSurveyGroupsBySurvey :many
SELECT * FROM survey_groups 
WHERE survey_id = $1 
ORDER BY id;

-- name: GetSurveyGroupsByGroup :many
SELECT * FROM survey_groups 
WHERE group_id = $1 
ORDER BY id;

-- name: GetActiveSurveyGroups :many
SELECT * FROM survey_groups 
WHERE survey_id = $1 AND is_active = TRUE 
ORDER BY id;

-- name: GetSurveyGroupBySurveyAndGroup :one
SELECT * FROM survey_groups 
WHERE survey_id = $1 AND group_id = $2 
ORDER BY id LIMIT 1;

-- name: ListSurveyGroups :many
SELECT * FROM survey_groups 
ORDER BY id;

-- name: ListActiveSurveyGroups :many
SELECT * FROM survey_groups 
WHERE is_active = TRUE 
ORDER BY id;

-- name: SearchSurveyGroups :many
SELECT sg.* FROM survey_groups sg
JOIN surveys s ON sg.survey_id = s.id
JOIN groups g ON sg.group_id = g.id
WHERE (s.title ILIKE $1 OR g.title ILIKE $1)
ORDER BY sg.id;

-- name: UpdateSurveyGroup :one
UPDATE survey_groups SET
    survey_id = $2, group_id = $3, is_active = $4, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteSurveyGroup :exec
DELETE FROM survey_groups WHERE id = $1;

-- name: DeactivateSurveyGroup :exec
UPDATE survey_groups SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: ActivateSurveyGroup :exec
UPDATE survey_groups SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: GetSurveyGroupStats :many
SELECT 
    g.title as group_name,
    COUNT(sg.id) as survey_count
FROM survey_groups sg
JOIN groups g ON sg.group_id = g.id
WHERE sg.is_active = $1
GROUP BY g.title
ORDER BY g.title;

-- name: GetSurveyTargetAudience :many
SELECT 
    s.title as survey_title,
    COUNT(sg.id) as group_count,
    STRING_AGG(g.title, ', ') as target_groups
FROM surveys s
LEFT JOIN survey_groups sg ON s.id = sg.survey_id AND sg.is_active = TRUE
LEFT JOIN groups g ON sg.group_id = g.id
WHERE s.is_active = $1
GROUP BY s.id, s.title
ORDER BY s.created_date DESC;
