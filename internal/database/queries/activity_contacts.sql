-- name: CreateActivityContact :one
INSERT INTO activity_contacts (
    activity_id, contact_id, record_type_id, role, is_deleted
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetActivityContact :one
SELECT * FROM activity_contacts WHERE id = $1;

-- name: GetActivityContactsByActivity :many
SELECT * FROM activity_contacts 
WHERE activity_id = $1 AND is_deleted = FALSE
ORDER BY id;

-- name: GetActivityContactsByContact :many
SELECT * FROM activity_contacts 
WHERE contact_id = $1 AND is_deleted = FALSE
ORDER BY id;

-- name: GetActivityContactsByRole :many
SELECT * FROM activity_contacts 
WHERE role = $1 AND is_deleted = FALSE
ORDER BY id;

-- name: GetActivityContactsByRecordType :many
SELECT * FROM activity_contacts 
WHERE record_type_id = $1 AND is_deleted = FALSE
ORDER BY id;

-- name: ListAllActivityContacts :many
SELECT * FROM activity_contacts 
WHERE is_deleted = FALSE
ORDER BY activity_id, id;

-- name: SearchActivityContacts :many
SELECT * FROM activity_contacts 
WHERE role ILIKE $1 AND is_deleted = FALSE
ORDER BY activity_id, id;

-- name: UpdateActivityContact :one
UPDATE activity_contacts SET
    activity_id = $2, contact_id = $3, record_type_id = $4,
    role = $5, is_deleted = $6, updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteActivityContact :exec
UPDATE activity_contacts SET is_deleted = TRUE, updated_at = NOW() WHERE id = $1;

-- name: HardDeleteActivityContact :exec
DELETE FROM activity_contacts WHERE id = $1;

-- name: CountActivityContacts :one
SELECT COUNT(*) FROM activity_contacts WHERE is_deleted = FALSE;

-- name: CountActivityContactsByActivity :one
SELECT COUNT(*) FROM activity_contacts 
WHERE activity_id = $1 AND is_deleted = FALSE;

-- name: CountActivityContactsByContact :one
SELECT COUNT(*) FROM activity_contacts 
WHERE contact_id = $1 AND is_deleted = FALSE;

-- name: CountActivityContactsByRole :one
SELECT COUNT(*) FROM activity_contacts 
WHERE role = $1 AND is_deleted = FALSE;
