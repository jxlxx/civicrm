-- name: CreateDiscount :one
INSERT INTO discounts (
    name, description, discount_type_id, amount, percentage, is_active
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetDiscount :one
SELECT * FROM discounts WHERE id = $1;

-- name: GetDiscountByName :one
SELECT * FROM discounts WHERE name = $1;

-- name: ListDiscounts :many
SELECT * FROM discounts 
WHERE is_active = $1
ORDER BY name;

-- name: SearchDiscounts :many
SELECT * FROM discounts 
WHERE (name ILIKE $1 OR description ILIKE $1)
AND is_active = $2
ORDER BY name;

-- name: UpdateDiscount :one
UPDATE discounts SET
    name = $2, description = $3, discount_type_id = $4,
    amount = $5, percentage = $6, is_active = $7, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteDiscount :exec
DELETE FROM discounts WHERE id = $1;

-- name: CountDiscounts :one
SELECT COUNT(*) FROM discounts WHERE is_active = $1;
