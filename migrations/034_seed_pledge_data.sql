-- Migration: 034_seed_pledge_data.sql
-- Description: Seed data for pledge system with sample pledge blocks and groups
-- Date: 2024-12-19

-- Seed Pledge Blocks for common fundraising campaigns
INSERT INTO pledge_blocks (name, title, description, campaign_id, is_active, start_date, end_date, goal_amount)
SELECT 
    'annual_fund_2024',
    'Annual Fund 2024',
    'Our annual fundraising campaign to support our core programs and services',
    c.id,
    true,
    '2024-01-01',
    '2024-12-31',
    100000.00
FROM campaigns c
WHERE c.name = 'Annual Fund 2024'
LIMIT 1;

INSERT INTO pledge_blocks (name, title, description, campaign_id, is_active, start_date, end_date, goal_amount)
SELECT 
    'capital_campaign_2024',
    'Capital Campaign 2024',
    'Building for the future - help us expand our facilities',
    c.id,
    true,
    '2024-06-01',
    '2026-05-31',
    500000.00
FROM campaigns c
WHERE c.name = 'Capital Campaign 2024'
LIMIT 1;

INSERT INTO pledge_blocks (name, title, description, campaign_id, is_active, start_date, end_date, goal_amount)
SELECT 
    'emergency_fund_2024',
    'Emergency Fund 2024',
    'Support for urgent community needs and crisis response',
    c.id,
    true,
    '2024-01-01',
    '2024-12-31',
    25000.00
FROM campaigns c
WHERE c.name = 'Emergency Fund 2024'
LIMIT 1;

-- If no campaigns exist, create default pledge blocks
INSERT INTO pledge_blocks (name, title, description, is_active, start_date, end_date, goal_amount)
SELECT 
    'annual_fund_2024',
    'Annual Fund 2024',
    'Our annual fundraising campaign to support our core programs and services',
    true,
    '2024-01-01',
    '2024-12-31',
    100000.00
WHERE NOT EXISTS (SELECT 1 FROM pledge_blocks WHERE name = 'annual_fund_2024');

INSERT INTO pledge_blocks (name, title, description, is_active, start_date, end_date, goal_amount)
SELECT 
    'capital_campaign_2024',
    'Capital Campaign 2024',
    'Building for the future - help us expand our facilities',
    true,
    '2024-06-01',
    '2026-05-31',
    500000.00
WHERE NOT EXISTS (SELECT 1 FROM pledge_blocks WHERE name = 'capital_campaign_2024');

INSERT INTO pledge_blocks (name, title, description, is_active, start_date, end_date, goal_amount)
SELECT 
    'emergency_fund_2024',
    'Emergency Fund 2024',
    'Support for urgent community needs and crisis response',
    true,
    '2024-01-01',
    '2024-12-31',
    25000.00
WHERE NOT EXISTS (SELECT 1 FROM pledge_blocks WHERE name = 'emergency_fund_2024');

-- Seed Pledge Groups for team fundraising
INSERT INTO pledge_groups (name, description, goal_amount, current_amount, is_active) VALUES
    ('board_members', 'Board of Directors Fundraising Team', 50000.00, 0.00, true),
    ('volunteer_leaders', 'Volunteer Leadership Team', 25000.00, 0.00, true),
    ('staff_team', 'Staff Fundraising Team', 15000.00, 0.00, true),
    ('youth_ambassadors', 'Youth Ambassador Program', 10000.00, 0.00, true),
    ('corporate_partners', 'Corporate Partnership Team', 100000.00, 0.00, true);

-- Seed sample pledges (using existing contacts)
-- Note: This assumes you have some contacts in your system already
-- You may need to adjust the contact IDs based on your actual data

-- Create sample pledges for the annual fund
INSERT INTO pledges (contact_id, pledge_block_id, amount, installments, frequency, frequency_interval, start_date, end_date, next_payment_date, status, currency, is_test)
SELECT 
    c.id,
    pb.id,
    1200.00, -- $100/month for 12 months
    12,
    'Monthly',
    1,
    '2024-01-01',
    '2024-12-31',
    '2024-01-01',
    'In Progress',
    'USD',
    false
