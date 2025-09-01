-- name: CreateLineItem :one
INSERT INTO line_items (
    entity_table, entity_id, price_field_id, price_field_value_id,
    label, qty, unit_price, line_total, financial_type_id,
    non_deductible_amount, tax_amount
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
) RETURNING *;

-- name: GetLineItem :one
SELECT * FROM line_items WHERE id = $1;

-- name: GetLineItemsByEntity :many
SELECT * FROM line_items 
WHERE entity_table = $1 AND entity_id = $2
ORDER BY id;

-- name: GetLineItemsByPriceField :many
SELECT * FROM line_items 
WHERE price_field_id = $1
ORDER BY id;

-- name: GetLineItemsByFinancialType :many
SELECT * FROM line_items 
WHERE financial_type_id = $1
ORDER BY id;

-- name: ListAllLineItems :many
SELECT * FROM line_items 
ORDER BY entity_table, entity_id, id;

-- name: SearchLineItems :many
SELECT * FROM line_items 
WHERE label ILIKE $1
ORDER BY entity_table, entity_id, id;

-- name: UpdateLineItem :one
UPDATE line_items SET
    entity_table = $2, entity_id = $3, price_field_id = $4, 
    price_field_value_id = $5, label = $6, qty = $7, unit_price = $8,
    line_total = $9, financial_type_id = $10, non_deductible_amount = $11,
    tax_amount = $12, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteLineItem :exec
DELETE FROM line_items WHERE id = $1;

-- name: DeleteLineItemsByEntity :exec
DELETE FROM line_items WHERE entity_table = $1 AND entity_id = $2;

-- name: CountLineItems :one
SELECT COUNT(*) FROM line_items;

-- name: CountLineItemsByEntity :one
SELECT COUNT(*) FROM line_items 
WHERE entity_table = $1 AND entity_id = $2;

-- name: CountLineItemsByFinancialType :one
SELECT COUNT(*) FROM line_items WHERE financial_type_id = $1;

-- name: GetTotalLineItemsByEntity :one
SELECT COALESCE(SUM(line_total), 0) as total FROM line_items 
WHERE entity_table = $1 AND entity_id = $2;
