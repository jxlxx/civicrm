-- Seed data for system configuration
-- Provides initial data needed for the system configuration to function

-- Create default domain
INSERT INTO domains (name, description, is_active) VALUES
    ('default', 'Default domain for CiviCRM', TRUE);

-- System settings for the default domain
INSERT INTO settings (domain_id, name, value, description, is_system, is_public) VALUES
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'site_name', 'CiviCRM', 'Site name displayed throughout the system', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'site_description', 'Community and Non-Profit Management System', 'Site description for SEO and display', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'site_url', 'https://example.com', 'Primary site URL', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'admin_email', 'admin@example.com', 'Administrator email address', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'default_currency', 'USD', 'Default currency for financial transactions', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'default_country', 'US', 'Default country for new contacts', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'default_language', 'en_US', 'Default language for the system', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'timezone', 'UTC', 'Default timezone for the system', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'date_format', 'Y-m-d', 'Default date format', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'time_format', 'H:i:s', 'Default time format', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'max_upload_size', '10485760', 'Maximum file upload size in bytes (10MB)', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'session_timeout', '3600', 'Session timeout in seconds (1 hour)', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_activity_logging', 'true', 'Enable activity logging for audit trails', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_caching', 'true', 'Enable system caching for performance', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'cache_ttl', '3600', 'Cache time-to-live in seconds', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_api_rate_limiting', 'true', 'Enable API rate limiting', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'api_rate_limit', '1000', 'API rate limit per hour per user', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_email_sending', 'true', 'Enable email sending functionality', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'smtp_host', 'localhost', 'SMTP server hostname', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'smtp_port', '587', 'SMTP server port', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'smtp_username', '', 'SMTP server username', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'smtp_password', '', 'SMTP server password', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'smtp_encryption', 'tls', 'SMTP encryption method', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_sms_sending', 'false', 'Enable SMS sending functionality', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_payment_processing', 'true', 'Enable payment processing', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'payment_gateway', 'stripe', 'Default payment gateway', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_recurring_contributions', 'true', 'Enable recurring contribution processing', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_event_registration', 'true', 'Enable event registration system', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_membership_management', 'true', 'Enable membership management', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_case_management', 'true', 'Enable case management system', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_campaign_management', 'true', 'Enable campaign management', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_survey_system', 'true', 'Enable survey system', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_reporting', 'true', 'Enable reporting system', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_extension_system', 'true', 'Enable extension system', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_workflow_engine', 'true', 'Enable workflow engine', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_audit_logging', 'true', 'Enable comprehensive audit logging', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_background_jobs', 'true', 'Enable background job processing', TRUE, FALSE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'enable_queue_processing', 'true', 'Enable queue processing system', TRUE, FALSE);

-- Main navigation structure
INSERT INTO navigation (domain_id, name, label, url, icon, permission, weight, is_active, is_visible) VALUES
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'dashboard', 'Dashboard', '/dashboard', 'dashboard', 'access_dashboard', 0, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'contacts', 'Contacts', '/contacts', 'people', 'access_contacts', 10, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'contributions', 'Contributions', '/contributions', 'money', 'access_contributions', 20, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'events', 'Events', '/events', 'event', 'access_events', 30, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'memberships', 'Memberships', '/memberships', 'card_membership', 'access_memberships', 40, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'cases', 'Cases', '/cases', 'folder', 'access_cases', 50, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'campaigns', 'Campaigns', '/campaigns', 'campaign', 'access_campaigns', 60, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'reports', 'Reports', '/reports', 'assessment', 'access_reports', 70, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'surveys', 'Surveys', '/surveys', 'poll', 'access_surveys', 80, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'admin', 'Administration', '/admin', 'settings', 'access_admin', 90, TRUE, TRUE);

-- Sub-navigation for contacts
INSERT INTO navigation (domain_id, parent_id, name, label, url, icon, permission, weight, is_active, is_visible) VALUES
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'contacts' LIMIT 1), 'add_contact', 'Add Contact', '/contacts/add', 'person_add', 'create_contacts', 0, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'contacts' LIMIT 1), 'search_contacts', 'Search Contacts', '/contacts/search', 'search', 'access_contacts', 10, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'contacts' LIMIT 1), 'contact_groups', 'Groups', '/contacts/groups', 'group', 'access_contacts', 20, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'contacts' LIMIT 1), 'contact_tags', 'Tags', '/contacts/tags', 'label', 'access_contacts', 30, TRUE, TRUE);

-- Sub-navigation for contributions
INSERT INTO navigation (domain_id, parent_id, name, label, url, icon, permission, weight, is_active, is_visible) VALUES
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'contributions' LIMIT 1), 'add_contribution', 'Add Contribution', '/contributions/add', 'add_circle', 'create_contributions', 0, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'contributions' LIMIT 1), 'contribution_pages', 'Contribution Pages', '/contributions/pages', 'web', 'access_contributions', 10, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'contributions' LIMIT 1), 'recurring_contributions', 'Recurring', '/contributions/recurring', 'repeat', 'access_contributions', 20, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'contributions' LIMIT 1), 'financial_accounts', 'Financial Accounts', '/contributions/accounts', 'account_balance', 'access_contributions', 30, TRUE, TRUE);

