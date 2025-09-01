-- name: CreateMembershipPayment :one
INSERT INTO membership_payments (
    membership_id, contribution_id, payment_amount, payment_currency,
    payment_date, payment_status
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetMembershipPayment :one
SELECT * FROM membership_payments WHERE id = $1;

-- name: GetMembershipPaymentsByMembership :many
SELECT * FROM membership_payments 
WHERE membership_id = $1 
ORDER BY payment_date DESC;

-- name: GetMembershipPaymentsByContribution :one
SELECT * FROM membership_payments WHERE contribution_id = $1;

-- name: ListMembershipPayments :many
SELECT * FROM membership_payments 
ORDER BY payment_date DESC;

-- name: ListMembershipPaymentsByStatus :many
SELECT * FROM membership_payments 
WHERE payment_status = $1 
ORDER BY payment_date DESC;

-- name: ListMembershipPaymentsByDateRange :many
SELECT * FROM membership_payments 
WHERE payment_date >= $1 AND payment_date <= $2 
ORDER BY payment_date DESC;

-- name: ListMembershipPaymentsByCurrency :many
SELECT * FROM membership_payments 
WHERE payment_currency = $1 
ORDER BY payment_date DESC;

-- name: SearchMembershipPayments :many
SELECT mp.* FROM membership_payments mp
JOIN memberships m ON mp.membership_id = m.id
JOIN contacts c ON m.contact_id = c.id
WHERE (c.first_name ILIKE $1 OR c.last_name ILIKE $1 OR c.organization_name ILIKE $1)
ORDER BY mp.payment_date DESC;

-- name: UpdateMembershipPayment :one
UPDATE membership_payments SET
    membership_id = $2, contribution_id = $3, payment_amount = $4,
    payment_currency = $5, payment_date = $6, payment_status = $7,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteMembershipPayment :exec
DELETE FROM membership_payments WHERE id = $1;

-- name: UpdatePaymentStatus :exec
UPDATE membership_payments SET payment_status = $2, updated_at = NOW() WHERE id = $1;

-- name: GetMembershipPaymentTotal :one
SELECT SUM(payment_amount) FROM membership_payments 
WHERE membership_id = $1 AND payment_status = 'Completed';

-- name: GetMembershipPaymentStats :many
SELECT 
    payment_status,
    payment_currency,
    COUNT(*) as count,
    SUM(payment_amount) as total_amount
FROM membership_payments 
WHERE payment_date >= $1 AND payment_date <= $2
GROUP BY payment_status, payment_currency
ORDER BY payment_status, payment_currency;
