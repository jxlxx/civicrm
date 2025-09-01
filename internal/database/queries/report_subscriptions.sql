-- name: CreateReportSubscription :one
INSERT INTO report_subscriptions (
    report_instance_id, contact_id, delivery_method, delivery_config, is_active
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetReportSubscription :one
SELECT * FROM report_subscriptions WHERE id = $1;

-- name: GetReportSubscriptionsByInstance :many
SELECT * FROM report_subscriptions 
WHERE report_instance_id = $1 AND is_active = $2 
ORDER BY id;

-- name: GetReportSubscriptionsByContact :many
SELECT * FROM report_subscriptions 
WHERE contact_id = $1 AND is_active = $2 
ORDER BY id;

-- name: GetActiveReportSubscriptions :many
SELECT * FROM report_subscriptions 
WHERE is_active = TRUE 
ORDER BY id;

-- name: GetReportSubscriptionsByDeliveryMethod :many
SELECT * FROM report_subscriptions 
WHERE delivery_method = $1 AND is_active = $2 
ORDER BY id;

-- name: GetReportSubscriptionByInstanceAndContact :one
SELECT * FROM report_subscriptions 
WHERE report_instance_id = $1 AND contact_id = $2 
ORDER BY id LIMIT 1;

-- name: ListReportSubscriptions :many
SELECT * FROM report_subscriptions 
ORDER BY id;

-- name: ListReportSubscriptionsByDateRange :many
SELECT * FROM report_subscriptions 
WHERE created_at >= $1 AND created_at <= $2 
ORDER BY created_at DESC;

-- name: SearchReportSubscriptions :many
SELECT rs.* FROM report_subscriptions rs
JOIN contacts c ON rs.contact_id = c.id
WHERE (c.first_name ILIKE $1 OR c.last_name ILIKE $1 OR c.organization_name ILIKE $1) AND rs.is_active = $2
ORDER BY rs.id;

-- name: UpdateReportSubscription :one
UPDATE report_subscriptions SET
    report_instance_id = $2, contact_id = $3, delivery_method = $4,
    delivery_config = $5, is_active = $6, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteReportSubscription :exec
DELETE FROM report_subscriptions WHERE id = $1;

-- name: DeactivateReportSubscription :exec
UPDATE report_subscriptions SET is_active = FALSE, updated_at = NOW() WHERE id = $1;

-- name: ActivateReportSubscription :exec
UPDATE report_subscriptions SET is_active = TRUE, updated_at = NOW() WHERE id = $1;

-- name: UpdateReportSubscriptionDeliveryMethod :exec
UPDATE report_subscriptions SET delivery_method = $2, updated_at = NOW() WHERE id = $1;

-- name: UpdateReportSubscriptionDeliveryConfig :exec
UPDATE report_subscriptions SET delivery_config = $2, updated_at = NOW() WHERE id = $1;

-- name: GetReportSubscriptionStats :many
SELECT 
    rs.delivery_method,
    COUNT(rs.id) as subscription_count
FROM report_subscriptions rs
WHERE rs.is_active = $1
GROUP BY rs.delivery_method
ORDER BY rs.delivery_method;

-- name: GetReportSubscriptionSummary :many
SELECT 
    ri.name as report_name,
    rt.report_type,
    rs.delivery_method,
    c.first_name || ' ' || c.last_name as contact_name,
    rs.created_at
FROM report_subscriptions rs
JOIN report_instances ri ON rs.report_instance_id = ri.id
JOIN report_templates rt ON ri.report_template_id = rt.id
JOIN contacts c ON rs.contact_id = c.id
WHERE rs.is_active = $1
ORDER BY rs.created_at DESC;
