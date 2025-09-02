-- Migration: 030_communication_system.sql
-- Description: Add communication system for message templates, mailings, and email tracking
-- Date: 2024-12-19

-- Message Templates - Reusable templates for emails, SMS, letters
CREATE TABLE IF NOT EXISTS message_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    body_text TEXT,
    body_html TEXT,
    template_type VARCHAR(50) NOT NULL, -- 'Email', 'SMS', 'Letter', 'PDF'
    is_active BOOLEAN DEFAULT TRUE,
    is_default BOOLEAN DEFAULT FALSE, -- Default template for entity type
    workflow_name VARCHAR(255), -- Associated workflow
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mailing Lists - Groups of contacts for mass communications
CREATE TABLE IF NOT EXISTS mailing_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE, -- Public subscription lists
    is_hidden BOOLEAN DEFAULT FALSE, -- Hidden from public view
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mailing List Subscriptions - Contact subscriptions to mailing lists
CREATE TABLE IF NOT EXISTS mailing_list_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mailing_list_id UUID NOT NULL REFERENCES mailing_lists(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'Subscribed', -- 'Subscribed', 'Unsubscribed', 'Pending', 'Bounced'
    source VARCHAR(255), -- How they subscribed
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mailings - Individual email campaigns
CREATE TABLE IF NOT EXISTS mailings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    body_text TEXT,
    body_html TEXT,
    template_id UUID REFERENCES message_templates(id),
    mailing_list_id UUID REFERENCES mailing_lists(id),
    status VARCHAR(50) DEFAULT 'Draft', -- 'Draft', 'Scheduled', 'In Progress', 'Completed', 'Cancelled'
    scheduled_date TIMESTAMP WITH TIME ZONE,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    total_recipients INTEGER DEFAULT 0,
    total_sent INTEGER DEFAULT 0,
    total_opened INTEGER DEFAULT 0,
    total_clicked INTEGER DEFAULT 0,
    total_bounced INTEGER DEFAULT 0,
    total_unsubscribed INTEGER DEFAULT 0,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mailing Recipients - Individual recipients for each mailing
CREATE TABLE IF NOT EXISTS mailing_recipients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mailing_id UUID NOT NULL REFERENCES mailings(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending', -- 'Pending', 'Sent', 'Delivered', 'Opened', 'Clicked', 'Bounced', 'Unsubscribed'
    sent_date TIMESTAMP WITH TIME ZONE,
    delivered_date TIMESTAMP WITH TIME ZONE,
    opened_date TIMESTAMP WITH TIME ZONE,
    clicked_date TIMESTAMP WITH TIME ZONE,
    bounce_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mailing Trackable URLs - URLs in emails for click tracking
CREATE TABLE IF NOT EXISTS mailing_trackable_urls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mailing_id UUID NOT NULL REFERENCES mailings(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    original_url TEXT NOT NULL, -- Original URL before tracking
    click_count INTEGER DEFAULT 0,
    unique_clicks INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mailing URL Clicks - Individual click tracking records
CREATE TABLE IF NOT EXISTS mailing_url_clicks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trackable_url_id UUID NOT NULL REFERENCES mailing_trackable_urls(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES mailing_recipients(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    ip_address INET,
    user_agent TEXT,
    clicked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mailing Opens - Email open tracking records
CREATE TABLE IF NOT EXISTS mailing_opens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID NOT NULL REFERENCES mailing_recipients(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    ip_address INET,
    user_agent TEXT,
    opened_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- SMS Messages - Individual SMS messages
CREATE TABLE IF NOT EXISTS sms_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    phone_number VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    direction VARCHAR(20) DEFAULT 'Outbound', -- 'Inbound', 'Outbound'
    status VARCHAR(50) DEFAULT 'Pending', -- 'Pending', 'Sent', 'Delivered', 'Failed'
    provider VARCHAR(100), -- SMS service provider
    provider_message_id VARCHAR(255), -- Provider's message ID
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Communication Preferences - Contact communication preferences
CREATE TABLE IF NOT EXISTS communication_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    email_opt_out BOOLEAN DEFAULT FALSE,
    sms_opt_out BOOLEAN DEFAULT FALSE,
    mail_opt_out BOOLEAN DEFAULT FALSE,
    phone_opt_out BOOLEAN DEFAULT FALSE,
    do_not_email BOOLEAN DEFAULT FALSE,
    do_not_sms BOOLEAN DEFAULT FALSE,
    do_not_mail BOOLEAN DEFAULT FALSE,
    do_not_phone BOOLEAN DEFAULT FALSE,
    do_not_trade BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_message_templates_type ON message_templates(template_type, is_active);
CREATE INDEX IF NOT EXISTS idx_message_templates_workflow ON message_templates(workflow_name);
CREATE INDEX IF NOT EXISTS idx_mailing_lists_is_active ON mailing_lists(is_active);
CREATE INDEX IF NOT EXISTS idx_mailing_list_subscriptions_contact ON mailing_list_subscriptions(contact_id, status);
CREATE INDEX IF NOT EXISTS idx_mailing_list_subscriptions_list ON mailing_list_subscriptions(mailing_list_id, status);
CREATE INDEX IF NOT EXISTS idx_mailings_status ON mailings(status, scheduled_date);
CREATE INDEX IF NOT EXISTS idx_mailings_created_by ON mailings(created_by);
CREATE INDEX IF NOT EXISTS idx_mailing_recipients_mailing ON mailing_recipients(mailing_id, status);
CREATE INDEX IF NOT EXISTS idx_mailing_recipients_contact ON mailing_recipients(contact_id);
CREATE INDEX IF NOT EXISTS idx_mailing_recipients_email ON mailing_recipients(email);
CREATE INDEX IF NOT EXISTS idx_mailing_trackable_urls_mailing ON mailing_trackable_urls(mailing_id);
CREATE INDEX IF NOT EXISTS idx_mailing_url_clicks_url ON mailing_url_clicks(trackable_url_id);
CREATE INDEX IF NOT EXISTS idx_mailing_url_clicks_contact ON mailing_url_clicks(contact_id);
CREATE INDEX IF NOT EXISTS idx_mailing_opens_recipient ON mailing_opens(recipient_id);
CREATE INDEX IF NOT EXISTS idx_mailing_opens_contact ON mailing_opens(contact_id);
CREATE INDEX IF NOT EXISTS idx_sms_messages_contact ON sms_messages(contact_id, status);
CREATE INDEX IF NOT EXISTS idx_sms_messages_phone ON sms_messages(phone_number);
CREATE INDEX IF NOT EXISTS idx_communication_preferences_contact ON communication_preferences(contact_id);

-- Unique constraints
CREATE UNIQUE INDEX IF NOT EXISTS idx_message_templates_name ON message_templates(name);
CREATE UNIQUE INDEX IF NOT EXISTS idx_mailing_lists_name ON mailing_lists(name);
CREATE UNIQUE INDEX IF NOT EXISTS idx_mailing_list_subscriptions_unique ON mailing_list_subscriptions(mailing_list_id, contact_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_mailing_recipients_unique ON mailing_recipients(mailing_id, contact_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_communication_preferences_contact ON communication_preferences(contact_id);

-- Add comments for documentation
COMMENT ON TABLE message_templates IS 'Reusable message templates for emails, SMS, and letters';
COMMENT ON TABLE mailing_lists IS 'Groups of contacts for mass communications';
COMMENT ON TABLE mailing_list_subscriptions IS 'Contact subscriptions to mailing lists';
COMMENT ON TABLE mailings IS 'Individual email campaigns';
COMMENT ON TABLE mailing_recipients IS 'Individual recipients for each mailing';
COMMENT ON TABLE mailing_trackable_urls IS 'URLs in emails for click tracking';
COMMENT ON TABLE mailing_url_clicks IS 'Individual click tracking records';
COMMENT ON TABLE mailing_opens IS 'Email open tracking records';
COMMENT ON TABLE sms_messages IS 'Individual SMS messages';
COMMENT ON TABLE communication_preferences IS 'Contact communication preferences and opt-outs';