FROM contacts c
CROSS JOIN pledge_blocks pb
WHERE c.contact_type = 'Individual'
  AND c.email IS NOT NULL
  AND pb.name = 'annual_fund_2024'
LIMIT 3;

INSERT INTO pledges (contact_id, pledge_block_id, amount, installments, frequency, frequency_interval, start_date, end_date, next_payment_date, status, currency, is_test)
SELECT 
    c.id,
    pb.id,
    600.00, -- $50/month for 12 months
    12,
    'Monthly',
    1,
    '2024-01-01',
    '2024-12-31',
    '2024-01-01',
    'In Progress',
    'USD',
    false
FROM contacts c
CROSS JOIN pledge_blocks pb
WHERE c.contact_type = 'Individual'
  AND c.email IS NOT NULL
  AND pb.name = 'annual_fund_2024'
LIMIT 2;

-- Create sample pledges for the capital campaign
INSERT INTO pledges (contact_id, pledge_block_id, amount, installments, frequency, frequency_interval, start_date, end_date, next_payment_date, status, currency, is_test)
SELECT 
    c.id,
    pb.id,
    5000.00, -- $500/month for 10 months
    10,
    'Monthly',
    1,
    '2024-06-01',
    '2025-03-31',
    '2024-06-01',
    'In Progress',
    'USD',
    false
FROM contacts c
CROSS JOIN pledge_blocks pb
WHERE c.contact_type = 'Individual'
  AND c.email IS NOT NULL
  AND pb.name = 'capital_campaign_2024'
LIMIT 2;

-- Create sample pledges for the emergency fund
INSERT INTO pledges (contact_id, pledge_block_id, amount, installments, frequency, frequency_interval, start_date, end_date, next_payment_date, status, currency, is_test)
SELECT 
    c.id,
    pb.id,
    500.00, -- $100/month for 5 months
    5,
    'Monthly',
    1,
    '2024-01-01',
    '2024-05-31',
    '2024-01-01',
    'In Progress',
    'USD',
    false
FROM contacts c
CROSS JOIN pledge_blocks pb
WHERE c.contact_type = 'Individual'
  AND c.email IS NOT NULL
  AND pb.name = 'emergency_fund_2024'
LIMIT 2;

-- Create sample pledge payments for existing pledges
INSERT INTO pledge_payments (pledge_id, scheduled_amount, scheduled_date, status)
SELECT 
    p.id,
    p.amount / p.installments,
    p.start_date + (INTERVAL '1 month' * (ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY p.start_date) - 1)),
    'Scheduled'
FROM pledges p
WHERE p.status = 'In Progress'
  AND p.installments > 1;

-- Create sample pledge logs for audit trail
INSERT INTO pledge_logs (pledge_id, action, description, amount_before, amount_after, status_before, status_after, created_by)
SELECT 
    p.id,
    'Created',
    'Pledge created for ' || pb.title,
    NULL,
    p.amount,
    NULL,
    p.status,
    u.id
FROM pledges p
INNER JOIN pledge_blocks pb ON p.pledge_block_id = pb.id
CROSS JOIN users u
WHERE u.is_admin = true
LIMIT 1;

-- Create sample pledge reminders
INSERT INTO pledge_reminders (pledge_id, pledge_payment_id, reminder_type, scheduled_date, message_template_id)
SELECT 
    p.id,
    pp.id,
    'Payment Due',
    pp.scheduled_date - INTERVAL '3 days',
    mt.id
FROM pledges p
INNER JOIN pledge_payments pp ON p.id = pp.pledge_id
CROSS JOIN message_templates mt
WHERE p.status = 'In Progress'
  AND pp.status = 'Scheduled'
  AND mt.name = 'pledge_reminder'
LIMIT 5;

-- Create sample pledge group members
-- Use ROW_NUMBER() to ensure unique group-contact combinations
INSERT INTO pledge_group_members (pledge_group_id, contact_id, pledge_id, role, is_active)
SELECT 
    pg.id,
    c.id,
    p.id,
    'Leader',
    true
