-- name: CreatePriceFieldValue :one
INSERT INTO price_field_values (
    price_field_id, name, label, amount, weight, is_active,
    financial_type_id, membership_type_id, membership_num_terms, is_default
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: GetPriceFieldValue :one
SELECT * FROM price_field_values WHERE id = $1;

-- name: GetPriceFieldValueByName :one
SELECT * FROM price_field_values WHERE name = $1 AND price_field_id = $2;

-- name: ListPriceFieldValues :many
SELECT * FROM price_field_values 
WHERE price_field_id = $1 
ORDER BY weight, name;

-- name: ListPriceFieldValuesByFinancialType :many
SELECT * FROM price_field_values 
WHERE financial_type_id = $1 AND is_active = $2
ORDER BY weight, name;

-- name: ListActivePriceFieldValues :many
SELECT * FROM price_field_values 
WHERE is_active = TRUE 
ORDER BY weight, name;

-- name: ListDefaultPriceFieldValues :many
SELECT * FROM price_field_values 
WHERE is_default = TRUE AND is_active = $1
ORDER BY weight, name;

-- name: SearchPriceFieldValues :many
SELECT * FROM price_field_values 
WHERE (name ILIKE $1 OR label ILIKE $1)
AND price_field_id = $2
ORDER BY weight, name;

-- name: UpdatePriceFieldValue :one
UPDATE price_field_values SET
    price_field_id = $2, name = $3, label = $4, amount = $5, weight = $6,
    is_active = $7, financial_type_id = $8, membership_type_id = $9,
    membership_num_terms = $10, is_default = $11, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeletePriceFieldValue :exec
DELETE FROM price_field_values WHERE id = $1;

-- name: CountPriceFieldValues :one
SELECT COUNT(*) FROM price_field_values WHERE price_field_id = $1;

-- name: CountPriceFieldValuesByFinancialType :one
SELECT COUNT(*) FROM price_field_values 
WHERE financial_type_id = $1 AND is_active = $2;
