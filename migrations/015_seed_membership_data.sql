-- Seed data for membership system
-- This provides initial data needed for the membership system to function

-- Membership types (common CiviCRM membership types)
INSERT INTO membership_types (name, description, duration_unit, duration_interval, period_type, visibility, weight, is_active) VALUES
    ('Individual', 'Individual membership for one person', 'year', 1, 'rolling', 'Public', 1, TRUE),
    ('Family', 'Family membership covering multiple household members', 'year', 1, 'rolling', 'Public', 2, TRUE),
    ('Student', 'Discounted membership for students', 'year', 1, 'rolling', 'Public', 3, TRUE),
    ('Senior', 'Discounted membership for seniors (65+)', 'year', 1, 'rolling', 'Public', 4, TRUE),
    ('Corporate', 'Corporate membership for businesses', 'year', 1, 'rolling', 'Public', 5, TRUE),
    ('Lifetime', 'One-time lifetime membership', 'year', 999, 'rolling', 'Public', 6, TRUE),
    ('Monthly', 'Monthly recurring membership', 'month', 1, 'rolling', 'Public', 7, TRUE),
    ('Quarterly', 'Quarterly membership', 'month', 3, 'rolling', 'Public', 8, TRUE),
    ('Academic Year', 'Academic year membership (Sept-June)', 'month', 10, 'fixed', 'Public', 9, TRUE),
    ('Calendar Year', 'Calendar year membership (Jan-Dec)', 'month', 12, 'fixed', 'Public', 10, TRUE);

-- Membership status (core CiviCRM membership statuses)
INSERT INTO membership_status (name, label, start_event, end_event, is_current_member, is_admin, weight, is_active) VALUES
    ('New', 'New', 'join', NULL, TRUE, FALSE, 1, TRUE),
    ('Current', 'Current', 'start', 'end', TRUE, FALSE, 2, TRUE),
    ('Grace', 'Grace', 'start', 'end', TRUE, FALSE, 3, TRUE),
    ('Expired', 'Expired', 'start', 'end', FALSE, FALSE, 4, TRUE),
    ('Cancelled', 'Cancelled', 'start', 'leave', FALSE, FALSE, 5, TRUE),
    ('Pending', 'Pending', 'join', 'start', FALSE, FALSE, 6, TRUE),
    ('Overdue', 'Overdue', 'start', 'end', FALSE, FALSE, 7, TRUE),
    ('Terminated', 'Terminated', 'start', 'leave', FALSE, FALSE, 8, TRUE),
    ('Deceased', 'Deceased', 'start', 'leave', FALSE, FALSE, 9, TRUE),
    ('Transferred', 'Transferred', 'start', 'leave', FALSE, FALSE, 10, TRUE);

-- Set fixed period start days for academic and calendar year memberships
UPDATE membership_types SET 
    fixed_period_start_day = 1,  -- January 1st for calendar year
    fixed_period_rollover_day = 31 -- January 31st for rollover
WHERE name = 'Calendar Year';

UPDATE membership_types SET 
    fixed_period_start_day = 244,  -- September 1st for academic year (day 244 of year)
    fixed_period_rollover_day = 274 -- October 1st for rollover (day 274 of year)
WHERE name = 'Academic Year';
