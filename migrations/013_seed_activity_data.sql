-- Seed data for activity system
-- This provides initial data needed for the activity system to function

-- Activity types (core CiviCRM activity types)
INSERT INTO activity_types (name, label, description, icon, is_reserved) VALUES
    ('Meeting', 'Meeting', 'Face-to-face meeting with contact', 'fa-users', TRUE),
    ('Phone Call', 'Phone Call', 'Phone conversation with contact', 'fa-phone', TRUE),
    ('Email', 'Email', 'Email communication with contact', 'fa-envelope', TRUE),
    ('SMS', 'SMS', 'Text message communication', 'fa-comment', TRUE),
    ('Letter', 'Letter', 'Written letter to contact', 'fa-file-text', TRUE),
    ('Fax', 'Fax', 'Fax communication', 'fa-fax', TRUE),
    ('Interview', 'Interview', 'Interview with contact', 'fa-microphone', TRUE),
    ('Survey', 'Survey', 'Survey response from contact', 'fa-clipboard-list', TRUE),
    ('Contribution', 'Contribution', 'Financial contribution', 'fa-gift', TRUE),
    ('Membership', 'Membership', 'Membership activity', 'fa-id-card', TRUE),
    ('Event', 'Event', 'Event-related activity', 'fa-calendar', TRUE),
    ('Case', 'Case', 'Case management activity', 'fa-folder-open', TRUE),
    ('Campaign', 'Campaign', 'Campaign-related activity', 'fa-bullhorn', TRUE),
    ('Grant', 'Grant', 'Grant-related activity', 'fa-handshake', TRUE),
    ('Pledge', 'Pledge', 'Pledge-related activity', 'fa-hand-holding-usd', TRUE),
    ('Volunteer', 'Volunteer', 'Volunteer activity', 'fa-hands-helping', TRUE),
    ('Print/Merge Document', 'Print/Merge Document', 'Document generation', 'fa-print', TRUE),
    ('Tell a Friend', 'Tell a Friend', 'Referral activity', 'fa-share', TRUE),
    ('Change Case Type', 'Change Case Type', 'Case type modification', 'fa-exchange-alt', TRUE),
    ('Change Case Status', 'Change Case Status', 'Case status modification', 'fa-toggle-on', TRUE),
    ('Change Case Start Date', 'Change Case Start Date', 'Case start date modification', 'fa-calendar-plus', TRUE),
    ('Change Case End Date', 'Change Case End Date', 'Case end date modification', 'fa-calendar-minus', TRUE),
    ('Change Case Subject', 'Change Case Subject', 'Case subject modification', 'fa-edit', TRUE),
    ('Change Case Role', 'Change Case Role', 'Case role modification', 'fa-user-edit', TRUE);

-- Activity status
INSERT INTO activity_status (name, label, weight, is_reserved) VALUES
    ('Scheduled', 'Scheduled', 1, TRUE),
    ('Completed', 'Completed', 2, TRUE),
    ('Cancelled', 'Cancelled', 3, TRUE),
    ('Left Message', 'Left Message', 4, TRUE),
    ('No Show', 'No Show', 5, TRUE),
    ('Available', 'Available', 6, TRUE),
    ('Unavailable', 'Unavailable', 7, TRUE),
    ('Tentative', 'Tentative', 8, TRUE),
    ('In Progress', 'In Progress', 9, TRUE),
    ('Waiting', 'Waiting', 10, TRUE),
    ('Overdue', 'Overdue', 11, TRUE),
    ('Draft', 'Draft', 12, TRUE),
    ('Sent', 'Sent', 13, TRUE),
    ('Opened', 'Opened', 14, TRUE),
    ('Bounced', 'Bounced', 15, TRUE),
    ('Replied', 'Replied', 16, TRUE),
    ('Forwarded', 'Forwarded', 17, TRUE),
    ('Pending', 'Pending', 18, TRUE),
    ('Approved', 'Approved', 19, TRUE),
    ('Rejected', 'Rejected', 20, TRUE);

-- Activity priority
INSERT INTO activity_priority (name, label, weight, is_reserved) VALUES
    ('Low', 'Low', 1, TRUE),
    ('Normal', 'Normal', 2, TRUE),
    ('High', 'High', 3, TRUE),
    ('Urgent', 'Urgent', 4, TRUE),
    ('Critical', 'Critical', 5, TRUE);

