-- name: CreateDashboard :one
INSERT INTO dashboards (
    name, description, layout, is_active, is_default, created_by
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetDashboard :one
SELECT * FROM dashboards WHERE id = $1;

-- name: GetDashboardByName :one
SELECT * FROM dashboards WHERE name = $1;

-- name: GetDefaultDashboard :one
SELECT * FROM dashboards WHERE is_default = TRUE AND is_active = TRUE LIMIT 1;

-- name: GetActiveDashboards :many
SELECT * FROM dashboards 
WHERE is_active = TRUE 
ORDER BY name;

-- name: GetDashboardsByCreator :many
SELECT * FROM dashboards 
WHERE created_by = $1 AND is_active = $2 
ORDER BY name;

-- name: ListDashboards :many
SELECT * FROM dashboards 
ORDER BY name;

-- name: ListDashboardsByDateRange :many
SELECT * FROM dashboards 
WHERE created_at >= $1 AND created_at <= $2 
ORDER BY created_at DESC;

-- name: SearchDashboards :many
SELECT * FROM dashboards 
WHERE (name ILIKE $1 OR description ILIKE $1) AND is_active = $2 
ORDER BY name;

-- name: UpdateDashboard :one
UPDATE dashboards SET
    name = $2, description = $3, layout = $4, is_active = $5,
    is_default = $6, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteDashboard :exec
DELETE FROM dashboards WHERE id = $1;

-- name: ActivateDashboard :exec
UPDATE dashboards SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateDashboard :exec
UPDATE dashboards SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: SetDefaultDashboard :exec
UPDATE dashboards SET is_default = FALSE, updated_at = NOW();
UPDATE dashboards SET is_default = TRUE, updated_at = NOW() WHERE id = $1;

-- name: UpdateDashboardLayout :exec
UPDATE dashboards SET layout = $2, updated_at = NOW() WHERE id = $1;

-- name: GetDashboardStats :many
SELECT 
    d.name as dashboard_name,
    COUNT(dw.id) as widget_count,
    COUNT(CASE WHEN dw.is_active = TRUE THEN 1 END) as active_widgets
FROM dashboards d
LEFT JOIN dashboard_widgets dw ON d.id = dw.dashboard_id
WHERE d.is_active = $1
GROUP BY d.id, d.name
ORDER BY d.name;

-- name: GetDashboardSummary :many
SELECT 
    d.name,
    d.description,
    d.is_default,
    d.created_at,
    COUNT(dw.id) as widget_count,
    c.first_name || ' ' || c.last_name as created_by_name
FROM dashboards d
LEFT JOIN dashboard_widgets dw ON d.id = dw.dashboard_id AND dw.is_active = TRUE
LEFT JOIN contacts c ON d.created_by = c.id
WHERE d.is_active = $1
GROUP BY d.id, d.name, d.description, d.is_default, d.created_at, c.first_name, c.last_name
ORDER BY d.created_at DESC;
