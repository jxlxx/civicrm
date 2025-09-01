-- name: CreateACLRole :one
INSERT INTO acl_roles (
    name, label, description, is_active
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: GetACLRole :one
SELECT * FROM acl_roles
WHERE id = $1 AND is_active = true;

-- name: GetACLRoleByName :one
SELECT * FROM acl_roles
WHERE name = $1 AND is_active = true;

-- name: ListACLRoles :many
SELECT * FROM acl_roles
WHERE is_active = true
ORDER BY name;

-- name: UpdateACLRole :one
UPDATE acl_roles
SET label = $2, description = $3, is_active = $4, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteACLRole :exec
UPDATE acl_roles
SET is_active = false, updated_at = NOW()
WHERE id = $1;

-- name: CreateACL :one
INSERT INTO acls (
    name, deny, entity_table, entity_id, operation, object_table, object_id, acl_table, acl_id, is_active, priority
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
) RETURNING *;

-- name: GetACL :one
SELECT * FROM acls
WHERE id = $1 AND is_active = true;

-- name: ListACLsByRole :many
SELECT * FROM acls
WHERE entity_table = 'acl_roles' 
AND entity_id = $1 
AND is_active = true
ORDER BY priority ASC, name;

-- name: ListACLsByEntity :many
SELECT * FROM acls
WHERE entity_table = $1 
AND entity_id = $2 
AND is_active = true
ORDER BY priority ASC, name;

-- name: ListACLsByOperation :many
SELECT * FROM acls
WHERE operation = $1 
AND is_active = true
ORDER BY priority ASC, name;

-- name: UpdateACL :one
UPDATE acls
SET name = $2, deny = $3, operation = $4, object_table = $5, object_id = $6, 
    acl_table = $7, acl_id = $8, is_active = $9, priority = $10, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteACL :exec
UPDATE acls
SET is_active = false, updated_at = NOW()
WHERE id = $1;

-- name: CreateACLEntityRole :one
INSERT INTO acl_entity_roles (
    acl_role_id, entity_table, entity_id, is_active
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: GetACLEntityRole :one
SELECT * FROM acl_entity_roles
WHERE id = $1 AND is_active = true;

-- name: ListACLEntityRolesByRole :many
SELECT * FROM acl_entity_roles
WHERE acl_role_id = $1 AND is_active = true;

-- name: ListACLEntityRolesByEntity :many
SELECT * FROM acl_entity_roles
WHERE entity_table = $1 AND entity_id = $2 AND is_active = true;

-- name: UpdateACLEntityRole :one
UPDATE acl_entity_roles
SET is_active = $2, updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteACLEntityRole :exec
UPDATE acl_entity_roles
SET is_active = false, updated_at = NOW()
WHERE id = $1;

-- name: GetUserRoles :many
SELECT ar.* FROM acl_roles ar
INNER JOIN acl_entity_roles aer ON ar.id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND ar.is_active = true
AND aer.is_active = true;

-- name: GetUserPermissions :many
SELECT DISTINCT a.* FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC, a.name;

-- name: CheckUserPermission :one
SELECT COUNT(*) > 0 as has_permission FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.operation = $2
AND a.object_table = $3
AND (a.object_id = $4 OR a.object_id IS NULL)
AND a.deny = false
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC
LIMIT 1;

-- name: GetContactsForUser :many
SELECT DISTINCT c.* FROM contacts c
INNER JOIN acl_contact_cache acc ON c.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND c.is_active = true
ORDER BY c.last_name, c.first_name;

-- name: GetGroupsForUser :many
SELECT DISTINCT g.* FROM groups g
INNER JOIN acl_contact_cache acc ON g.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND g.is_active = true
ORDER BY g.name;

-- name: GetEventsForUser :many
SELECT DISTINCT e.* FROM events e
INNER JOIN acl_contact_cache acc ON e.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND e.is_active = true
ORDER BY e.start_date;

-- name: CreateACLCache :one
INSERT INTO acl_cache (
    contact_id, acl_id
) VALUES (
    $1, $2
) RETURNING *;

-- name: GetACLCache :many
SELECT * FROM acl_cache
WHERE contact_id = $1;

-- name: DeleteACLCache :exec
DELETE FROM acl_cache
WHERE contact_id = $1;

-- name: CreateACLContactCache :one
INSERT INTO acl_contact_cache (
    user_id, contact_id, operation, domain_id
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: GetACLContactCache :many
SELECT * FROM acl_contact_cache
WHERE user_id = $1 AND operation = $2;

-- name: GetACLContactCacheByContact :many
SELECT * FROM acl_contact_cache
WHERE contact_id = $1 AND operation = $2;

-- name: DeleteACLContactCache :exec
DELETE FROM acl_contact_cache
WHERE user_id = $1 AND operation = $2;

-- name: DeleteACLContactCacheByContact :exec
DELETE FROM acl_contact_cache
WHERE contact_id = $1 AND operation = $2;

-- name: GetUserPermissionSummary :many
SELECT 
    a.operation,
    a.object_table,
    COUNT(DISTINCT a.object_id) as object_count,
    a.deny
FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.is_active = true
AND aer.is_active = true
GROUP BY a.operation, a.object_table, a.deny
ORDER BY a.operation, a.object_table;

-- name: GetRolePermissionSummary :many
SELECT 
    a.operation,
    a.object_table,
    COUNT(DISTINCT a.object_id) as object_count,
    a.deny
FROM acls a
WHERE a.entity_table = 'acl_roles' 
AND a.entity_id = $1 
AND a.is_active = true
GROUP BY a.operation, a.object_table, a.deny
ORDER BY a.operation, a.object_table;

-- name: SearchACLs :many
SELECT * FROM acls
WHERE is_active = true
AND (
    name ILIKE '%' || $1 || '%' OR
    operation ILIKE '%' || $1 || '%' OR
    object_table ILIKE '%' || $1 || '%'
)
ORDER BY priority ASC, name
LIMIT $2 OFFSET $3;

-- name: GetACLStats :one
SELECT 
    COUNT(*) as total_acls,
    COUNT(CASE WHEN deny = true THEN 1 END) as deny_rules,
    COUNT(CASE WHEN deny = false THEN 1 END) as allow_rules,
    COUNT(DISTINCT entity_id) as unique_entities,
    COUNT(DISTINCT operation) as unique_operations
FROM acls
WHERE is_active = true;


