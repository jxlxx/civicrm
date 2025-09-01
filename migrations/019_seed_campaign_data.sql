-- Seed data for campaign management system
-- This provides initial data needed for the campaign management system to function

-- Campaign types (common CiviCRM campaign types)
INSERT INTO campaign_types (name, label, description, weight, is_active) VALUES
    ('Fundraising', 'Fundraising Campaign', 'Campaigns focused on raising money for the organization', 1, TRUE),
    ('Advocacy', 'Advocacy Campaign', 'Campaigns focused on policy change and public awareness', 2, TRUE),
    ('Outreach', 'Outreach Campaign', 'Campaigns focused on community engagement and education', 3, TRUE),
    ('Volunteer', 'Volunteer Campaign', 'Campaigns focused on recruiting and managing volunteers', 4, TRUE),
    ('Membership', 'Membership Campaign', 'Campaigns focused on growing membership base', 5, TRUE),
    ('Event', 'Event Campaign', 'Campaigns focused on event promotion and attendance', 6, TRUE),
    ('Communication', 'Communication Campaign', 'Campaigns focused on newsletters and updates', 7, TRUE),
    ('Research', 'Research Campaign', 'Campaigns focused on data collection and surveys', 8, TRUE),
    ('Emergency', 'Emergency Campaign', 'Campaigns for urgent needs and crisis response', 9, TRUE),
    ('Legacy', 'Legacy Campaign', 'Campaigns focused on planned giving and bequests', 10, TRUE);

-- Campaign status (core CiviCRM campaign statuses)
INSERT INTO campaign_status (name, label, grouping, weight, is_active, color) VALUES
    ('Planned', 'Planned', 'Planned', 1, TRUE, '#6c757d'),
    ('In Development', 'In Development', 'Planned', 2, TRUE, '#17a2b8'),
    ('Approved', 'Approved', 'Planned', 3, TRUE, '#28a745'),
    ('Active', 'Active', 'Active', 4, TRUE, '#007bff'),
    ('In Progress', 'In Progress', 'Active', 5, TRUE, '#fd7e14'),
    ('On Hold', 'On Hold', 'Active', 6, TRUE, '#ffc107'),
    ('Completed', 'Completed', 'Completed', 7, TRUE, '#20c997'),
    ('Successful', 'Successful', 'Completed', 8, TRUE, '#28a745'),
    ('Cancelled', 'Cancelled', 'Cancelled', 9, TRUE, '#dc3545'),
    ('Failed', 'Failed', 'Cancelled', 10, TRUE, '#e83e8c'),
    ('Suspended', 'Suspended', 'Cancelled', 11, TRUE, '#6f42c1'),
    ('Archived', 'Archived', 'Completed', 12, TRUE, '#6c757d');
