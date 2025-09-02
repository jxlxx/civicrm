-- Pledge System Queries
-- Provides CRUD operations and specialized queries for pledge management

-- Pledge Blocks CRUD operations
-- name: CreatePledgeBlock :one
INSERT INTO pledge_blocks (
    name, title, description, campaign_id, is_active, start_date, end_date, goal_amount
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *;

-- name: GetPledgeBlock :one
SELECT * FROM pledge_blocks WHERE id = $1;

-- name: ListPledgeBlocks :many
SELECT * FROM pledge_blocks 
WHERE is_active = $1
ORDER BY start_date DESC;

-- name: ListPledgeBlocksByCampaign :many
SELECT * FROM pledge_blocks 
WHERE campaign_id = $1 AND is_active = $2
ORDER BY start_date DESC;

-- name: UpdatePledgeBlock :one
UPDATE pledge_blocks SET
    title = $2,
    description = $3,
    campaign_id = $4,
    is_active = $5,
    start_date = $6,
    end_date = $7,
    goal_amount = $8,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeletePledgeBlock :exec
DELETE FROM pledge_blocks WHERE id = $1;

-- Pledges CRUD operations
-- name: CreatePledge :one
INSERT INTO pledges (
    contact_id, campaign_id, pledge_block_id, amount, installments, frequency,
    frequency_interval, start_date, end_date, next_payment_date, status,
    currency, financial_type_id, payment_instrument_id, is_test
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15
) RETURNING *;

-- name: GetPledge :one
SELECT * FROM pledges WHERE id = $1;

-- name: GetPledgeByContact :one
SELECT * FROM pledges WHERE contact_id = $1 AND status = $2 LIMIT 1;

-- name: ListPledgesByContact :many
SELECT * FROM pledges 
WHERE contact_id = $1
ORDER BY created_at DESC;

-- name: ListPledgesByCampaign :many
SELECT p.*, c.first_name, c.last_name, c.email
FROM pledges p
INNER JOIN contacts c ON p.contact_id = c.id
WHERE p.campaign_id = $1 AND p.status = $2
ORDER BY p.created_at DESC;

-- name: ListPledgesByBlock :many
SELECT p.*, c.first_name, c.last_name, c.email
FROM pledges p
INNER JOIN contacts c ON p.contact_id = c.id
WHERE p.pledge_block_id = $1 AND p.status = $2
ORDER BY p.created_at DESC;

-- name: ListPledgesByStatus :many
SELECT p.*, c.first_name, c.last_name, c.email
FROM pledges p
INNER JOIN contacts c ON p.contact_id = c.id
WHERE p.status = $1
ORDER BY p.next_payment_date ASC;

-- name: UpdatePledge :one
UPDATE pledges SET
    amount = $2,
    installments = $3,
    frequency = $4,
    frequency_interval = $5,
    start_date = $6,
    end_date = $7,
    next_payment_date = $8,
    status = $9,
    currency = $10,
    financial_type_id = $11,
    payment_instrument_id = $12,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: UpdatePledgeStatus :one
UPDATE pledges SET
    status = $2,
    next_payment_date = $3,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeletePledge :exec
DELETE FROM pledges WHERE id = $1;

-- Pledge Payments CRUD operations
-- name: CreatePledgePayment :one
INSERT INTO pledge_payments (
    pledge_id, contribution_id, scheduled_amount, actual_amount,
    scheduled_date, actual_date, status
) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *;

-- name: GetPledgePayment :one
SELECT * FROM pledge_payments WHERE id = $1;

-- name: ListPledgePayments :many
SELECT * FROM pledge_payments 
WHERE pledge_id = $1
ORDER BY scheduled_date;

-- name: ListPledgePaymentsByStatus :many
SELECT pp.*, p.contact_id, c.first_name, c.last_name, c.email
FROM pledge_payments pp
INNER JOIN pledges p ON pp.pledge_id = p.id
INNER JOIN contacts c ON p.contact_id = c.id
WHERE pp.status = $1
ORDER BY pp.scheduled_date ASC;

-- name: UpdatePledgePayment :one
UPDATE pledge_payments SET
    actual_amount = $3,
    actual_date = $4,
    status = $5,
    reminder_count = $6,
    reminder_date = $7,
    updated_at = NOW()
WHERE pledge_id = $1 AND scheduled_date = $2 RETURNING *;

-- name: UpdatePledgePaymentStatus :one
UPDATE pledge_payments SET
    status = $3,
    updated_at = NOW()
WHERE pledge_id = $1 AND scheduled_date = $2 RETURNING *;

-- name: DeletePledgePayment :exec
DELETE FROM pledge_payments WHERE id = $1;

-- Pledge Logs CRUD operations
-- name: CreatePledgeLog :one
INSERT INTO pledge_logs (
    pledge_id, action, description, amount_before, amount_after,
    status_before, status_after, created_by
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *;

-- name: GetPledgeLogs :many
SELECT * FROM pledge_logs 
WHERE pledge_id = $1
ORDER BY created_at DESC;

-- name: ListPledgeLogsByUser :many
SELECT pl.*, p.contact_id, c.first_name, c.last_name
FROM pledge_logs pl
INNER JOIN pledges p ON pl.pledge_id = p.id
INNER JOIN contacts c ON p.contact_id = c.id
WHERE pl.created_by = $1
ORDER BY pl.created_at DESC
LIMIT $2;

-- Pledge Reminders CRUD operations
-- name: CreatePledgeReminder :one
INSERT INTO pledge_reminders (
    pledge_id, pledge_payment_id, reminder_type, scheduled_date,
    message_template_id
) VALUES ($1, $2, $3, $4, $5) RETURNING *;

-- name: GetPledgeReminder :one
SELECT * FROM pledge_reminders WHERE id = $1;

-- name: ListPledgeReminders :many
SELECT * FROM pledge_reminders 
WHERE pledge_id = $1 AND status = $2
ORDER BY scheduled_date;

-- name: ListScheduledReminders :many
SELECT pr.*, p.contact_id, c.first_name, c.last_name, c.email
FROM pledge_reminders pr
INNER JOIN pledges p ON pr.pledge_id = p.id
INNER JOIN contacts c ON p.contact_id = c.id
WHERE pr.status = 'Scheduled' AND pr.scheduled_date <= $1
ORDER BY pr.scheduled_date;

-- name: UpdateReminderStatus :one
UPDATE pledge_reminders SET
    status = $2,
    sent_date = $3,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeletePledgeReminder :exec
DELETE FROM pledge_reminders WHERE id = $1;

-- Pledge Groups CRUD operations
-- name: CreatePledgeGroup :one
INSERT INTO pledge_groups (
    name, description, goal_amount, current_amount, is_active
) VALUES ($1, $2, $3, $4, $5) RETURNING *;

-- name: GetPledgeGroup :one
SELECT * FROM pledge_groups WHERE id = $1;

-- name: ListPledgeGroups :many
SELECT * FROM pledge_groups 
WHERE is_active = $1
ORDER BY name;

-- name: UpdatePledgeGroup :one
UPDATE pledge_groups SET
    description = $2,
    goal_amount = $3,
    current_amount = $4,
    is_active = $5,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: UpdatePledgeGroupAmount :one
UPDATE pledge_groups SET
    current_amount = $2,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeletePledgeGroup :exec
DELETE FROM pledge_groups WHERE id = $1;

-- Pledge Group Members CRUD operations
-- name: CreatePledgeGroupMember :one
INSERT INTO pledge_group_members (
    pledge_group_id, contact_id, pledge_id, role
) VALUES ($1, $2, $3, $4) RETURNING *;

-- name: GetPledgeGroupMember :one
SELECT * FROM pledge_group_members WHERE id = $1;

-- name: ListPledgeGroupMembers :many
SELECT pgm.*, c.first_name, c.last_name, c.email
FROM pledge_group_members pgm
INNER JOIN contacts c ON pgm.contact_id = c.id
WHERE pgm.pledge_group_id = $1 AND pgm.is_active = $2
ORDER BY pgm.role, c.last_name, c.first_name;

-- name: UpdatePledgeGroupMember :one
UPDATE pledge_group_members SET
    role = $3,
    is_active = $4,
    updated_at = NOW()
WHERE pledge_group_id = $1 AND contact_id = $2 RETURNING *;

-- name: DeletePledgeGroupMember :exec
DELETE FROM pledge_group_members WHERE id = $1;

-- Specialized queries for pledge system
-- name: GetPledgeSummary :one
SELECT 
    COUNT(*) as total_pledges,
    COUNT(CASE WHEN status = 'Pending' THEN 1 END) as pending_pledges,
    COUNT(CASE WHEN status = 'In Progress' THEN 1 END) as active_pledges,
    COUNT(CASE WHEN status = 'Overdue' THEN 1 END) as overdue_pledges,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) as completed_pledges,
    SUM(amount) as total_pledged_amount,
    SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END) as total_completed_amount
