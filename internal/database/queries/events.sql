-- name: CreateEvent :one
INSERT INTO events (
    title, description, start_date, end_date, 
    location, max_participants
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetEvent :one
SELECT * FROM events WHERE id = $1;

-- name: GetEventByTitle :one
SELECT * FROM events WHERE title = $1;

-- name: ListEvents :many
SELECT * FROM events 
ORDER BY start_date ASC 
LIMIT $1 OFFSET $2;

-- name: ListUpcomingEvents :many
SELECT * FROM events 
WHERE start_date > NOW() 
ORDER BY start_date ASC 
LIMIT $1 OFFSET $2;

-- name: ListPastEvents :many
SELECT * FROM events 
WHERE end_date < NOW() 
ORDER BY start_date DESC 
LIMIT $1 OFFSET $2;

-- name: SearchEvents :many
SELECT * FROM events 
WHERE (
    title ILIKE $1 OR 
    description ILIKE $1 OR 
    location ILIKE $1
)
ORDER BY start_date ASC 
LIMIT $2 OFFSET $3;

-- name: UpdateEvent :one
UPDATE events 
SET 
    title = $2,
    description = $3,
    start_date = $4,
    end_date = $5,
    location = $6,
    max_participants = $7,
    updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- name: DeleteEvent :exec
DELETE FROM events WHERE id = $1;

-- name: CountEvents :one
SELECT COUNT(*) FROM events;

-- name: CountUpcomingEvents :one
SELECT COUNT(*) FROM events WHERE start_date > NOW();

-- name: GetEventsByDateRange :many
SELECT * FROM events 
WHERE start_date >= $1 AND end_date <= $2 
ORDER BY start_date ASC;
