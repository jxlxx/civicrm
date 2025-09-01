-- name: CreateReportResult :one
INSERT INTO report_results (
    report_instance_id, execution_date, result_data, row_count, execution_time_ms, status, error_message
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetReportResult :one
SELECT * FROM report_results WHERE id = $1;

-- name: GetReportResultsByInstance :many
SELECT * FROM report_results 
WHERE report_instance_id = $1 
ORDER BY execution_date DESC;

-- name: GetReportResultsByStatus :many
SELECT * FROM report_results 
WHERE report_instance_id = $1 AND status = $2 
ORDER BY execution_date DESC;

-- name: GetLatestReportResult :one
SELECT * FROM report_results 
WHERE report_instance_id = $1 
ORDER BY execution_date DESC LIMIT 1;

-- name: GetReportResultsByDateRange :many
SELECT * FROM report_results 
WHERE report_instance_id = $1 AND execution_date >= $2 AND execution_date <= $3 
ORDER BY execution_date DESC;

-- name: ListReportResults :many
SELECT * FROM report_results 
ORDER BY execution_date DESC;

-- name: ListReportResultsByDateRange :many
SELECT * FROM report_results 
WHERE execution_date >= $1 AND execution_date <= $2 
ORDER BY execution_date DESC;

-- name: ListFailedReportResults :many
SELECT * FROM report_results 
WHERE status = 'Failed' 
ORDER BY execution_date DESC;

-- name: SearchReportResults :many
SELECT rr.* FROM report_results rr
JOIN report_instances ri ON rr.report_instance_id = ri.id
WHERE ri.name ILIKE $1 
ORDER BY rr.execution_date DESC;

-- name: UpdateReportResult :one
UPDATE report_results SET
    report_instance_id = $2, execution_date = $3, result_data = $4,
    row_count = $5, execution_time_ms = $6, status = $7, error_message = $8
WHERE id = $1 RETURNING *;

-- name: DeleteReportResult :exec
DELETE FROM report_results WHERE id = $1;

-- name: DeleteReportResultsByInstance :exec
DELETE FROM report_results WHERE report_instance_id = $1;

-- name: UpdateReportResultStatus :exec
UPDATE report_results SET status = $2 WHERE id = $1;

-- name: MarkReportResultCompleted :exec
UPDATE report_results SET status = 'Completed' WHERE id = $1;

-- name: MarkReportResultFailed :exec
UPDATE report_results SET status = 'Failed', error_message = $2 WHERE id = $1;

-- name: GetReportResultStats :many
SELECT 
    rr.status,
    COUNT(rr.id) as result_count,
    AVG(rr.execution_time_ms) as avg_execution_time,
    AVG(rr.row_count) as avg_row_count
FROM report_results rr
WHERE rr.report_instance_id = $1
GROUP BY rr.status
ORDER BY rr.status;

-- name: GetReportPerformanceStats :many
SELECT 
    ri.name as instance_name,
    COUNT(rr.id) as execution_count,
    AVG(rr.execution_time_ms) as avg_execution_time,
    AVG(rr.row_count) as avg_row_count,
    COUNT(CASE WHEN rr.status = 'Completed' THEN 1 END) as success_count,
    COUNT(CASE WHEN rr.status = 'Failed' THEN 1 END) as failure_count
FROM report_results rr
JOIN report_instances ri ON rr.report_instance_id = ri.id
WHERE rr.execution_date >= $1
GROUP BY ri.id, ri.name
ORDER BY execution_count DESC;
