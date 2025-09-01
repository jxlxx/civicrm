-- name: CreatePriceField :one
INSERT INTO price_fields (
    price_set_id, name, label, html_type, price, is_required,
    is_display_amounts, weight, help_pre, help_post, options_per_line,
    is_active, is_enter_qty, default_value
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
) RETURNING *;

-- name: GetPriceField :one
SELECT * FROM price_fields WHERE id = $1;

-- name: GetPriceFieldByName :one
SELECT * FROM price_fields WHERE name = $1 AND price_set_id = $2;

-- name: ListPriceFields :many
SELECT * FROM price_fields 
WHERE price_set_id = $1 
ORDER BY weight, name;

-- name: ListPriceFieldsByType :many
SELECT * FROM price_fields 
WHERE html_type = $1 AND is_active = $2
ORDER BY weight, name;

-- name: ListActivePriceFields :many
SELECT * FROM price_fields 
WHERE is_active = TRUE 
ORDER BY weight, name;

-- name: ListPriceFieldsBySet :many
SELECT * FROM price_fields 
WHERE price_set_id = $1 AND is_active = $2
ORDER BY weight, name;

-- name: SearchPriceFields :many
SELECT * FROM price_fields 
WHERE (name ILIKE $1 OR label ILIKE $1)
AND price_set_id = $2
ORDER BY weight, name;

-- name: UpdatePriceField :one
UPDATE price_fields SET
    price_set_id = $2, name = $3, label = $4, html_type = $5, price = $6,
    is_required = $7, is_display_amounts = $8, weight = $9, help_pre = $10,
    help_post = $11, options_per_line = $12, is_active = $13, 
    is_enter_qty = $14, default_value = $15, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeletePriceField :exec
DELETE FROM price_fields WHERE id = $1;

-- name: CountPriceFields :one
SELECT COUNT(*) FROM price_fields WHERE price_set_id = $1;

-- name: CountPriceFieldsByType :one
SELECT COUNT(*) FROM price_fields 
WHERE html_type = $1 AND is_active = $2;
