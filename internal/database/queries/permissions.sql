-- name: CheckContactPermission :one
SELECT COUNT(*) > 0 as has_permission FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.operation = $2
AND a.object_table = 'contacts'
AND (a.object_id = $3 OR a.object_id IS NULL)
AND a.deny = false
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC
LIMIT 1;

-- name: CheckGroupPermission :one
SELECT COUNT(*) > 0 as has_permission FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.operation = $2
AND a.object_table = 'groups'
AND (a.object_id = $3 OR a.object_id IS NULL)
AND a.deny = false
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC
LIMIT 1;

-- name: CheckEventPermission :one
SELECT COUNT(*) > 0 as has_permission FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.operation = $2
AND a.object_table = 'events'
AND (a.object_id = $3 OR a.object_id IS NULL)
AND a.deny = false
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC
LIMIT 1;

-- name: CheckCampaignPermission :one
SELECT COUNT(*) > 0 as has_permission FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.operation = $2
AND a.object_table = 'campaigns'
AND (a.object_id = $3 OR a.object_id IS NULL)
AND a.deny = false
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC
LIMIT 1;

-- name: CheckCasePermission :one
SELECT COUNT(*) > 0 as has_permission FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.operation = $2
AND a.object_table = 'cases'
AND (a.object_id = $3 OR a.object_id IS NULL)
AND a.deny = false
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC
LIMIT 1;

-- name: CheckMembershipPermission :one
SELECT COUNT(*) > 0 as has_permission FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.operation = $2
AND a.object_table = 'memberships'
AND (a.object_id = $3 OR a.object_id IS NULL)
AND a.deny = false
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC
LIMIT 1;

-- name: CheckContributionPermission :one
SELECT COUNT(*) > 0 as has_permission FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.operation = $2
AND a.object_table = 'contributions'
AND (a.object_id = $3 OR a.object_id IS NULL)
AND a.deny = false
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC
LIMIT 1;

-- name: GetUserAccessibleContacts :many
SELECT DISTINCT c.* FROM contacts c
INNER JOIN acl_contact_cache acc ON c.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND c.is_active = true
ORDER BY c.last_name, c.first_name
LIMIT $3 OFFSET $4;

-- name: GetUserAccessibleGroups :many
SELECT DISTINCT g.* FROM groups g
INNER JOIN acl_contact_cache acc ON g.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND g.is_active = true
ORDER BY g.name
LIMIT $3 OFFSET $4;

-- name: GetUserAccessibleEvents :many
SELECT DISTINCT e.* FROM events e
INNER JOIN acl_contact_cache acc ON e.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND e.is_active = true
ORDER BY e.start_date
LIMIT $3 OFFSET $4;

-- name: GetUserAccessibleCampaigns :many
SELECT DISTINCT cam.* FROM campaigns cam
INNER JOIN acl_contact_cache acc ON cam.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND cam.is_active = true
ORDER BY cam.name
LIMIT $3 OFFSET $4;

-- name: GetUserAccessibleCases :many
SELECT DISTINCT cas.* FROM cases cas
INNER JOIN acl_contact_cache acc ON cas.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND cas.is_deleted = false
ORDER BY cas.created_date DESC
LIMIT $3 OFFSET $4;

-- name: GetUserAccessibleMemberships :many
SELECT DISTINCT m.* FROM memberships m
INNER JOIN acl_contact_cache acc ON m.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
ORDER BY m.start_date DESC
LIMIT $3 OFFSET $4;

-- name: GetUserAccessibleContributions :many
SELECT DISTINCT cont.* FROM contributions cont
INNER JOIN acl_contact_cache acc ON cont.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND cont.status != 'Cancelled'
ORDER BY cont.received_date DESC
LIMIT $3 OFFSET $4;

-- name: CountUserAccessibleContacts :one
SELECT COUNT(DISTINCT c.id) FROM contacts c
INNER JOIN acl_contact_cache acc ON c.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND c.is_active = true;

-- name: CountUserAccessibleGroups :one
SELECT COUNT(DISTINCT g.id) FROM groups g
INNER JOIN acl_contact_cache acc ON g.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND g.is_active = true;

-- name: CountUserAccessibleEvents :one
SELECT COUNT(DISTINCT e.id) FROM events e
INNER JOIN acl_contact_cache acc ON e.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND e.is_active = true;

-- name: CountUserAccessibleCampaigns :one
SELECT COUNT(DISTINCT cam.id) FROM campaigns cam
INNER JOIN acl_contact_cache acc ON cam.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND cam.is_active = true;

-- name: CountUserAccessibleCases :one
SELECT COUNT(DISTINCT cas.id) FROM cases cas
INNER JOIN acl_contact_cache acc ON cas.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND cas.is_deleted = false;

-- name: CountUserAccessibleMemberships :one
SELECT COUNT(DISTINCT m.id) FROM memberships m
INNER JOIN acl_contact_cache acc ON m.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2;

-- name: CountUserAccessibleContributions :one
SELECT COUNT(DISTINCT cont.id) FROM contributions cont
INNER JOIN acl_contact_cache acc ON cont.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND cont.status != 'Cancelled';

-- name: GetUserPermissionMatrix :many
SELECT 
    a.operation,
    a.object_table,
    a.object_id,
    a.deny,
    a.priority,
    ar.name as role_name
FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
INNER JOIN acl_roles ar ON aer.acl_role_id = ar.id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC, a.operation, a.object_table;

-- name: GetRolePermissionMatrix :many
SELECT 
    a.operation,
    a.object_table,
    a.object_id,
    a.deny,
    a.priority
FROM acls a
WHERE a.entity_table = 'acl_roles' 
AND a.entity_id = $1 
AND a.is_active = true
ORDER BY a.priority ASC, a.operation, a.object_table;

-- name: SearchUserAccessibleContacts :many
SELECT DISTINCT c.* FROM contacts c
INNER JOIN acl_contact_cache acc ON c.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND c.is_active = true
AND (
    c.first_name ILIKE '%' || $3 || '%' OR
    c.last_name ILIKE '%' || $3 || '%' OR
    c.email ILIKE '%' || $3 || '%'
)
ORDER BY c.last_name, c.first_name
LIMIT $4 OFFSET $5;

-- name: SearchUserAccessibleGroups :many
SELECT DISTINCT g.* FROM groups g
INNER JOIN acl_contact_cache acc ON g.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND g.is_active = true
AND g.name ILIKE '%' || $3 || '%'
ORDER BY g.name
LIMIT $4 OFFSET $5;

-- name: SearchUserAccessibleEvents :many
SELECT DISTINCT e.* FROM events e
INNER JOIN acl_contact_cache acc ON e.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = $2
AND e.is_active = true
AND e.title ILIKE '%' || $3 || '%'
ORDER BY e.start_date
LIMIT $4 OFFSET $5;

-- name: GetUserPermissionSummaryByType :many
SELECT 
    a.object_table,
    a.operation,
    COUNT(DISTINCT a.object_id) as object_count,
    a.deny,
    MAX(a.priority) as max_priority
FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.is_active = true
AND aer.is_active = true
GROUP BY a.object_table, a.operation, a.deny
ORDER BY a.object_table, a.operation;