FROM (
    SELECT pg.id, pg.name, ROW_NUMBER() OVER (ORDER BY pg.id) as rn
    FROM pledge_groups pg
    WHERE pg.name = 'board_members'
) pg
CROSS JOIN (
    SELECT c.id, ROW_NUMBER() OVER (ORDER BY c.id) as rn
    FROM contacts c
    WHERE c.contact_type = 'Individual'
    AND c.email IS NOT NULL
) c
CROSS JOIN (
    SELECT p.id, ROW_NUMBER() OVER (ORDER BY p.id) as rn
    FROM pledges p
    WHERE p.status = 'In Progress'
) p
WHERE pg.rn = 1 
  AND c.rn <= 2 
  AND p.rn = 1
  AND NOT EXISTS (
    SELECT 1 FROM pledge_group_members pgm 
    WHERE pgm.pledge_group_id = pg.id AND pgm.contact_id = c.id
  );

INSERT INTO pledge_group_members (pledge_group_id, contact_id, pledge_id, role, is_active)
SELECT 
    pg.id,
    c.id,
    p.id,
    'Member',
    true
FROM (
    SELECT pg.id, pg.name, ROW_NUMBER() OVER (ORDER BY pg.id) as rn
    FROM pledge_groups pg
    WHERE pg.name = 'volunteer_leaders'
) pg
CROSS JOIN (
    SELECT c.id, ROW_NUMBER() OVER (ORDER BY c.id) as rn
    FROM contacts c
    WHERE c.contact_type = 'Individual'
    AND c.email IS NOT NULL
) c
CROSS JOIN (
    SELECT p.id, ROW_NUMBER() OVER (ORDER BY p.id) as rn
    FROM pledges p
    WHERE p.status = 'In Progress'
) p
WHERE pg.rn = 1 
  AND c.rn <= 3 
  AND p.rn = 1
  AND NOT EXISTS (
    SELECT 1 FROM pledge_group_members pgm 
    WHERE pgm.pledge_group_id = pg.id AND pgm.contact_id = c.id
  );

INSERT INTO pledge_group_members (pledge_group_id, contact_id, pledge_id, role, is_active)
SELECT 
    pg.id,
    c.id,
    p.id,
    'Member',
    true
FROM (
    SELECT pg.id, pg.name, ROW_NUMBER() OVER (ORDER BY pg.id) as rn
    FROM pledge_groups pg
    WHERE pg.name = 'staff_team'
) pg
CROSS JOIN (
    SELECT c.id, ROW_NUMBER() OVER (ORDER BY c.id) as rn
    FROM contacts c
    WHERE c.contact_type = 'Individual'
    AND c.email IS NOT NULL
) c
CROSS JOIN (
    SELECT p.id, ROW_NUMBER() OVER (ORDER BY p.id) as rn
    FROM pledges p
    WHERE p.status = 'In Progress'
) p
WHERE pg.rn = 1 
  AND c.rn <= 2 
  AND p.rn = 1
  AND NOT EXISTS (
    SELECT 1 FROM pledge_group_members pgm 
    WHERE pgm.pledge_group_id = pg.id AND pgm.contact_id = c.id
  );

-- Update pledge group current amounts based on pledges
UPDATE pledge_groups 
SET current_amount = (
    SELECT COALESCE(SUM(p.amount), 0.00)
    FROM pledges p
    INNER JOIN pledge_group_members pgm ON p.contact_id = pgm.contact_id
    WHERE pgm.pledge_group_id = pledge_groups.id
      AND p.status = 'In Progress'
)
WHERE id IN (SELECT id FROM pledge_groups);

-- Create sample pledge logs for status changes
INSERT INTO pledge_logs (pledge_id, action, description, amount_before, amount_after, status_before, status_after, created_by)
SELECT 
    p.id,
    'Status Changed',
    'Pledge status updated to ' || p.status,
    0.00, -- amount_before should be numeric
    p.amount, -- amount_after should be the pledge amount
    'Pending',
    p.status,
    u.id
FROM pledges p
CROSS JOIN users u
WHERE p.status = 'In Progress'
  AND u.is_admin = true
LIMIT 3;
