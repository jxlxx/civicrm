-- name: CreatePriceSet :one
INSERT INTO price_sets (
    name, title, description, extends, financial_type_id, 
    is_active, is_quick_config, min_amount, max_amount
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetPriceSet :one
SELECT * FROM price_sets WHERE id = $1;

-- name: GetPriceSetByName :one
SELECT * FROM price_sets WHERE name = $1;

-- name: GetPriceSetByTitle :one
SELECT * FROM price_sets WHERE title = $1;

-- name: ListPriceSets :many
SELECT * FROM price_sets 
WHERE is_active = $1 
ORDER BY name;

-- name: ListPriceSetsByExtends :many
SELECT * FROM price_sets 
WHERE extends = $1 AND is_active = $2
ORDER BY name;

-- name: ListPriceSetsByFinancialType :many
SELECT * FROM price_sets 
WHERE financial_type_id = $1 AND is_active = $2
ORDER BY name;

-- name: ListActivePriceSets :many
SELECT * FROM price_sets 
WHERE is_active = TRUE 
ORDER BY name;

-- name: SearchPriceSets :many
SELECT * FROM price_sets 
WHERE (name ILIKE $1 OR title ILIKE $1 OR description ILIKE $1)
AND is_active = $2
ORDER BY name;

-- name: UpdatePriceSet :one
UPDATE price_sets SET
    name = $2, title = $3, description = $4, extends = $5,
    financial_type_id = $6, is_active = $7, is_quick_config = $8,
    min_amount = $9, max_amount = $10, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeletePriceSet :exec
DELETE FROM price_sets WHERE id = $1;

-- name: CountPriceSets :one
SELECT COUNT(*) FROM price_sets WHERE is_active = $1;

-- name: CountPriceSetsByExtends :one
SELECT COUNT(*) FROM price_sets 
WHERE extends = $1 AND is_active = $2;
