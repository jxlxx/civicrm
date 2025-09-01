-- Seed data for reporting and analytics system
-- This provides initial data needed for the reporting system to function

-- Sample report templates (common CiviCRM report types)
INSERT INTO report_templates (name, description, report_type, query_template, parameters, is_active, is_system) VALUES
    ('Contact Summary Report', 'Summary of contact information and demographics', 'contact', 
     'SELECT contact_type, COUNT(*) as contact_count FROM contacts GROUP BY contact_type ORDER BY contact_count DESC',
     '{"filters": {"date_range": true, "contact_type": true, "location": true}}', TRUE, TRUE),
    
    ('Contribution Summary Report', 'Summary of contributions and fundraising metrics', 'contribution',
     'SELECT contribution_type, SUM(amount) as total_amount, COUNT(*) as contribution_count FROM contributions WHERE received_date >= $1 AND received_date <= $2 GROUP BY contribution_type ORDER BY total_amount DESC',
     '{"filters": {"date_range": true, "contribution_type": true, "status": true}}', TRUE, TRUE),
    
    ('Event Registration Report', 'Summary of event registrations and attendance', 'event',
     'SELECT e.title, COUNT(er.id) as registration_count, COUNT(CASE WHEN er.status = ''Registered'' THEN 1 END) as confirmed_count FROM events e LEFT JOIN event_registrations er ON e.id = er.event_id GROUP BY e.id, e.title ORDER BY e.start_date DESC',
     '{"filters": {"date_range": true, "event_type": true, "status": true}}', TRUE, TRUE),
    
    ('Membership Summary Report', 'Summary of membership types and status', 'membership',
     'SELECT mt.name as membership_type, COUNT(m.id) as member_count, COUNT(CASE WHEN m.status_id = 1 THEN 1 END) as active_count FROM membership_types mt LEFT JOIN memberships m ON mt.id = m.membership_type_id GROUP BY mt.id, mt.name ORDER BY member_count DESC',
     '{"filters": {"date_range": true, "membership_type": true, "status": true}}', TRUE, TRUE),
    
    ('Case Summary Report', 'Summary of case management and resolution', 'case',
     'SELECT ct.name as case_type, COUNT(c.id) as case_count, COUNT(CASE WHEN c.status_id = 1 THEN 1 END) as open_count FROM case_types ct LEFT JOIN cases c ON ct.id = c.case_type_id GROUP BY ct.id, ct.name ORDER BY case_count DESC',
     '{"filters": {"date_range": true, "case_type": true, "status": true}}', TRUE, TRUE),
    
    ('Survey Response Report', 'Summary of survey responses and analytics', 'survey',
     'SELECT s.title, COUNT(sr.id) as response_count, COUNT(CASE WHEN sr.status = ''Completed'' THEN 1 END) as completed_count FROM surveys s LEFT JOIN survey_responses sr ON s.id = sr.survey_id GROUP BY s.id, s.title ORDER BY response_count DESC',
     '{"filters": {"date_range": true, "survey_type": true, "status": true}}', TRUE, TRUE);

-- Sample dashboards (common dashboard configurations)
INSERT INTO dashboards (name, description, layout, is_active, is_default) VALUES
    ('Executive Dashboard', 'High-level overview for executives and board members', 
     '{"grid": {"columns": 12, "rows": 8}, "widgets": []}', TRUE, TRUE),
    
    ('Development Dashboard', 'Fundraising and donor management overview', 
     '{"grid": {"columns": 12, "rows": 8}, "widgets": []}', TRUE, FALSE),
    
    ('Program Dashboard', 'Program delivery and impact measurement', 
     '{"grid": {"columns": 12, "rows": 8}, "widgets": []}', TRUE, FALSE),
    
    ('Operations Dashboard', 'Operational metrics and efficiency tracking', 
     '{"grid": {"columns": 12, "rows": 8}, "widgets": []}', TRUE, FALSE);

