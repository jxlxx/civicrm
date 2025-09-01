-- Seed data for case management system
-- This provides initial data needed for the case management system to function

-- Case types (common CiviCRM case types)
INSERT INTO case_types (name, title, description, weight, is_active) VALUES
    ('Legal', 'Legal Case', 'Legal representation and advice cases', 1, TRUE),
    ('Medical', 'Medical Case', 'Medical and health-related cases', 2, TRUE),
    ('Social Work', 'Social Work Case', 'Social work and human services cases', 3, TRUE),
    ('Housing', 'Housing Case', 'Housing assistance and homelessness cases', 4, TRUE),
    ('Employment', 'Employment Case', 'Employment and job training cases', 5, TRUE),
    ('Education', 'Education Case', 'Educational support and advocacy cases', 6, TRUE),
    ('Immigration', 'Immigration Case', 'Immigration and citizenship cases', 7, TRUE),
    ('Veterans', 'Veterans Case', 'Veterans services and support cases', 8, TRUE),
    ('Disability', 'Disability Case', 'Disability rights and support cases', 9, TRUE),
    ('Youth', 'Youth Case', 'Youth services and juvenile justice cases', 10, TRUE);

-- Case status (core CiviCRM case statuses)
INSERT INTO case_status (name, label, grouping, weight, is_active, color) VALUES
    ('Open', 'Open', 'Open', 1, TRUE, '#28a745'),
    ('In Progress', 'In Progress', 'Open', 2, TRUE, '#17a2b8'),
    ('Urgent', 'Urgent', 'Open', 3, TRUE, '#dc3545'),
    ('On Hold', 'On Hold', 'Open', 4, TRUE, '#ffc107'),
    ('Waiting for Client', 'Waiting for Client', 'Open', 5, TRUE, '#fd7e14'),
    ('Closed', 'Closed', 'Closed', 6, TRUE, '#6c757d'),
    ('Resolved', 'Resolved', 'Closed', 7, TRUE, '#20c997'),
    ('Referred', 'Referred', 'Closed', 8, TRUE, '#6f42c1'),
    ('Cancelled', 'Cancelled', 'Closed', 9, TRUE, '#e83e8c'),
    ('Transferred', 'Transferred', 'Closed', 10, TRUE, '#6610f2');
