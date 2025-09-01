-- name: CreateContact :one
INSERT INTO contacts (
    contact_type, first_name, last_name, organization_name, 
    email, phone, address_line_1, address_line_2, 
    city, state_province, postal_code, country
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
) RETURNING *;

-- name: GetContact :one
SELECT * FROM contacts WHERE id = $1;

-- name: GetContactByEmail :one
SELECT * FROM contacts WHERE email = $1;

-- name: GetContactByPhone :one
SELECT * FROM contacts WHERE phone = $1;

-- name: ListContacts :many
SELECT * FROM contacts 
WHERE contact_type = $1 
ORDER BY created_at DESC 
LIMIT $2 OFFSET $3;

-- name: ListAllContacts :many
SELECT * FROM contacts 
ORDER BY created_at DESC 
LIMIT $1 OFFSET $2;

-- name: SearchContacts :many
SELECT * FROM contacts 
WHERE (
    first_name ILIKE $1 OR 
    last_name ILIKE $1 OR 
    organization_name ILIKE $1 OR
    email ILIKE $1
)
ORDER BY created_at DESC 
LIMIT $2 OFFSET $3;

-- name: UpdateContact :one
UPDATE contacts 
SET 
    contact_type = $2,
    first_name = $3,
    last_name = $4,
    organization_name = $5,
    email = $6,
    phone = $7,
    address_line_1 = $8,
    address_line_2 = $9,
    city = $10,
    state_province = $11,
    postal_code = $12,
    country = $13,
    updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- name: DeleteContact :exec
DELETE FROM contacts WHERE id = $1;

-- name: CountContacts :one
SELECT COUNT(*) FROM contacts WHERE contact_type = $1;

-- name: CountAllContacts :one
SELECT COUNT(*) FROM contacts;

-- name: GetContactsByType :many
SELECT * FROM contacts 
WHERE contact_type = $1 
ORDER BY created_at DESC;

-- name: GetContactsByLocation :many
SELECT * FROM contacts 
WHERE city = $1 AND state_province = $2 
ORDER BY created_at DESC;
