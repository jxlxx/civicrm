-- name: CreateReportInstance :one
INSERT INTO report_instances (
    report_template_id, name, description, parameters, schedule, is_active, created_by
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetReportInstance :one
SELECT * FROM report_instances WHERE id = $1;

-- name: GetReportInstanceByName :one
SELECT * FROM report_instances WHERE name = $1;

-- name: GetReportInstancesByTemplate :many
SELECT * FROM report_instances 
WHERE report_template_id = $1 AND is_active = $2 
ORDER BY name;

-- name: GetActiveReportInstances :many
SELECT * FROM report_instances 
WHERE is_active = TRUE 
ORDER BY name;

-- name: GetScheduledReportInstances :many
SELECT * FROM report_instances 
WHERE schedule IS NOT NULL AND is_active = $1 
ORDER BY next_run;

-- name: GetReportInstancesByCreator :many
SELECT * FROM report_instances 
WHERE created_by = $1 AND is_active = $2 
ORDER BY name;

-- name: ListReportInstances :many
SELECT * FROM report_instances 
ORDER BY name;

-- name: ListReportInstancesByDateRange :many
SELECT * FROM report_instances 
WHERE created_at >= $1 AND created_at <= $2 
ORDER BY created_at DESC;

-- name: SearchReportInstances :many
SELECT * FROM report_instances 
WHERE (name ILIKE $1 OR description ILIKE $1) AND is_active = $2 
ORDER BY name;

-- name: UpdateReportInstance :one
UPDATE report_instances SET
    report_template_id = $2, name = $3, description = $4, parameters = $5,
    schedule = $6, is_active = $7, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteReportInstance :exec
DELETE FROM report_instances WHERE id = $1;

-- name: ActivateReportInstance :exec
UPDATE report_instances SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateReportInstance :exec
UPDATE report_instances SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateReportInstanceSchedule :exec
UPDATE report_instances SET schedule = $2, updated_at = NOW() WHERE id = $1;

-- name: UpdateReportInstanceLastRun :exec
UPDATE report_instances SET last_run = $2, updated_at = NOW() WHERE id = $1;

-- name: UpdateReportInstanceNextRun :exec
UPDATE report_instances SET next_run = $2, updated_at = NOW() WHERE id = $1;

-- name: GetReportInstanceStats :many
SELECT 
    rt.report_type,
    COUNT(ri.id) as instance_count,
    COUNT(CASE WHEN ri.schedule IS NOT NULL THEN 1 END) as scheduled_count
FROM report_instances ri
JOIN report_templates rt ON ri.report_template_id = rt.id
WHERE ri.is_active = $1
GROUP BY rt.report_type
ORDER BY rt.report_type;

-- name: GetReportInstanceSummary :many
SELECT 
    ri.name,
    ri.description,
    ri.schedule,
    ri.last_run,
    ri.next_run,
    rt.name as template_name,
    rt.report_type,
    c.first_name || ' ' || c.last_name as created_by_name
FROM report_instances ri
JOIN report_templates rt ON ri.report_template_id = rt.id
LEFT JOIN contacts c ON ri.created_by = c.id
WHERE ri.is_active = $1
ORDER BY ri.created_at DESC;
