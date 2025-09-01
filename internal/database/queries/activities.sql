-- name: CreateActivity :one
INSERT INTO activities (
    activity_type_id, subject, activity_date_time, duration, location,
    phone_id, phone_number, details, status_id, priority_id, parent_id,
    is_test, medium_id, is_auto, relationship_id, is_current_revision,
    original_id, result, is_deleted, campaign_id, engagement_level, weight, is_star
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23
) RETURNING *;

-- name: GetActivity :one
SELECT * FROM activities WHERE id = $1;

-- name: GetActivityBySubject :one
SELECT * FROM activities WHERE subject = $1 LIMIT 1;

-- name: GetActivitiesByType :many
SELECT * FROM activities 
WHERE activity_type_id = $1 AND is_deleted = FALSE
ORDER BY activity_date_time DESC;

-- name: GetActivitiesByStatus :many
SELECT * FROM activities 
WHERE status_id = $1 AND is_deleted = FALSE
ORDER BY activity_date_time DESC;

-- name: GetActivitiesByPriority :many
SELECT * FROM activities 
WHERE priority_id = $1 AND is_deleted = FALSE
ORDER BY activity_date_time DESC;

-- name: GetActivitiesByContact :many
SELECT a.* FROM activities a
JOIN activity_contacts ac ON a.id = ac.activity_id
WHERE ac.contact_id = $1 AND a.is_deleted = FALSE
ORDER BY a.activity_date_time DESC;

-- name: GetActivitiesByDateRange :many
SELECT * FROM activities 
WHERE activity_date_time BETWEEN $1 AND $2 AND is_deleted = FALSE
ORDER BY activity_date_time DESC;

-- name: GetActivitiesByCampaign :many
SELECT * FROM activities 
WHERE campaign_id = $1 AND is_deleted = FALSE
ORDER BY activity_date_time DESC;

-- name: GetUpcomingActivities :many
SELECT * FROM activities 
WHERE activity_date_time > NOW() AND is_deleted = FALSE
ORDER BY activity_date_time;

-- name: GetPastActivities :many
SELECT * FROM activities 
WHERE activity_date_time < NOW() AND is_deleted = FALSE
ORDER BY activity_date_time DESC;

-- name: ListAllActivities :many
SELECT * FROM activities 
WHERE is_deleted = FALSE
ORDER BY activity_date_time DESC;

-- name: SearchActivities :many
SELECT * FROM activities 
WHERE (subject ILIKE $1 OR details ILIKE $1 OR location ILIKE $1)
AND is_deleted = FALSE
ORDER BY activity_date_time DESC;

-- name: UpdateActivity :one
UPDATE activities SET
    activity_type_id = $2, subject = $3, activity_date_time = $4, duration = $5,
    location = $6, phone_id = $7, phone_number = $8, details = $9, status_id = $10,
    priority_id = $11, parent_id = $12, is_test = $13, medium_id = $14, is_auto = $15,
    relationship_id = $16, is_current_revision = $17, original_id = $18, result = $19,
    is_deleted = $20, campaign_id = $21, engagement_level = $22, weight = $23,
    is_star = $24, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteActivity :exec
UPDATE activities SET is_deleted = TRUE, updated_at = NOW() WHERE id = $1;

-- name: HardDeleteActivity :exec
DELETE FROM activities WHERE id = $1;

-- name: CountActivities :one
SELECT COUNT(*) FROM activities WHERE is_deleted = FALSE;

-- name: CountActivitiesByType :one
SELECT COUNT(*) FROM activities 
WHERE activity_type_id = $1 AND is_deleted = FALSE;

-- name: CountActivitiesByStatus :one
SELECT COUNT(*) FROM activities 
WHERE status_id = $1 AND is_deleted = FALSE;

-- name: CountActivitiesByContact :one
SELECT COUNT(*) FROM activities a
JOIN activity_contacts ac ON a.id = ac.activity_id
WHERE ac.contact_id = $1 AND a.is_deleted = FALSE;
