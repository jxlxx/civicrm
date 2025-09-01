-- name: CreateEventRegistration :one
INSERT INTO event_registrations (
    event_id, contact_id, status
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: GetEventRegistration :one
SELECT * FROM event_registrations WHERE id = $1;

-- name: GetEventRegistrationByEventAndContact :one
SELECT * FROM event_registrations 
WHERE event_id = $1 AND contact_id = $2;

-- name: GetRegistrationsByEvent :many
SELECT 
    er.*,
    e.title as event_title,
    e.start_date as event_start_date,
    e.location as event_location,
    c.contact_type,
    c.first_name,
    c.last_name,
    c.organization_name,
    c.email
FROM event_registrations er
JOIN events e ON er.event_id = e.id
JOIN contacts c ON er.contact_id = c.id
WHERE er.event_id = $1
ORDER BY er.registration_date ASC;

-- name: GetRegistrationsByContact :many
SELECT 
    er.*,
    e.title as event_title,
    e.start_date as event_start_date,
    e.location as event_location
FROM event_registrations er
JOIN events e ON er.event_id = e.id
WHERE er.contact_id = $1
ORDER BY e.start_date DESC;

-- name: ListAllRegistrations :many
SELECT 
    er.*,
    e.title as event_title,
    e.start_date as event_start_date,
    e.location as event_location,
    c.contact_type,
    c.first_name,
    c.last_name,
    c.organization_name,
    c.email
FROM event_registrations er
JOIN events e ON er.event_id = e.id
JOIN contacts c ON er.contact_id = c.id
ORDER BY er.registration_date DESC 
LIMIT $1 OFFSET $2;

-- name: ListRegistrationsByStatus :many
SELECT 
    er.*,
    e.title as event_title,
    e.start_date as event_start_date,
    e.location as event_location,
    c.contact_type,
    c.first_name,
    c.last_name,
    c.organization_name,
    c.email
FROM event_registrations er
JOIN events e ON er.event_id = e.id
JOIN contacts c ON er.contact_id = c.id
WHERE er.status = $1
ORDER BY er.registration_date DESC 
LIMIT $2 OFFSET $3;

-- name: UpdateEventRegistration :one
UPDATE event_registrations 
SET 
    status = $2,
    updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- name: DeleteEventRegistration :exec
DELETE FROM event_registrations WHERE id = $1;

-- name: CountRegistrations :one
SELECT COUNT(*) FROM event_registrations;

-- name: CountRegistrationsByEvent :one
SELECT COUNT(*) FROM event_registrations WHERE event_id = $1;

-- name: CountRegistrationsByContact :one
SELECT COUNT(*) FROM event_registrations WHERE contact_id = $1;

-- name: CountRegistrationsByStatus :one
SELECT COUNT(*) FROM event_registrations WHERE status = $1;

-- name: GetUpcomingRegistrations :many
SELECT 
    er.*,
    e.title as event_title,
    e.start_date as event_start_date,
    e.location as event_location,
    c.contact_type,
    c.first_name,
    c.last_name,
    c.organization_name,
    c.email
FROM event_registrations er
JOIN events e ON er.event_id = e.id
JOIN contacts c ON er.contact_id = c.id
WHERE e.start_date > NOW()
ORDER BY e.start_date ASC;

-- name: GetPastRegistrations :many
SELECT 
    er.*,
    e.title as event_title,
    e.start_date as event_start_date,
    e.location as event_location,
    c.contact_type,
    c.first_name,
    c.last_name,
    c.organization_name,
    c.email
FROM event_registrations er
JOIN events e ON er.event_id = e.id
JOIN contacts c ON er.contact_id = c.id
WHERE e.end_date < NOW()
ORDER BY e.start_date DESC;
