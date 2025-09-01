-- name: CreateNavigation :one
INSERT INTO navigation (
    domain_id, parent_id, name, label, url, icon, permission, weight, is_active, is_visible
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: GetNavigation :one
SELECT * FROM navigation WHERE id = $1;

-- name: GetNavigationByName :one
SELECT * FROM navigation WHERE domain_id = $1 AND name = $2;

-- name: GetNavigationByURL :one
SELECT * FROM navigation WHERE domain_id = $1 AND url = $2;

-- name: GetRootNavigation :many
SELECT * FROM navigation 
WHERE domain_id = $1 AND parent_id IS NULL 
ORDER BY weight ASC, name ASC;

-- name: GetChildNavigation :many
SELECT * FROM navigation 
WHERE parent_id = $1 
ORDER BY weight ASC, name ASC;

-- name: GetNavigationTree :many
WITH RECURSIVE nav_tree AS (
    SELECT n.*, 0 as level, ARRAY[n.weight, n.id] as path
    FROM navigation n
    WHERE n.domain_id = $1 AND n.parent_id IS NULL
    
    UNION ALL
    
    SELECT n.*, nt.level + 1, nt.path || n.weight || n.id
    FROM navigation n
    INNER JOIN nav_tree nt ON n.parent_id = nt.id
    WHERE n.domain_id = $1
)
SELECT * FROM nav_tree 
ORDER BY path ASC;

-- name: GetActiveNavigation :many
SELECT * FROM navigation 
WHERE domain_id = $1 AND is_active = TRUE 
ORDER BY weight ASC, name ASC;

-- name: GetVisibleNavigation :many
SELECT * FROM navigation 
WHERE domain_id = $1 AND is_active = TRUE AND is_visible = TRUE 
ORDER BY weight ASC, name ASC;

-- name: GetNavigationByPermission :many
SELECT * FROM navigation 
WHERE domain_id = $1 AND permission = $2 AND is_active = TRUE 
ORDER BY weight ASC, name ASC;

-- name: UpdateNavigation :one
UPDATE navigation 
SET 
    parent_id = $3,
    name = $4,
    label = $5,
    url = $6,
    icon = $7,
    permission = $8,
    weight = $9,
    is_active = $10,
    is_visible = $11,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: UpdateNavigationWeight :one
UPDATE navigation 
SET 
    weight = $3,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: UpdateNavigationStatus :one
UPDATE navigation 
SET 
    is_active = $3,
    is_visible = $4,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: DeleteNavigation :exec
DELETE FROM navigation WHERE id = $1 AND domain_id = $2;

-- name: DeleteNavigationByDomain :exec
DELETE FROM navigation WHERE domain_id = $1;

-- name: CountNavigationByDomain :one
SELECT COUNT(*) FROM navigation WHERE domain_id = $1;

-- name: CountActiveNavigationByDomain :one
SELECT COUNT(*) FROM navigation WHERE domain_id = $1 AND is_active = TRUE;

-- name: GetNavigationBreadcrumb :many
WITH RECURSIVE breadcrumb AS (
    SELECT n.*, 0 as level
    FROM navigation n
    WHERE n.id = $1
    
    UNION ALL
    
    SELECT p.*, bc.level + 1
    FROM navigation p
    INNER JOIN breadcrumb bc ON p.id = bc.parent_id
)
SELECT * FROM breadcrumb 
ORDER BY level DESC;

-- name: GetNavigationSiblings :many
SELECT * FROM navigation 
WHERE parent_id = (SELECT parent_id FROM navigation WHERE navigation.id = $1)
AND navigation.id != $1
ORDER BY weight ASC, name ASC;

-- name: ReorderNavigation :many
UPDATE navigation 
SET 
    weight = CASE 
        WHEN navigation.id = $1 THEN $2
        WHEN navigation.id = $3 THEN $4
        WHEN navigation.id = $5 THEN $6
        ELSE weight
    END,
    updated_at = NOW()
WHERE domain_id = $7 AND navigation.id IN ($1, $3, $5)
RETURNING *;

-- name: SearchNavigation :many
SELECT * FROM navigation 
WHERE domain_id = $1 
AND (name ILIKE $2 OR label ILIKE $2 OR url ILIKE $2)
ORDER BY weight ASC, name ASC
LIMIT $3 OFFSET $4;
