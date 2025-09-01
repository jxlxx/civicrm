-- name: CreateQueue :one
INSERT INTO queues (
    domain_id, name, description, is_active, max_retries, retry_delay_seconds
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetQueue :one
SELECT * FROM queues WHERE id = $1;

-- name: GetQueueByName :one
SELECT * FROM queues WHERE domain_id = $1 AND name = $2;

-- name: ListQueuesByDomain :many
SELECT * FROM queues 
WHERE domain_id = $1 
ORDER BY name ASC;

-- name: ListActiveQueuesByDomain :many
SELECT * FROM queues 
WHERE domain_id = $1 AND is_active = TRUE 
ORDER BY name ASC;

-- name: ListAllQueues :many
SELECT q.*, d.name as domain_name FROM queues q
INNER JOIN domains d ON q.domain_id = d.id
ORDER BY d.name ASC, q.name ASC;

-- name: UpdateQueue :one
UPDATE queues 
SET 
    name = $3,
    description = $4,
    is_active = $5,
    max_retries = $6,
    retry_delay_seconds = $7,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: UpdateQueueStatus :one
UPDATE queues 
SET 
    is_active = $3,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: DeleteQueue :exec
DELETE FROM queues WHERE id = $1 AND domain_id = $2;

-- name: DeleteQueuesByDomain :exec
DELETE FROM queues WHERE domain_id = $1;

-- name: CountQueuesByDomain :one
SELECT COUNT(*) FROM queues WHERE domain_id = $1;

-- name: CountActiveQueuesByDomain :one
SELECT COUNT(*) FROM queues WHERE domain_id = $1 AND is_active = TRUE;

-- name: SearchQueues :many
SELECT q.*, d.name as domain_name FROM queues q
INNER JOIN domains d ON q.domain_id = d.id
WHERE q.name ILIKE $1 OR q.description ILIKE $1
ORDER BY d.name ASC, q.name ASC
LIMIT $2 OFFSET $3;

-- name: GetQueueStats :one
SELECT 
    COUNT(*) as total_items,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_items,
    COUNT(CASE WHEN status = 'processing' THEN 1 END) as processing_items,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_items,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_items,
    AVG(priority) as avg_priority
FROM queue_items 
WHERE queue_id = $1;

-- name: GetQueuePerformanceMetrics :many
SELECT 
    DATE(scheduled_at) as queue_date,
    COUNT(*) as item_count,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_count,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_count,
    AVG(EXTRACT(EPOCH FROM (completed_at - scheduled_at))) as avg_processing_time_seconds
FROM queue_items 
WHERE queue_id = $1 
AND scheduled_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(scheduled_at)
ORDER BY queue_date DESC;

-- name: GetQueueWithItems :many
SELECT q.*, qi.* FROM queues q
LEFT JOIN queue_items qi ON q.id = qi.queue_id
WHERE q.id = $1
ORDER BY qi.priority DESC, qi.scheduled_at ASC;

-- name: GetQueueHealthStatus :one
SELECT 
    q.name,
    q.is_active,
    COUNT(qi.id) as total_items,
    COUNT(CASE WHEN qi.status = 'failed' AND qi.attempts >= q.max_retries THEN 1 END) as permanently_failed,
    COUNT(CASE WHEN qi.status = 'pending' AND qi.scheduled_at < NOW() - INTERVAL '1 hour' THEN 1 END) as stale_items,
    q.max_retries,
    q.retry_delay_seconds
FROM queues q
LEFT JOIN queue_items qi ON q.id = qi.queue_id
WHERE q.id = $1
GROUP BY q.id, q.name, q.is_active, q.max_retries, q.retry_delay_seconds;