-- Sample dashboard widgets for Executive Dashboard
INSERT INTO dashboard_widgets (dashboard_id, name, widget_type, configuration, position_x, position_y, width, height, is_active) VALUES
    ((SELECT id FROM dashboards WHERE name = 'Executive Dashboard' LIMIT 1), 'Total Contacts', 'metric', 
     '{"data_source": "contact_count", "format": "number", "color": "blue"}', 0, 0, 3, 2, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Executive Dashboard' LIMIT 1), 'Total Contributions', 'metric', 
     '{"data_source": "contribution_total", "format": "currency", "color": "green"}', 3, 0, 3, 2, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Executive Dashboard' LIMIT 1), 'Active Members', 'metric', 
     '{"data_source": "active_members", "format": "number", "color": "purple"}', 6, 0, 3, 2, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Executive Dashboard' LIMIT 1), 'Open Cases', 'metric', 
     '{"data_source": "open_cases", "format": "number", "color": "orange"}', 9, 0, 3, 2, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Executive Dashboard' LIMIT 1), 'Contact Growth Trend', 'chart', 
     '{"data_source": "contact_growth", "chart_type": "line", "title": "Contact Growth Over Time"}', 0, 2, 6, 3, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Executive Dashboard' LIMIT 1), 'Contribution by Type', 'chart', 
     '{"data_source": "contribution_by_type", "chart_type": "pie", "title": "Contributions by Type"}', 6, 2, 6, 3, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Executive Dashboard' LIMIT 1), 'Recent Activities', 'list', 
     '{"data_source": "recent_activities", "limit": 10, "title": "Recent Activities"}', 0, 5, 12, 3, TRUE);

-- Sample dashboard widgets for Development Dashboard
INSERT INTO dashboard_widgets (dashboard_id, name, widget_type, configuration, position_x, position_y, width, height, is_active) VALUES
    ((SELECT id FROM dashboards WHERE name = 'Development Dashboard' LIMIT 1), 'Monthly Contributions', 'metric', 
     '{"data_source": "monthly_contributions", "format": "currency", "color": "green"}', 0, 0, 4, 2, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Development Dashboard' LIMIT 1), 'Donor Retention Rate', 'metric', 
     '{"data_source": "donor_retention", "format": "percentage", "color": "blue"}', 4, 0, 4, 2, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Development Dashboard' LIMIT 1), 'New Donors This Month', 'metric', 
     '{"data_source": "new_donors", "format": "number", "color": "purple"}', 8, 0, 4, 2, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Development Dashboard' LIMIT 1), 'Contribution Trends', 'chart', 
     '{"data_source": "contribution_trends", "chart_type": "line", "title": "Contribution Trends"}', 0, 2, 8, 3, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Development Dashboard' LIMIT 1), 'Top Donors', 'list', 
     '{"data_source": "top_donors", "limit": 10, "title": "Top Donors"}', 8, 2, 4, 3, TRUE),
    
    ((SELECT id FROM dashboards WHERE name = 'Development Dashboard' LIMIT 1), 'Campaign Performance', 'chart', 
     '{"data_source": "campaign_performance", "chart_type": "bar", "title": "Campaign Performance"}', 0, 5, 12, 3, TRUE);

-- Sample report instances (scheduled reports)
INSERT INTO report_instances (report_template_id, name, description, parameters, schedule, is_active) VALUES
    ((SELECT id FROM report_templates WHERE name = 'Contact Summary Report' LIMIT 1), 'Monthly Contact Summary', 
     'Monthly summary of contact growth and demographics', '{"date_range": "last_month"}', '0 9 1 * *', TRUE),
    
    ((SELECT id FROM report_templates WHERE name = 'Contribution Summary Report' LIMIT 1), 'Weekly Contribution Summary', 
     'Weekly summary of contributions and fundraising', '{"date_range": "last_week"}', '0 9 * * 1', TRUE),
    
    ((SELECT id FROM report_templates WHERE name = 'Event Registration Report' LIMIT 1), 'Event Registration Summary', 
     'Summary of event registrations and attendance', '{"date_range": "last_month"}', '0 9 1 * *', TRUE);
