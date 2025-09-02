-- Migration: 032_seed_custom_fields_data.sql
-- Description: Seed data for custom fields system with common use cases
-- Date: 2024-12-19

-- Seed Custom Groups for common entities
INSERT INTO custom_groups (name, title, extends, is_active, weight, help_pre, help_post) VALUES
    ('contact_additional_info', 'Additional Contact Information', 'Contact', true, 10, 'Additional information about this contact', 'Please provide any additional details that may be helpful.'),
    ('contact_preferences', 'Contact Preferences', 'Contact', true, 20, 'Communication and preference settings', 'Help us understand how you prefer to be contacted.'),
    ('contribution_details', 'Contribution Details', 'Contribution', true, 10, 'Additional details about this contribution', 'Please provide any additional information about this donation.'),
    ('event_registration', 'Event Registration Details', 'Event', true, 10, 'Additional registration information', 'Please provide any special requirements or preferences.'),
    ('activity_notes', 'Activity Notes', 'Activity', true, 10, 'Additional notes and details', 'Please provide any additional context for this activity.');

-- Seed Custom Fields for Contact Additional Info
INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'birth_date', 'Birth Date', 'Date', 'Select Date', false, true, 10, 'When is your birthday?', 'We use this for special birthday communications.'
FROM custom_groups cg WHERE cg.name = 'contact_additional_info';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'occupation', 'Occupation', 'String', 'Text', false, true, 20, 'What is your current occupation?', 'This helps us understand your professional background.'
FROM custom_groups cg WHERE cg.name = 'contact_additional_info';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'employer', 'Employer', 'String', 'Text', false, true, 30, 'Who is your current employer?', 'This helps us understand your professional affiliations.'
FROM custom_groups cg WHERE cg.name = 'contact_additional_info';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'interests', 'Areas of Interest', 'String', 'TextArea', false, true, 40, 'What areas are you most interested in?', 'This helps us tailor our communications to your interests.'
FROM custom_groups cg WHERE cg.name = 'contact_additional_info';

-- Seed Custom Fields for Contact Preferences
INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'newsletter_frequency', 'Newsletter Frequency', 'String', 'Select', false, true, 10, 'How often would you like to receive our newsletter?', 'Choose the frequency that works best for you.'
FROM custom_groups cg WHERE cg.name = 'contact_preferences';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'volunteer_interests', 'Volunteer Interests', 'String', 'CheckBox', false, true, 20, 'What types of volunteer opportunities interest you?', 'Select all that apply.'
FROM custom_groups cg WHERE cg.name = 'contact_preferences';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'preferred_contact_method', 'Preferred Contact Method', 'String', 'Radio', false, true, 30, 'What is your preferred method of contact?', 'We will use this method for important communications.'
FROM custom_groups cg WHERE cg.name = 'contact_preferences';

-- Seed Custom Fields for Contribution Details
INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'campaign_source', 'Campaign Source', 'String', 'Text', false, true, 10, 'How did you hear about this campaign?', 'This helps us understand which outreach methods are most effective.'
FROM custom_groups cg WHERE cg.name = 'contribution_details';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'donor_motivation', 'Donor Motivation', 'String', 'Select', false, true, 20, 'What motivated you to make this donation?', 'This helps us understand donor motivations.'
FROM custom_groups cg WHERE cg.name = 'contribution_details';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'anonymous_donation', 'Anonymous Donation', 'Boolean', 'Radio', false, false, 30, 'Would you like this donation to remain anonymous?', 'Anonymous donations will not be publicly recognized.'
FROM custom_groups cg WHERE cg.name = 'contribution_details';

-- Seed Custom Fields for Event Registration
INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'dietary_restrictions', 'Dietary Restrictions', 'String', 'TextArea', false, true, 10, 'Do you have any dietary restrictions?', 'This helps us plan meals and refreshments.'
FROM custom_groups cg WHERE cg.name = 'event_registration';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'accessibility_needs', 'Accessibility Needs', 'String', 'TextArea', false, true, 20, 'Do you have any accessibility needs?', 'This helps us ensure the event is accessible to all participants.'
FROM custom_groups cg WHERE cg.name = 'event_registration';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'emergency_contact', 'Emergency Contact', 'String', 'Text', false, false, 30, 'Emergency contact information', 'Please provide emergency contact details.'
FROM custom_groups cg WHERE cg.name = 'event_registration';

-- Seed Custom Fields for Activity Notes
INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'follow_up_required', 'Follow-up Required', 'Boolean', 'Radio', false, true, 10, 'Does this activity require follow-up?', 'Mark if follow-up action is needed.'
FROM custom_groups cg WHERE cg.name = 'activity_notes';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'priority_level', 'Priority Level', 'String', 'Select', false, true, 20, 'What is the priority level of this activity?', 'Choose the appropriate priority level.'
FROM custom_groups cg WHERE cg.name = 'activity_notes';

INSERT INTO custom_fields (custom_group_id, name, label, data_type, html_type, is_required, is_searchable, weight, help_pre, help_post) 
SELECT cg.id, 'internal_notes', 'Internal Notes', 'String', 'TextArea', false, false, 30, 'Internal notes and comments', 'These notes are only visible to staff members.'
FROM custom_groups cg WHERE cg.name = 'activity_notes';

-- Seed Custom Field Options for Select/Radio/Checkbox fields
-- Newsletter Frequency Options
INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Weekly', 'weekly', 10, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'newsletter_frequency';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Monthly', 'monthly', 20, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'newsletter_frequency';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Quarterly', 'quarterly', 30, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'newsletter_frequency';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Never', 'never', 40, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'newsletter_frequency';

-- Volunteer Interest Options
INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Event Planning', 'event_planning', 10, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'volunteer_interests';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Administrative Support', 'admin_support', 20, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'volunteer_interests';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Fundraising', 'fundraising', 30, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'volunteer_interests';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Community Outreach', 'community_outreach', 40, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'volunteer_interests';

-- Preferred Contact Method Options
INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Email', 'email', 10, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'preferred_contact_method';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Phone', 'phone', 20, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'preferred_contact_method';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Mail', 'mail', 30, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'preferred_contact_method';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'SMS', 'sms', 40, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contact_preferences' AND cf.name = 'preferred_contact_method';

-- Donor Motivation Options
INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Personal Connection', 'personal_connection', 10, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contribution_details' AND cf.name = 'donor_motivation';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Tax Benefits', 'tax_benefits', 20, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contribution_details' AND cf.name = 'donor_motivation';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Social Impact', 'social_impact', 30, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contribution_details' AND cf.name = 'donor_motivation';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Recognition', 'recognition', 40, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'contribution_details' AND cf.name = 'donor_motivation';

-- Priority Level Options
INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Low', 'low', 10, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'activity_notes' AND cf.name = 'priority_level';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Medium', 'medium', 20, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'activity_notes' AND cf.name = 'priority_level';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'High', 'high', 30, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'activity_notes' AND cf.name = 'priority_level';

INSERT INTO custom_field_options (custom_field_id, label, value, weight, is_active)
SELECT cf.id, 'Urgent', 'urgent', 40, true
FROM custom_fields cf 
INNER JOIN custom_groups cg ON cf.custom_group_id = cg.id
WHERE cg.name = 'activity_notes' AND cf.name = 'priority_level';
