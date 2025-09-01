-- name: CreateFinancialAccount :one
INSERT INTO financial_accounts (
    name, description, account_type_code, account_code, parent_id, 
    is_header_account, is_deductible, is_tax, is_reserved, is_active
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: GetFinancialAccount :one
SELECT * FROM financial_accounts WHERE id = $1;

-- name: GetFinancialAccountByCode :one
SELECT * FROM financial_accounts WHERE account_code = $1;

-- name: GetFinancialAccountByName :one
SELECT * FROM financial_accounts WHERE name = $1;

-- name: ListFinancialAccounts :many
SELECT * FROM financial_accounts 
WHERE is_active = $1 
ORDER BY account_code;

-- name: ListFinancialAccountsByType :many
SELECT * FROM financial_accounts 
WHERE account_type_code = $1 AND is_active = $2
ORDER BY account_code;

-- name: ListChildAccounts :many
SELECT * FROM financial_accounts 
WHERE parent_id = $1 AND is_active = $2
ORDER BY account_code;

-- name: ListHeaderAccounts :many
SELECT * FROM financial_accounts 
WHERE is_header_account = $1 AND is_active = $2
ORDER BY account_code;

-- name: SearchFinancialAccounts :many
SELECT * FROM financial_accounts 
WHERE (name ILIKE $1 OR description ILIKE $1 OR account_code ILIKE $1)
AND is_active = $2
ORDER BY account_code;

-- name: UpdateFinancialAccount :one
UPDATE financial_accounts SET
    name = $2, description = $3, account_type_code = $4, account_code = $5,
    parent_id = $6, is_header_account = $7, is_deductible = $8, 
    is_tax = $9, is_reserved = $10, is_active = $11, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteFinancialAccount :exec
DELETE FROM financial_accounts WHERE id = $1;

-- name: CountFinancialAccounts :one
SELECT COUNT(*) FROM financial_accounts WHERE is_active = $1;

-- name: CountFinancialAccountsByType :one
SELECT COUNT(*) FROM financial_accounts 
WHERE account_type_code = $1 AND is_active = $2;
