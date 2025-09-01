-- name: CreateJob :one
INSERT INTO jobs (
    domain_id, name, description, job_type, parameters, schedule, is_active
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetJob :one
SELECT * FROM jobs WHERE id = $1;

-- name: GetJobByName :one
SELECT * FROM jobs WHERE domain_id = $1 AND name = $2;

-- name: ListJobsByDomain :many
SELECT * FROM jobs 
WHERE domain_id = $1 
ORDER BY name ASC;

-- name: ListActiveJobsByDomain :many
SELECT * FROM jobs 
WHERE domain_id = $1 AND is_active = TRUE 
ORDER BY name ASC;

-- name: ListJobsByType :many
SELECT * FROM jobs 
WHERE domain_id = $1 AND job_type = $2 
ORDER BY name ASC;

-- name: ListScheduledJobs :many
SELECT * FROM jobs 
WHERE domain_id = $1 AND schedule IS NOT NULL AND is_active = TRUE 
ORDER BY next_run ASC;

-- name: ListAllJobs :many
SELECT j.*, d.name as domain_name FROM jobs j
INNER JOIN domains d ON j.domain_id = d.id
ORDER BY d.name ASC, j.name ASC;

-- name: UpdateJob :one
UPDATE jobs 
SET 
    name = $3,
    description = $4,
    job_type = $5,
    parameters = $6,
    schedule = $7,
    is_active = $8,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: UpdateJobStatus :one
UPDATE jobs 
SET 
    is_active = $3,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: UpdateJobSchedule :one
UPDATE jobs 
SET 
    schedule = $3,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: UpdateJobLastRun :one
UPDATE jobs 
SET 
    last_run = $3,
    next_run = $4,
    updated_at = NOW()
WHERE id = $1 AND domain_id = $2 
RETURNING *;

-- name: DeleteJob :exec
DELETE FROM jobs WHERE id = $1 AND domain_id = $2;

-- name: DeleteJobsByDomain :exec
DELETE FROM jobs WHERE domain_id = $1;

-- name: CountJobsByDomain :one
SELECT COUNT(*) FROM jobs WHERE domain_id = $1;

-- name: CountActiveJobsByDomain :one
SELECT COUNT(*) FROM jobs WHERE domain_id = $1 AND is_active = TRUE;

-- name: CountScheduledJobsByDomain :one
SELECT COUNT(*) FROM jobs WHERE domain_id = $1 AND schedule IS NOT NULL AND is_active = TRUE;

-- name: SearchJobs :many
SELECT j.*, d.name as domain_name FROM jobs j
INNER JOIN domains d ON j.domain_id = d.id
WHERE j.name ILIKE $1 OR j.description ILIKE $1 OR j.job_type ILIKE $1
ORDER BY d.name ASC, j.name ASC
LIMIT $2 OFFSET $3;

-- name: GetJobsDueForExecution :many
SELECT * FROM jobs 
WHERE domain_id = $1 
AND is_active = TRUE 
AND schedule IS NOT NULL 
AND (next_run IS NULL OR next_run <= NOW())
ORDER BY next_run ASC, name ASC;

-- name: GetJobWithLogs :many
SELECT j.*, jl.* FROM jobs j
LEFT JOIN job_logs jl ON j.id = jl.job_id
WHERE j.id = $1
ORDER BY jl.started_at DESC;

-- name: GetJobExecutionStats :one
SELECT 
    COUNT(*) as total_executions,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful_executions,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_executions,
    AVG(execution_time_ms) as avg_execution_time,
    MAX(execution_time_ms) as max_execution_time,
    MIN(execution_time_ms) as min_execution_time
FROM job_logs 
WHERE job_id = $1;

-- name: CleanupOldJobLogs :exec
DELETE FROM job_logs 
WHERE job_id = $1 
AND started_at < NOW() - INTERVAL '30 days';

-- name: GetJobPerformanceMetrics :many
SELECT 
    DATE(started_at) as execution_date,
    COUNT(*) as execution_count,
    AVG(execution_time_ms) as avg_execution_time,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failure_count
FROM job_logs 
WHERE job_id = $1 
AND started_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(started_at)
ORDER BY execution_date DESC;