-- Sub-navigation for events
INSERT INTO navigation (domain_id, parent_id, name, label, url, icon, permission, weight, is_active, is_visible) VALUES
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'events' LIMIT 1), 'add_event', 'Add Event', '/events/add', 'add_circle', 'create_events', 0, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'events' LIMIT 1), 'event_templates', 'Templates', '/events/templates', 'template', 'access_events', 10, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'events' LIMIT 1), 'event_types', 'Event Types', '/events/types', 'category', 'access_events', 20, TRUE, TRUE);

-- Sub-navigation for admin
INSERT INTO navigation (domain_id, parent_id, name, label, url, icon, permission, weight, is_active, is_visible) VALUES
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'admin' LIMIT 1), 'system_settings', 'System Settings', '/admin/settings', 'settings', 'administer_system', 0, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'admin' LIMIT 1), 'user_management', 'Users & Permissions', '/admin/users', 'people', 'administer_users', 10, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'admin' LIMIT 1), 'extensions', 'Extensions', '/admin/extensions', 'extension', 'administer_extensions', 20, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'admin' LIMIT 1), 'workflows', 'Workflows', '/admin/workflows', 'workflow', 'administer_workflows', 30, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'admin' LIMIT 1), 'background_jobs', 'Background Jobs', '/admin/jobs', 'schedule', 'administer_jobs', 40, TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 
     (SELECT id FROM navigation WHERE name = 'admin' LIMIT 1), 'system_logs', 'System Logs', '/admin/logs', 'list_alt', 'administer_logs', 50, TRUE, TRUE);

-- Default user framework groups for common forms
INSERT INTO uf_groups (domain_id, name, title, description, is_active, is_reserved) VALUES
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'contact_profile', 'Contact Profile', 'Standard contact information form', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'event_registration', 'Event Registration', 'Standard event registration form', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'contribution_page', 'Contribution Page', 'Standard contribution form', TRUE, TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'membership_signup', 'Membership Signup', 'Standard membership signup form', TRUE, TRUE);

-- Default user framework fields for contact profile
INSERT INTO uf_fields (uf_group_id, name, label, field_type, is_required, weight, help_pre, help_post) VALUES
    ((SELECT id FROM uf_groups WHERE name = 'contact_profile' LIMIT 1), 'first_name', 'First Name', 'text', TRUE, 10, 'Enter your first name', ''),
    ((SELECT id FROM uf_groups WHERE name = 'contact_profile' LIMIT 1), 'last_name', 'Last Name', 'text', TRUE, 20, 'Enter your last name', ''),
    ((SELECT id FROM uf_groups WHERE name = 'contact_profile' LIMIT 1), 'email', 'Email Address', 'email', TRUE, 30, 'Enter your email address', 'We will use this to send you important updates'),
    ((SELECT id FROM uf_groups WHERE name = 'contact_profile' LIMIT 1), 'phone', 'Phone Number', 'phone', FALSE, 40, 'Enter your phone number', ''),
    ((SELECT id FROM uf_groups WHERE name = 'contact_profile' LIMIT 1), 'address_line_1', 'Address Line 1', 'text', FALSE, 50, 'Enter your street address', ''),
    ((SELECT id FROM uf_groups WHERE name = 'contact_profile' LIMIT 1), 'city', 'City', 'text', FALSE, 60, 'Enter your city', ''),
    ((SELECT id FROM uf_groups WHERE name = 'contact_profile' LIMIT 1), 'state_province', 'State/Province', 'select', FALSE, 70, 'Select your state or province', ''),
    ((SELECT id FROM uf_groups WHERE name = 'contact_profile' LIMIT 1), 'postal_code', 'Postal Code', 'text', FALSE, 80, 'Enter your postal code', ''),
    ((SELECT id FROM uf_groups WHERE name = 'contact_profile' LIMIT 1), 'country', 'Country', 'select', FALSE, 90, 'Select your country', '');

-- Default background jobs
INSERT INTO jobs (domain_id, name, description, job_type, parameters, schedule, is_active) VALUES
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'cleanup_expired_sessions', 'Clean up expired user sessions', 'cleanup', '{"retention_days": 7}', '0 2 * * *', TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'process_recurring_contributions', 'Process recurring contributions', 'contribution', '{}', '0 */6 * * *', TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'send_scheduled_reports', 'Send scheduled reports via email', 'report', '{}', '0 9 * * *', TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'cleanup_old_logs', 'Clean up old system logs', 'cleanup', '{"retention_days": 90}', '0 3 * * 0', TRUE),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'update_contact_statistics', 'Update contact statistics and metrics', 'statistics', '{}', '0 1 * * *', TRUE);

-- Default queues for background processing
INSERT INTO queues (domain_id, name, description, is_active, max_retries, retry_delay_seconds) VALUES
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'email_queue', 'Email sending queue', TRUE, 3, 300),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'report_queue', 'Report generation queue', TRUE, 2, 600),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'notification_queue', 'User notification queue', TRUE, 3, 300),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'data_export_queue', 'Data export queue', TRUE, 2, 900),
    ((SELECT id FROM domains WHERE name = 'default' LIMIT 1), 'cleanup_queue', 'System cleanup queue', TRUE, 1, 1800);