FROM pledges
WHERE campaign_id = $1;

-- name: GetPledgePaymentSchedule :many
SELECT 
    pp.scheduled_date,
    pp.scheduled_amount,
    pp.status,
    p.contact_id,
    c.first_name,
    c.last_name,
    c.email
FROM pledge_payments pp
INNER JOIN pledges p ON pp.pledge_id = p.id
INNER JOIN contacts c ON p.contact_id = c.id
WHERE pp.pledge_id = $1
ORDER BY pp.scheduled_date;

-- name: GetOverduePledges :many
SELECT 
    p.*,
    c.first_name,
    c.last_name,
    c.email,
    pp.scheduled_date as next_payment_date,
    pp.scheduled_amount as next_payment_amount
FROM pledges p
INNER JOIN contacts c ON p.contact_id = c.id
INNER JOIN pledge_payments pp ON p.id = pp.pledge_id
WHERE p.status = 'In Progress' 
  AND pp.status = 'Scheduled' 
  AND pp.scheduled_date < $1
ORDER BY pp.scheduled_date ASC;

-- name: GetPledgePerformance :many
SELECT 
    DATE_TRUNC('month', p.created_at) as month,
    COUNT(*) as new_pledges,
    SUM(p.amount) as pledged_amount,
    COUNT(CASE WHEN p.status = 'Completed' THEN 1 END) as completed_pledges,
    SUM(CASE WHEN p.status = 'Completed' THEN p.amount ELSE 0 END) as completed_amount
