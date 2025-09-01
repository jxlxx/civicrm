-- name: CreateCaseActivity :one
INSERT INTO case_activities (
    case_id, activity_id, is_deleted
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: GetCaseActivity :one
SELECT * FROM case_activities WHERE id = $1 AND is_deleted = FALSE;

-- name: GetCaseActivitiesByCase :many
SELECT * FROM case_activities 
WHERE case_id = $1 AND is_deleted = FALSE 
ORDER BY id DESC;

-- name: GetCaseActivitiesByActivity :one
SELECT * FROM case_activities WHERE activity_id = $1 AND is_deleted = FALSE;

-- name: GetCaseActivitiesWithDetails :many
SELECT 
    ca.*,
    a.activity_type_id,
    a.subject,
    a.activity_date_time,
    a.duration,
    a.location,
    a.details,
    at.name as activity_type_name
FROM case_activities ca
JOIN activities a ON ca.activity_id = a.id
JOIN activity_types at ON a.activity_type_id = at.id
WHERE ca.case_id = $1 AND ca.is_deleted = FALSE 
ORDER BY a.activity_date_time DESC;

-- name: ListCaseActivities :many
SELECT * FROM case_activities 
WHERE is_deleted = FALSE 
ORDER BY id DESC;

-- name: ListCaseActivitiesByType :many
SELECT ca.* FROM case_activities ca
JOIN activities a ON ca.activity_id = a.id
WHERE a.activity_type_id = $1 AND ca.is_deleted = FALSE 
ORDER BY a.activity_date_time DESC;

-- name: ListCaseActivitiesByDateRange :many
SELECT ca.* FROM case_activities ca
JOIN activities a ON ca.activity_id = a.id
WHERE a.activity_date_time >= $1 AND a.activity_date_time <= $2 
AND ca.is_deleted = FALSE 
ORDER BY a.activity_date_time DESC;

-- name: SearchCaseActivities :many
SELECT ca.* FROM case_activities ca
JOIN activities a ON ca.activity_id = a.id
WHERE (a.subject ILIKE $1 OR a.details ILIKE $1) 
AND ca.is_deleted = FALSE 
ORDER BY a.activity_date_time DESC;

-- name: UpdateCaseActivity :one
UPDATE case_activities SET
    case_id = $2, activity_id = $3, is_deleted = $4, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteCaseActivity :exec
UPDATE case_activities SET is_deleted = TRUE, updated_at = NOW() WHERE id = $1;

-- name: HardDeleteCaseActivity :exec
DELETE FROM case_activities WHERE id = $1;

-- name: GetCaseActivityCount :one
SELECT COUNT(*) FROM case_activities WHERE case_id = $1 AND is_deleted = FALSE;

-- name: GetCaseActivityStats :many
SELECT 
    at.name as activity_type,
    COUNT(ca.id) as activity_count
FROM case_activities ca
JOIN activities a ON ca.activity_id = a.id
JOIN activity_types at ON a.activity_type_id = at.id
WHERE ca.case_id = $1 AND ca.is_deleted = FALSE
GROUP BY at.name
ORDER BY at.name;

-- name: GetCaseTimeline :many
SELECT 
    ca.id as case_activity_id,
    a.activity_date_time,
    a.subject,
    a.details,
    at.name as activity_type,
    c.first_name, c.last_name
FROM case_activities ca
JOIN activities a ON ca.activity_id = a.id
JOIN activity_types at ON a.activity_type_id = at.id
LEFT JOIN activity_contacts ac ON a.id = ac.activity_id AND ac.record_type = 'Activity'
LEFT JOIN contacts c ON ac.contact_id = c.id
WHERE ca.case_id = $1 AND ca.is_deleted = FALSE
ORDER BY a.activity_date_time DESC;
