-- name: CreateReportPermission :one
INSERT INTO report_permissions (
    report_template_id, role_id, permission_type, is_active
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: GetReportPermission :one
SELECT * FROM report_permissions WHERE id = $1;

-- name: GetReportPermissionsByTemplate :many
SELECT * FROM report_permissions 
WHERE report_template_id = $1 AND is_active = $2 
ORDER BY permission_type;

-- name: GetReportPermissionsByRole :many
SELECT * FROM report_permissions 
WHERE role_id = $1 AND is_active = $2 
ORDER BY permission_type;

-- name: GetPublicReportPermissions :many
SELECT * FROM report_permissions 
WHERE role_id IS NULL AND is_active = $1 
ORDER BY permission_type;

-- name: GetActiveReportPermissions :many
SELECT * FROM report_permissions 
WHERE is_active = TRUE 
ORDER BY report_template_id, permission_type;

-- name: GetReportPermissionsByType :many
SELECT * FROM report_permissions 
WHERE permission_type = $1 AND is_active = $2 
ORDER BY report_template_id;

-- name: GetReportPermissionByTemplateAndRole :one
SELECT * FROM report_permissions 
WHERE report_template_id = $1 AND role_id = $2 
ORDER BY permission_type LIMIT 1;

-- name: ListReportPermissions :many
SELECT * FROM report_permissions 
ORDER BY report_template_id, permission_type;

-- name: ListReportPermissionsByDateRange :many
SELECT * FROM report_permissions 
WHERE created_at >= $1 AND created_at <= $2 
ORDER BY created_at DESC;

-- name: SearchReportPermissions :many
SELECT rp.* FROM report_permissions rp
JOIN report_templates rt ON rp.report_template_id = rt.id
WHERE rt.name ILIKE $1 AND rp.is_active = $2
ORDER BY rp.id;

-- name: UpdateReportPermission :one
UPDATE report_permissions SET
    report_template_id = $2, role_id = $3, permission_type = $4,
    is_active = $5, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteReportPermission :exec
DELETE FROM report_permissions WHERE id = $1;

-- name: DeactivateReportPermission :exec
UPDATE report_permissions SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: ActivateReportPermission :exec
UPDATE report_permissions SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: UpdateReportPermissionType :exec
UPDATE report_permissions SET permission_type = $2, updated_at = NOW() WHERE id = $1;

-- name: GetReportPermissionStats :many
SELECT 
    rp.permission_type,
    COUNT(rp.id) as permission_count
FROM report_permissions rp
WHERE rp.is_active = $1
GROUP BY rp.permission_type
ORDER BY rp.permission_type;

-- name: GetReportPermissionSummary :many
SELECT 
    rt.name as report_name,
    rt.report_type,
    rp.permission_type,
    rp.role_id,
    rp.is_active,
    rp.created_at
FROM report_permissions rp
JOIN report_templates rt ON rp.report_template_id = rt.id
WHERE rp.is_active = $1
ORDER BY rt.name, rp.permission_type;
