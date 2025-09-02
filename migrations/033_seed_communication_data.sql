-- Migration: 033_seed_communication_data.sql
-- Description: Seed data for communication system with sample templates and mailing lists
-- Date: 2024-12-19

-- Seed Message Templates for common workflows
INSERT INTO message_templates (name, title, subject, body_text, body_html, template_type, is_active, is_default, workflow_name) VALUES
    ('welcome_email', 'Welcome Email', 'Welcome to Our Organization!', 
     'Dear {contact.first_name},\n\nWelcome to our organization! We''re excited to have you as part of our community.\n\nBest regards,\nThe Team', 
     '<h2>Welcome to Our Organization!</h2><p>Dear {contact.first_name},</p><p>Welcome to our organization! We''re excited to have you as part of our community.</p><p>Best regards,<br>The Team</p>', 
     'Email', true, true, 'contact_created'),
     
    ('donation_receipt', 'Donation Receipt', 'Thank You for Your Donation', 
     'Dear {contact.first_name},\n\nThank you for your generous donation of ${contribution.total_amount}.\n\nYour support makes a difference.\n\nBest regards,\nThe Team', 
     '<h2>Thank You for Your Donation</h2><p>Dear {contact.first_name},</p><p>Thank you for your generous donation of <strong>${contribution.total_amount}</strong>.</p><p>Your support makes a difference.</p><p>Best regards,<br>The Team</p>', 
     'Email', true, true, 'contribution_received'),
     
    ('event_confirmation', 'Event Confirmation', 'Event Registration Confirmed', 
     'Dear {contact.first_name},\n\nYour registration for {event.title} has been confirmed.\n\nDate: {event.start_date}\nLocation: {event.location}\n\nWe look forward to seeing you!\n\nBest regards,\nThe Team', 
     '<h2>Event Registration Confirmed</h2><p>Dear {contact.first_name},</p><p>Your registration for <strong>{event.title}</strong> has been confirmed.</p><p><strong>Date:</strong> {event.start_date}<br><strong>Location:</strong> {event.location}</p><p>We look forward to seeing you!</p><p>Best regards,<br>The Team</p>', 
     'Email', true, true, 'event_registration'),
     
    ('newsletter_weekly', 'Weekly Newsletter', 'This Week at Our Organization', 
     'Dear {contact.first_name},\n\nHere''s what''s happening this week:\n\n{newsletter.content}\n\nBest regards,\nThe Team', 
     '<h2>This Week at Our Organization</h2><p>Dear {contact.first_name},</p><p>Here''s what''s happening this week:</p><div>{newsletter.content}</div><p>Best regards,<br>The Team</p>', 
     'Email', true, false, 'newsletter'),
     
    ('sms_reminder', 'SMS Reminder', 'Reminder: {activity.subject}', 
     'Hi {contact.first_name}, this is a reminder about {activity.subject}. Please call us at {phone} if you need to reschedule.', 
     'Hi {contact.first_name}, this is a reminder about {activity.subject}. Please call us at {phone} if you need to reschedule.', 
     'SMS', true, true, 'activity_reminder'),
     
    ('pledge_reminder', 'Pledge Reminder', 'Pledge Payment Reminder', 
     'Dear {contact.first_name},\n\nThis is a friendly reminder that your pledge payment of ${pledge.amount} is due on {payment.scheduled_date}.\n\nThank you for your continued support.\n\nBest regards,\nThe Team', 
     '<h2>Pledge Payment Reminder</h2><p>Dear {contact.first_name},</p><p>This is a friendly reminder that your pledge payment of <strong>${pledge.amount}</strong> is due on <strong>{payment.scheduled_date}</strong>.</p><p>Thank you for your continued support.</p><p>Best regards,<br>The Team</p>', 
     'Email', true, true, 'pledge_reminder');

-- Seed Mailing Lists for common use cases
INSERT INTO mailing_lists (name, title, description, is_public, is_hidden, is_active) VALUES
    ('general_newsletter', 'General Newsletter', 'Our main newsletter with organization updates and news', true, false, true),
    ('volunteer_updates', 'Volunteer Updates', 'Updates and opportunities for our volunteers', false, false, true),
    ('donor_news', 'Donor News', 'Special updates and recognition for our donors', false, false, true),
    ('event_notifications', 'Event Notifications', 'Notifications about upcoming events and activities', true, false, true),
    ('advocacy_alerts', 'Advocacy Alerts', 'Important advocacy and policy updates', true, false, true),
    ('staff_announcements', 'Staff Announcements', 'Internal announcements for staff members', false, true, true);

-- Seed sample contacts for mailing list subscriptions (using existing contacts)
-- Note: This assumes you have some contacts in your system already
-- You may need to adjust the contact IDs based on your actual data

-- Create communication preferences for existing contacts
INSERT INTO communication_preferences (contact_id, email_opt_out, sms_opt_out, mail_opt_out, phone_opt_out, do_not_email, do_not_sms, do_not_mail, do_not_phone, do_not_trade)
SELECT 
    c.id,
    false, -- email_opt_out
    false, -- sms_opt_out
    false, -- mail_opt_out
    false, -- phone_opt_out
    false, -- do_not_email
    false, -- do_not_sms
    false, -- do_not_mail
    false, -- do_not_phone
    false  -- do_not_trade
