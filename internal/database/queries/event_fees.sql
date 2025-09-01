-- name: CreateEventFee :one
INSERT INTO event_fees (
    event_id, name, label, amount, currency, is_active,
    weight, help_pre, help_post, is_default
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: GetEventFee :one
SELECT * FROM event_fees WHERE id = $1;

-- name: GetEventFeeByName :one
SELECT * FROM event_fees WHERE name = $1 AND event_id = $2;

-- name: GetEventFeeByEvent :many
SELECT * FROM event_fees 
WHERE event_id = $1
ORDER BY weight, name;

-- name: GetActiveEventFees :many
SELECT * FROM event_fees 
WHERE is_active = TRUE
ORDER BY weight, name;

-- name: GetDefaultEventFee :one
SELECT * FROM event_fees 
WHERE event_id = $1 AND is_default = TRUE AND is_active = TRUE
LIMIT 1;

-- name: ListEventFees :many
SELECT * FROM event_fees 
ORDER BY event_id, weight, name;

-- name: ListEventFeesByEvent :many
SELECT * FROM event_fees 
WHERE event_id = $1 AND is_active = $2
ORDER BY weight, name;

-- name: SearchEventFees :many
SELECT * FROM event_fees 
WHERE (name ILIKE $1 OR label ILIKE $1)
AND event_id = $2
ORDER BY weight, name;

-- name: UpdateEventFee :one
UPDATE event_fees SET
    event_id = $2, name = $3, label = $4, amount = $5, currency = $6,
    is_active = $7, weight = $8, help_pre = $9, help_post = $10,
    is_default = $11, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteEventFee :exec
DELETE FROM event_fees WHERE id = $1;

-- name: CountEventFees :one
SELECT COUNT(*) FROM event_fees;

-- name: CountEventFeesByEvent :one
SELECT COUNT(*) FROM event_fees WHERE event_id = $1;

-- name: CountActiveEventFees :one
SELECT COUNT(*) FROM event_fees WHERE is_active = TRUE;
