-- name: CreateParticipant :one
INSERT INTO participants (
    event_id, contact_id, status_id, role_id, register_date, source,
    fee_level, is_test, is_pay_later, fee_amount, registered_by_id,
    discount_id, fee_currency, campaign_id, discount_amount, cart_id, must_wait
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17
) RETURNING *;

-- name: GetParticipant :one
SELECT * FROM participants WHERE id = $1;

-- name: GetParticipantByEventAndContact :one
SELECT * FROM participants 
WHERE event_id = $1 AND contact_id = $2;

-- name: GetParticipantsByEvent :many
SELECT * FROM participants 
WHERE event_id = $1
ORDER BY register_date;

-- name: GetParticipantsByContact :many
SELECT * FROM participants 
WHERE contact_id = $1
ORDER BY register_date DESC;

-- name: GetParticipantsByStatus :many
SELECT * FROM participants 
WHERE status_id = $1
ORDER BY register_date DESC;

-- name: GetParticipantsByCampaign :many
SELECT * FROM participants 
WHERE campaign_id = $1
ORDER BY register_date DESC;

-- name: ListAllParticipants :many
SELECT * FROM participants 
ORDER BY register_date DESC;

-- name: ListTestParticipants :many
SELECT * FROM participants 
WHERE is_test = $1
ORDER BY register_date DESC;

-- name: SearchParticipants :many
SELECT * FROM participants 
WHERE (source ILIKE $1 OR fee_level ILIKE $1)
ORDER BY register_date DESC;

-- name: UpdateParticipant :one
UPDATE participants SET
    event_id = $2, contact_id = $3, status_id = $4, role_id = $5,
    register_date = $6, source = $7, fee_level = $8, is_test = $9,
    is_pay_later = $10, fee_amount = $11, registered_by_id = $12,
    discount_id = $13, fee_currency = $14, campaign_id = $15,
    discount_amount = $16, cart_id = $17, must_wait = $18, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteParticipant :exec
DELETE FROM participants WHERE id = $1;

-- name: CountParticipants :one
SELECT COUNT(*) FROM participants;

-- name: CountParticipantsByEvent :one
SELECT COUNT(*) FROM participants WHERE event_id = $1;

-- name: CountParticipantsByContact :one
SELECT COUNT(*) FROM participants WHERE contact_id = $1;

-- name: CountParticipantsByStatus :one
SELECT COUNT(*) FROM participants WHERE status_id = $1;

-- name: CountParticipantsByCampaign :one
SELECT COUNT(*) FROM participants WHERE campaign_id = $1;
