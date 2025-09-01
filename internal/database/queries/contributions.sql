-- name: CreateContribution :one
INSERT INTO contributions (
    contact_id, amount, currency, contribution_type, status
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetContribution :one
SELECT * FROM contributions WHERE id = $1;

-- name: GetContributionsByContact :many
SELECT * FROM contributions 
WHERE contact_id = $1 
ORDER BY received_date DESC;

-- name: ListContributions :many
SELECT 
    c.*,
    co.contact_type,
    co.first_name,
    co.last_name,
    co.organization_name,
    co.email
FROM contributions c
JOIN contacts co ON c.contact_id = co.id
ORDER BY c.received_date DESC 
LIMIT $1 OFFSET $2;

-- name: ListContributionsByType :many
SELECT 
    c.*,
    co.contact_type,
    co.first_name,
    co.last_name,
    co.organization_name,
    co.email
FROM contributions c
JOIN contacts co ON c.contact_id = co.id
WHERE c.contribution_type = $1
ORDER BY c.received_date DESC 
LIMIT $2 OFFSET $3;

-- name: ListContributionsByStatus :many
SELECT 
    c.*,
    co.contact_type,
    co.first_name,
    co.last_name,
    co.organization_name,
    co.email
FROM contributions c
JOIN contacts co ON c.contact_id = co.id
WHERE c.status = $1
ORDER BY c.received_date DESC 
LIMIT $2 OFFSET $3;

-- name: SearchContributions :many
SELECT 
    c.*,
    co.contact_type,
    co.first_name,
    co.last_name,
    co.organization_name,
    co.email
FROM contributions c
JOIN contacts co ON c.contact_id = co.id
WHERE (
    co.first_name ILIKE $1 OR 
    co.last_name ILIKE $1 OR 
    co.organization_name ILIKE $1 OR
    co.email ILIKE $1
)
ORDER BY c.received_date DESC 
LIMIT $2 OFFSET $3;

-- name: UpdateContribution :one
UPDATE contributions 
SET 
    amount = $2,
    currency = $3,
    contribution_type = $4,
    status = $5,
    updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- name: DeleteContribution :exec
DELETE FROM contributions WHERE id = $1;

-- name: CountContributions :one
SELECT COUNT(*) FROM contributions;

-- name: CountContributionsByContact :one
SELECT COUNT(*) FROM contributions WHERE contact_id = $1;

-- name: CountContributionsByType :one
SELECT COUNT(*) FROM contributions WHERE contribution_type = $1;

-- name: CountContributionsByStatus :one
SELECT COUNT(*) FROM contributions WHERE status = $1;

-- name: GetTotalContributions :one
SELECT SUM(amount) FROM contributions WHERE status = 'Completed';

-- name: GetTotalContributionsByContact :one
SELECT SUM(amount) FROM contributions WHERE contact_id = $1 AND status = 'Completed';

-- name: GetContributionsByDateRange :many
SELECT 
    c.*,
    co.contact_type,
    co.first_name,
    co.last_name,
    co.organization_name,
    co.email
FROM contributions c
JOIN contacts co ON c.contact_id = co.id
WHERE c.received_date >= $1 AND c.received_date <= $2
ORDER BY c.received_date DESC;
