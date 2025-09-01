-- name: CreateUser :one
INSERT INTO users (
    username, email, hashed_password, is_active, is_admin
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetUser :one
SELECT * FROM users
WHERE id = $1 AND is_active = true;

-- name: GetUserByUsername :one
SELECT * FROM users
WHERE username = $1 AND is_active = true;

-- name: GetUserByEmail :one
SELECT * FROM users
WHERE email = $1 AND is_active = true;

-- name: ListUsers :many
SELECT * FROM users
WHERE is_active = true
ORDER BY username;

-- name: ListUsersByRole :many
SELECT u.* FROM users u
INNER JOIN acl_entity_roles aer ON u.id = aer.entity_id
INNER JOIN acl_roles ar ON aer.acl_role_id = ar.id
WHERE aer.entity_table = 'users' 
AND ar.name = $1 
AND u.is_active = true
AND aer.is_active = true
ORDER BY u.username;

-- name: UpdateUser :one
UPDATE users
SET username = $2, email = $3, is_active = $4, is_admin = $5, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: UpdateUserPassword :one
UPDATE users
SET hashed_password = $2, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: UpdateUserLastLogin :one
UPDATE users
SET last_login = NOW(), updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteUser :exec
UPDATE users
SET is_active = false, updated_at = NOW()
WHERE id = $1;

-- name: SearchUsers :many
SELECT * FROM users
WHERE is_active = true
AND (
    username ILIKE '%' || $1 || '%' OR
    email ILIKE '%' || $1 || '%'
)
ORDER BY username
LIMIT $2 OFFSET $3;

-- name: GetUserStats :one
SELECT 
    COUNT(*) as total_users,
    COUNT(CASE WHEN is_admin = true THEN 1 END) as admin_users,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_users,
    COUNT(CASE WHEN last_login IS NOT NULL THEN 1 END) as users_with_logins
FROM users;

-- name: CreateUFMatch :one
INSERT INTO uf_match (
    domain_id, uf_id, uf_name, contact_id, language
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetUFMatch :one
SELECT * FROM uf_match
WHERE id = $1;

-- name: GetUFMatchByUserID :one
SELECT * FROM uf_match
WHERE uf_id = $1;

-- name: GetUFMatchByContactID :one
SELECT * FROM uf_match
WHERE contact_id = $1;

-- name: GetUFMatchByUsername :one
SELECT * FROM uf_match
WHERE uf_name = $1;

-- name: ListUFMatches :many
SELECT * FROM uf_match
ORDER BY uf_name;

-- name: UpdateUFMatch :one
UPDATE uf_match
SET domain_id = $2, uf_name = $3, contact_id = $4, language = $5, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteUFMatch :exec
DELETE FROM uf_match
WHERE id = $1;

-- name: GetUserWithContact :one
SELECT 
    u.*,
    c.id as contact_id,
    c.first_name,
    c.last_name,
    c.email as contact_email,
    c.contact_type
FROM users u
LEFT JOIN uf_match ufm ON u.id = ufm.uf_id
LEFT JOIN contacts c ON ufm.contact_id = c.id
WHERE u.id = $1 AND u.is_active = true;

-- name: GetUserByUsernameWithContact :one
SELECT 
    u.*,
    c.id as contact_id,
    c.first_name,
    c.last_name,
    c.email as contact_email,
    c.contact_type
FROM users u
LEFT JOIN uf_match ufm ON u.id = ufm.uf_id
LEFT JOIN contacts c ON ufm.contact_id = c.id
WHERE u.username = $1 AND u.is_active = true;

-- name: GetUserByEmailWithContact :one
SELECT 
    u.*,
    c.id as contact_id,
    c.first_name,
    c.last_name,
    c.email as contact_email,
    c.contact_type
FROM users u
LEFT JOIN uf_match ufm ON u.id = ufm.uf_id
LEFT JOIN contacts c ON ufm.contact_id = c.id
WHERE u.email = $1 AND u.is_active = true;

-- name: GetUsersWithContacts :many
SELECT 
    u.*,
    c.id as contact_id,
    c.first_name,
    c.last_name,
    c.email as contact_email,
    c.contact_type
FROM users u
LEFT JOIN uf_match ufm ON u.id = ufm.uf_id
LEFT JOIN contacts c ON ufm.contact_id = c.id
WHERE u.is_active = true
ORDER BY u.username;

-- name: GetUsersByRoleWithContacts :many
SELECT 
    u.*,
    c.id as contact_id,
    c.first_name,
    c.last_name,
    c.email as contact_email,
    c.contact_type
FROM users u
INNER JOIN acl_entity_roles aer ON u.id = aer.entity_id
INNER JOIN acl_roles ar ON aer.acl_role_id = ar.id
LEFT JOIN uf_match ufm ON u.id = ufm.uf_id
LEFT JOIN contacts c ON ufm.contact_id = c.id
WHERE aer.entity_table = 'users' 
AND ar.name = $1 
AND u.is_active = true
AND aer.is_active = true
ORDER BY u.username;

-- name: AssignUserToRole :one
INSERT INTO acl_entity_roles (
    acl_role_id, entity_table, entity_id, is_active
) VALUES (
    (SELECT id FROM acl_roles WHERE name = $1), 'users', $2, true
) RETURNING *;

-- name: RemoveUserFromRole :exec
UPDATE acl_entity_roles
SET is_active = false, updated_at = NOW()
WHERE entity_table = 'users' 
AND entity_id = $2
AND acl_role_id = (SELECT id FROM acl_roles WHERE name = $1);



-- name: GetUsersByPermission :many
SELECT DISTINCT u.* FROM users u
INNER JOIN acl_entity_roles aer ON u.id = aer.entity_id
INNER JOIN acls a ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND a.entity_table = 'acl_roles'
AND a.operation = $1
AND a.object_table = $2
AND (a.object_id = $3 OR a.object_id IS NULL)
AND a.deny = false
AND a.is_active = true
AND aer.is_active = true
AND u.is_active = true
ORDER BY u.username;
