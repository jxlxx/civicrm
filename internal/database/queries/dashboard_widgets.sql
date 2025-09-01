-- name: CreateDashboardWidget :one
INSERT INTO dashboard_widgets (
    dashboard_id, name, widget_type, configuration, position_x, position_y, width, height, is_active
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetDashboardWidget :one
SELECT * FROM dashboard_widgets WHERE id = $1;

-- name: GetDashboardWidgetsByDashboard :many
SELECT * FROM dashboard_widgets 
WHERE dashboard_id = $1 AND is_active = $2 
ORDER BY position_y, position_x;

-- name: GetActiveDashboardWidgets :many
SELECT * FROM dashboard_widgets 
WHERE dashboard_id = $1 AND is_active = TRUE 
ORDER BY position_y, position_x;

-- name: GetDashboardWidgetsByType :many
SELECT * FROM dashboard_widgets 
WHERE dashboard_id = $1 AND widget_type = $2 AND is_active = $3 
ORDER BY position_y, position_x;

-- name: ListDashboardWidgets :many
SELECT * FROM dashboard_widgets 
ORDER BY dashboard_id, position_y, position_x;

-- name: ListActiveDashboardWidgets :many
SELECT * FROM dashboard_widgets 
WHERE is_active = TRUE 
ORDER BY dashboard_id, position_y, position_x;

-- name: ListDashboardWidgetsByType :many
SELECT * FROM dashboard_widgets 
WHERE widget_type = $1 AND is_active = $2 
ORDER BY dashboard_id, position_y, position_x;

-- name: SearchDashboardWidgets :many
SELECT * FROM dashboard_widgets 
WHERE name ILIKE $1 AND is_active = $2 
ORDER BY dashboard_id, position_y, position_x;

-- name: UpdateDashboardWidget :one
UPDATE dashboard_widgets SET
    dashboard_id = $2, name = $3, widget_type = $4, configuration = $5,
    position_x = $6, position_y = $7, width = $8, height = $9, is_active = $10, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteDashboardWidget :exec
DELETE FROM dashboard_widgets WHERE id = $1;

-- name: ActivateDashboardWidget :exec
UPDATE dashboard_widgets SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: DeactivateDashboardWidget :exec
UPDATE dashboard_widgets SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: UpdateDashboardWidgetPosition :exec
UPDATE dashboard_widgets SET position_x = $2, position_y = $3, updated_at = NOW() WHERE id = $1;

-- name: UpdateDashboardWidgetSize :exec
UPDATE dashboard_widgets SET width = $2, height = $3, updated_at = NOW() WHERE id = $1;

-- name: UpdateDashboardWidgetConfiguration :exec
UPDATE dashboard_widgets SET configuration = $2, updated_at = NOW() WHERE id = $1;

-- name: GetDashboardWidgetStats :many
SELECT 
    dw.widget_type,
    COUNT(dw.id) as widget_count
FROM dashboard_widgets dw
WHERE dw.dashboard_id = $1 AND dw.is_active = $2
GROUP BY dw.widget_type
ORDER BY dw.widget_type;

-- name: GetDashboardWidgetSummary :many
SELECT 
    dw.name,
    dw.widget_type,
    dw.position_x,
    dw.position_y,
    dw.width,
    dw.height,
    d.name as dashboard_name
FROM dashboard_widgets dw
JOIN dashboards d ON dw.dashboard_id = d.id
WHERE dw.is_active = $1
ORDER BY d.name, dw.position_y, dw.position_x;
