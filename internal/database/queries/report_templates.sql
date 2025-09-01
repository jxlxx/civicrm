-- name: CreateReportTemplate :one
INSERT INTO report_templates (
    name, description, report_type, query_template, parameters, is_active, is_system, created_by
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- name: GetReportTemplate :one
SELECT * FROM report_templates WHERE id = $1;

-- name: GetReportTemplateByName :one
SELECT * FROM report_templates WHERE name = $1;

-- name: GetReportTemplatesByType :many
SELECT * FROM report_templates 
WHERE report_type = $1 AND is_active = $2 
ORDER BY name;

-- name: GetSystemReportTemplates :many
SELECT * FROM report_templates 
WHERE is_system = TRUE AND is_active = $1 
ORDER BY name;

-- name: GetCustomReportTemplates :many
SELECT * FROM report_templates 
WHERE is_system = FALSE AND is_active = $1 
ORDER BY name;

-- name: ListReportTemplates :many
SELECT * FROM report_templates 
ORDER BY name;

-- name: ListActiveReportTemplates :many
SELECT * FROM report_templates 
WHERE is_active = TRUE 
ORDER BY name;

-- name: ListReportTemplatesByCreator :many
SELECT * FROM report_templates 
WHERE created_by = $1 AND is_active = $2 
ORDER BY name;

-- name: SearchReportTemplates :many
SELECT * FROM report_templates 
WHERE (name ILIKE $1 OR description ILIKE $1) AND is_active = $2 
ORDER BY name;

-- name: UpdateReportTemplate :one
UPDATE report_templates SET
    name = $2, description = $3, report_type = $4, query_template = $5,
    parameters = $6, is_active = $7, is_system = $8, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteReportTemplate :exec
DELETE FROM report_templates WHERE id = $1;

-- name: ActivateReportTemplate :exec
UPDATE report_templates SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateReportTemplate :exec
UPDATE report_templates SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: GetReportTemplateStats :many
SELECT 
    rt.report_type,
    COUNT(rt.id) as template_count,
    COUNT(CASE WHEN rt.is_system = TRUE THEN 1 END) as system_count,
    COUNT(CASE WHEN rt.is_system = FALSE THEN 1 END) as custom_count
FROM report_templates rt
WHERE rt.is_active = $1
GROUP BY rt.report_type
ORDER BY rt.report_type;

-- name: GetReportTemplateSummary :many
SELECT 
    rt.name,
    rt.description,
    rt.report_type,
    rt.is_system,
    rt.created_at,
    c.first_name || ' ' || c.last_name as created_by_name
FROM report_templates rt
LEFT JOIN contacts c ON rt.created_by = c.id
WHERE rt.is_active = $1
ORDER BY rt.created_at DESC;