FROM contacts c
WHERE c.contact_type = 'Individual'
LIMIT 10; -- Limit to first 10 contacts to avoid overwhelming the system

-- Create sample mailings (draft status)
INSERT INTO mailings (name, subject, body_text, body_html, template_id, mailing_list_id, status, created_by)
SELECT 
    'Welcome Campaign 2024',
    'Welcome to Our Organization!',
    'Dear Friend,\n\nWelcome to our organization! We''re excited to have you as part of our community.\n\nBest regards,\nThe Team',
    '<h2>Welcome to Our Organization!</h2><p>Dear Friend,</p><p>Welcome to our organization! We''re excited to have you as part of our community.</p><p>Best regards,<br>The Team</p>',
    mt.id,
    ml.id,
    'Draft',
    u.id
FROM message_templates mt
CROSS JOIN mailing_lists ml
CROSS JOIN users u
WHERE mt.name = 'welcome_email' 
  AND ml.name = 'general_newsletter'
  AND u.is_admin = true
LIMIT 1;

INSERT INTO mailings (name, subject, body_text, body_html, template_id, mailing_list_id, status, created_by)
SELECT 
    'Monthly Newsletter - December 2024',
    'December Newsletter: Holiday Season Updates',
    'Dear Friend,\n\nHappy Holidays! Here''s what''s happening this month:\n\n- Holiday fundraising campaign\n- Year-end volunteer opportunities\n- Upcoming events in January\n\nBest regards,\nThe Team',
    '<h2>December Newsletter: Holiday Season Updates</h2><p>Dear Friend,</p><p>Happy Holidays! Here''s what''s happening this month:</p><ul><li>Holiday fundraising campaign</li><li>Year-end volunteer opportunities</li><li>Upcoming events in January</li></ul><p>Best regards,<br>The Team</p>',
    mt.id,
    ml.id,
    'Draft',
    u.id
FROM message_templates mt
CROSS JOIN mailing_lists ml
CROSS JOIN users u
WHERE mt.name = 'newsletter_weekly' 
  AND ml.name = 'general_newsletter'
  AND u.is_admin = true
LIMIT 1;

-- Create sample SMS messages
INSERT INTO sms_messages (contact_id, phone_number, message, direction, status, provider)
SELECT 
    c.id,
    c.phone,
    'Hi ' || COALESCE(c.first_name, 'there') || '! Thank you for your recent donation. Your support makes a difference!',
    'Outbound',
    'Delivered',
    'Twilio'
FROM contacts c
WHERE c.phone IS NOT NULL 
  AND c.contact_type = 'Individual'
LIMIT 5;

-- Create sample mailing recipients for the welcome campaign
INSERT INTO mailing_recipients (mailing_id, contact_id, email, status)
SELECT 
    m.id,
    c.id,
    c.email,
    'Pending'
FROM mailings m
CROSS JOIN contacts c
WHERE m.name = 'Welcome Campaign 2024'
  AND c.email IS NOT NULL
  AND c.contact_type = 'Individual'
LIMIT 5;

-- Create sample mailing recipients for the newsletter
INSERT INTO mailing_recipients (mailing_id, contact_id, email, status)
SELECT 
    m.id,
    c.id,
    c.email,
    'Pending'
FROM mailings m
CROSS JOIN contacts c
WHERE m.name = 'Monthly Newsletter - December 2024'
  AND c.email IS NOT NULL
  AND c.contact_type = 'Individual'
LIMIT 5;

-- Create sample trackable URLs for the welcome campaign
INSERT INTO mailing_trackable_urls (mailing_id, url, original_url)
SELECT 
    m.id,
    'https://example.com/track/' || m.id || '/welcome',
    'https://example.com/welcome'
FROM mailings m
WHERE m.name = 'Welcome Campaign 2024';

-- Create sample trackable URLs for the newsletter
INSERT INTO mailing_trackable_urls (mailing_id, url, original_url)
SELECT 
    m.id,
    'https://example.com/track/' || m.id || '/newsletter',
    'https://example.com/newsletter'
FROM mailings m
WHERE m.name = 'Monthly Newsletter - December 2024';

-- Create sample mailing list subscriptions
INSERT INTO mailing_list_subscriptions (mailing_list_id, contact_id, status, source, is_active)
SELECT 
    ml.id,
    c.id,
    'Subscribed',
    'System Import',
    true
FROM mailing_lists ml
CROSS JOIN contacts c
WHERE ml.name = 'general_newsletter'
  AND c.contact_type = 'Individual'
  AND c.email IS NOT NULL
LIMIT 5;

INSERT INTO mailing_list_subscriptions (mailing_list_id, contact_id, status, source, is_active)
SELECT 
    ml.id,
    c.id,
    'Subscribed',
    'System Import',
    true
FROM mailing_lists ml
CROSS JOIN contacts c
WHERE ml.name = 'volunteer_updates'
  AND c.contact_type = 'Individual'
  AND c.email IS NOT NULL
LIMIT 3;

INSERT INTO mailing_list_subscriptions (mailing_list_id, contact_id, status, source, is_active)
SELECT 
    ml.id,
    c.id,
    'Subscribed',
    'System Import',
    true
FROM mailing_lists ml
CROSS JOIN contacts c
WHERE ml.name = 'donor_news'
  AND c.contact_type = 'Individual'
  AND c.email IS NOT NULL
LIMIT 3;