-- Activity medium
INSERT INTO activity_medium (name, label, weight, is_reserved) VALUES
    ('Phone', 'Phone', 1, TRUE),
    ('Email', 'Email', 2, TRUE),
    ('In Person', 'In Person', 3, TRUE),
    ('Mail', 'Mail', 4, TRUE),
    ('Fax', 'Fax', 5, TRUE),
    ('SMS', 'SMS', 6, TRUE),
    ('Chat', 'Chat', 7, TRUE),
    ('Video Call', 'Video Call', 8, TRUE),
    ('Social Media', 'Social Media', 9, TRUE),
    ('Website', 'Website', 10, TRUE),
    ('Mobile App', 'Mobile App', 11, TRUE),
    ('Other', 'Other', 12, TRUE);

-- Financial accounts (basic chart of accounts)
INSERT INTO financial_accounts (name, description, account_type_code, account_code, is_header_account) VALUES
    ('Assets', 'Asset accounts', 'Asset', '1000', TRUE),
    ('Current Assets', 'Current asset accounts', 'Asset', '1100', TRUE),
    ('Cash', 'Cash on hand and in bank', 'Asset', '1110', FALSE),
    ('Accounts Receivable', 'Money owed by customers', 'Asset', '1120', FALSE),
    ('Prepaid Expenses', 'Expenses paid in advance', 'Asset', '1130', FALSE),
    ('Fixed Assets', 'Long-term asset accounts', 'Asset', '1200', TRUE),
    ('Equipment', 'Office equipment and furniture', 'Asset', '1210', FALSE),
    ('Buildings', 'Office buildings and facilities', 'Asset', '1220', FALSE),
    ('Liabilities', 'Liability accounts', 'Liability', '2000', TRUE),
    ('Current Liabilities', 'Current liability accounts', 'Liability', '2100', TRUE),
    ('Accounts Payable', 'Money owed to vendors', 'Liability', '2110', FALSE),
    ('Accrued Expenses', 'Expenses incurred but not paid', 'Liability', '2120', FALSE),
    ('Revenue', 'Revenue accounts', 'Revenue', '3000', TRUE),
    ('Donations', 'Charitable donations', 'Revenue', '3100', FALSE),
    ('Membership Dues', 'Membership fees', 'Revenue', '3200', FALSE),
    ('Event Revenue', 'Event registration fees', 'Revenue', '3300', FALSE),
    ('Grant Revenue', 'Grant funding', 'Revenue', '3400', FALSE),
    ('Expenses', 'Expense accounts', 'Expense', '4000', TRUE),
    ('Program Expenses', 'Program-related expenses', 'Expense', '4100', FALSE),
    ('Administrative Expenses', 'Administrative costs', 'Expense', '4200', FALSE),
    ('Fundraising Expenses', 'Fundraising costs', 'Expense', '4300', FALSE);

-- Set parent relationships for financial accounts
UPDATE financial_accounts SET parent_id = (SELECT id FROM financial_accounts WHERE account_code = '1000') WHERE account_code IN ('1100', '1200');
UPDATE financial_accounts SET parent_id = (SELECT id FROM financial_accounts WHERE account_code = '1100') WHERE account_code IN ('1110', '1120', '1130');
UPDATE financial_accounts SET parent_id = (SELECT id FROM financial_accounts WHERE account_code = '1200') WHERE account_code IN ('1210', '1220');
UPDATE financial_accounts SET parent_id = (SELECT id FROM financial_accounts WHERE account_code = '2000') WHERE account_code IN ('2100');
UPDATE financial_accounts SET parent_id = (SELECT id FROM financial_accounts WHERE account_code = '2100') WHERE account_code IN ('2110', '2120');
UPDATE financial_accounts SET parent_id = (SELECT id FROM financial_accounts WHERE account_code = '3000') WHERE account_code IN ('3100', '3200', '3300', '3400');
UPDATE financial_accounts SET parent_id = (SELECT id FROM financial_accounts WHERE account_code = '4000') WHERE account_code IN ('4100', '4200', '4300');