FROM pledges p
WHERE p.created_at >= $1
GROUP BY DATE_TRUNC('month', p.created_at)
ORDER BY month;

-- name: GetPledgeGroupProgress :many
SELECT 
    pg.name,
    pg.goal_amount,
    pg.current_amount,
    ROUND((pg.current_amount / pg.goal_amount) * 100, 2) as progress_percentage,
    COUNT(pgm.contact_id) as member_count
FROM pledge_groups pg
LEFT JOIN pledge_group_members pgm ON pg.id = pgm.pledge_group_id AND pgm.is_active = true
WHERE pg.is_active = $1
GROUP BY pg.id, pg.name, pg.goal_amount, pg.current_amount
ORDER BY progress_percentage DESC;

-- name: GetPledgeReminderQueue :many
SELECT 
    pr.*,
    p.contact_id,
    c.first_name,
    c.last_name,
    c.email,
    p.amount as pledge_amount,
    p.frequency
FROM pledge_reminders pr
INNER JOIN pledges p ON pr.pledge_id = p.id
INNER JOIN contacts c ON p.contact_id = c.id
WHERE pr.status = 'Scheduled' 
  AND pr.scheduled_date <= $1
  AND p.status IN ('In Progress', 'Overdue')
ORDER BY pr.scheduled_date ASC;

-- name: CountPledgesByStatus :one
SELECT 
    COUNT(CASE WHEN status = 'Pending' THEN 1 END) as pending_count,
    COUNT(CASE WHEN status = 'In Progress' THEN 1 END) as in_progress_count,
    COUNT(CASE WHEN status = 'Overdue' THEN 1 END) as overdue_count,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) as completed_count,
    COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) as cancelled_count
FROM pledges
WHERE campaign_id = $1;
