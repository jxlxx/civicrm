-- Communication System Queries
-- Provides CRUD operations and specialized queries for message templates, mailings, and tracking

-- Message Templates CRUD operations
-- name: CreateMessageTemplate :one
INSERT INTO message_templates (
    name, title, subject, body_text, body_html, template_type, 
    is_active, is_default, workflow_name
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetMessageTemplate :one
SELECT * FROM message_templates WHERE id = $1;

-- name: GetMessageTemplateByName :one
SELECT * FROM message_templates WHERE name = $1;

-- name: ListMessageTemplates :many
SELECT * FROM message_templates 
WHERE template_type = $1 AND is_active = $2
ORDER BY title;

-- name: ListMessageTemplatesByWorkflow :many
SELECT * FROM message_templates 
WHERE workflow_name = $1 AND is_active = $2
ORDER BY title;

-- name: UpdateMessageTemplate :one
UPDATE message_templates SET
    title = $2,
    subject = $3,
    body_text = $4,
    body_html = $5,
    template_type = $6,
    is_active = $7,
    is_default = $8,
    workflow_name = $9,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteMessageTemplate :exec
DELETE FROM message_templates WHERE id = $1;

-- Mailing Lists CRUD operations
-- name: CreateMailingList :one
INSERT INTO mailing_lists (
    name, title, description, is_public, is_hidden, is_active
) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *;

-- name: GetMailingList :one
SELECT * FROM mailing_lists WHERE id = $1;

-- name: GetMailingListByName :one
SELECT * FROM mailing_lists WHERE name = $1;

-- name: ListMailingLists :many
SELECT * FROM mailing_lists 
WHERE is_active = $1 AND is_hidden = $2
ORDER BY title;

-- name: UpdateMailingList :one
UPDATE mailing_lists SET
    title = $2,
    description = $3,
    is_public = $4,
    is_hidden = $5,
    is_active = $6,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteMailingList :exec
DELETE FROM mailing_lists WHERE id = $1;

-- Mailing List Subscriptions CRUD operations
-- name: CreateMailingListSubscription :one
INSERT INTO mailing_list_subscriptions (
    mailing_list_id, contact_id, status, source, is_active
) VALUES ($1, $2, $3, $4, $5) RETURNING *;

-- name: GetMailingListSubscription :one
SELECT * FROM mailing_list_subscriptions WHERE id = $1;

-- name: GetSubscriptionByContactAndList :one
SELECT * FROM mailing_list_subscriptions 
WHERE mailing_list_id = $1 AND contact_id = $2;

-- name: ListSubscriptionsByList :many
SELECT mls.*, c.first_name, c.last_name, c.email
FROM mailing_list_subscriptions mls
INNER JOIN contacts c ON mls.contact_id = c.id
WHERE mls.mailing_list_id = $1 AND mls.is_active = $2
ORDER BY c.last_name, c.first_name;

-- name: ListSubscriptionsByContact :many
SELECT mls.*, ml.name as list_name, ml.title as list_title
FROM mailing_list_subscriptions mls
INNER JOIN mailing_lists ml ON mls.mailing_list_id = ml.id
WHERE mls.contact_id = $1 AND mls.is_active = $2
ORDER BY ml.title;

-- name: UpdateSubscriptionStatus :one
UPDATE mailing_list_subscriptions SET
    status = $3,
    updated_at = NOW()
WHERE mailing_list_id = $1 AND contact_id = $2 RETURNING *;

-- name: DeleteMailingListSubscription :exec
DELETE FROM mailing_list_subscriptions WHERE id = $1;

-- Mailings CRUD operations
-- name: CreateMailing :one
INSERT INTO mailings (
    name, subject, body_text, body_html, template_id, mailing_list_id,
    status, scheduled_date, created_by
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: GetMailing :one
SELECT * FROM mailings WHERE id = $1;

-- name: ListMailings :many
SELECT * FROM mailings 
WHERE status = $1
ORDER BY created_at DESC;

-- name: ListMailingsByCreator :many
SELECT * FROM mailings 
WHERE created_by = $1
ORDER BY created_at DESC;

-- name: UpdateMailingStatus :one
UPDATE mailings SET
    status = $2,
    start_date = $3,
    end_date = $4,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: UpdateMailingStats :one
UPDATE mailings SET
    total_sent = $2,
    total_opened = $3,
    total_clicked = $4,
    total_bounced = $5,
    total_unsubscribed = $6,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteMailing :exec
DELETE FROM mailings WHERE id = $1;

-- Mailing Recipients CRUD operations
-- name: CreateMailingRecipient :one
INSERT INTO mailing_recipients (
    mailing_id, contact_id, email, status
) VALUES ($1, $2, $3, $4) RETURNING *;

-- name: GetMailingRecipient :one
SELECT * FROM mailing_recipients WHERE id = $1;

-- name: GetRecipientByMailingAndContact :one
SELECT * FROM mailing_recipients 
WHERE mailing_id = $1 AND contact_id = $2;

-- name: ListRecipientsByMailing :many
SELECT mr.*, c.first_name, c.last_name, c.email as contact_email
FROM mailing_recipients mr
INNER JOIN contacts c ON mr.contact_id = c.id
WHERE mr.mailing_id = $1
ORDER BY c.last_name, c.first_name;

-- name: UpdateRecipientStatus :one
UPDATE mailing_recipients SET
    status = $3,
    sent_date = $4,
    delivered_date = $5,
    opened_date = $6,
    clicked_date = $7,
    bounce_reason = $8,
    updated_at = NOW()
WHERE mailing_id = $1 AND contact_id = $2 RETURNING *;

-- name: DeleteMailingRecipient :exec
DELETE FROM mailing_recipients WHERE id = $1;

-- Mailing Tracking CRUD operations
-- name: CreateTrackableUrl :one
INSERT INTO mailing_trackable_urls (
    mailing_id, url, original_url
) VALUES ($1, $2, $3) RETURNING *;

-- name: GetTrackableUrl :one
SELECT * FROM mailing_trackable_urls WHERE id = $1;

-- name: ListTrackableUrlsByMailing :many
SELECT * FROM mailing_trackable_urls 
WHERE mailing_id = $1
ORDER BY created_at;

-- name: UpdateUrlClickCount :one
UPDATE mailing_trackable_urls SET
    click_count = $2,
    unique_clicks = $3
WHERE id = $1 RETURNING *;

-- name: CreateUrlClick :one
INSERT INTO mailing_url_clicks (
    trackable_url_id, recipient_id, contact_id, ip_address, user_agent
) VALUES ($1, $2, $3, $4, $5) RETURNING *;

-- name: CreateMailingOpen :one
INSERT INTO mailing_opens (
    recipient_id, contact_id, ip_address, user_agent
) VALUES ($1, $2, $3, $4) RETURNING *;

-- SMS Messages CRUD operations
-- name: CreateSmsMessage :one
INSERT INTO sms_messages (
    contact_id, phone_number, message, direction, status, provider
) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *;

-- name: GetSmsMessage :one
SELECT * FROM sms_messages WHERE id = $1;

-- name: ListSmsMessagesByContact :many
SELECT * FROM sms_messages 
WHERE contact_id = $1
ORDER BY created_at DESC;

-- name: UpdateSmsStatus :one
UPDATE sms_messages SET
    status = $2,
    sent_at = $3,
    delivered_at = $4,
    updated_at = NOW()
WHERE id = $1 RETURNING *;

-- name: DeleteSmsMessage :exec
DELETE FROM sms_messages WHERE id = $1;

-- Communication Preferences CRUD operations
-- name: CreateCommunicationPreferences :one
INSERT INTO communication_preferences (
    contact_id, email_opt_out, sms_opt_out, mail_opt_out, phone_opt_out,
    do_not_email, do_not_sms, do_not_mail, do_not_phone, do_not_trade
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *;

-- name: GetCommunicationPreferences :one
SELECT * FROM communication_preferences WHERE contact_id = $1;

-- name: UpdateCommunicationPreferences :one
UPDATE communication_preferences SET
    email_opt_out = $2,
    sms_opt_out = $3,
    mail_opt_out = $4,
    phone_opt_out = $5,
    do_not_email = $6,
    do_not_sms = $7,
    do_not_mail = $8,
    do_not_phone = $9,
    do_not_trade = $10,
    updated_at = NOW()
WHERE contact_id = $1 RETURNING *;

-- name: DeleteCommunicationPreferences :exec
DELETE FROM communication_preferences WHERE contact_id = $1;

-- Specialized queries for communication system
-- name: GetMailingStats :one
SELECT 
    COUNT(*) as total_recipients,
    COUNT(CASE WHEN status = 'Sent' THEN 1 END) as total_sent,
    COUNT(CASE WHEN status = 'Delivered' THEN 1 END) as total_delivered,
    COUNT(CASE WHEN status = 'Opened' THEN 1 END) as total_opened,
    COUNT(CASE WHEN status = 'Clicked' THEN 1 END) as total_clicked,
    COUNT(CASE WHEN status = 'Bounced' THEN 1 END) as total_bounced,
    COUNT(CASE WHEN status = 'Unsubscribed' THEN 1 END) as total_unsubscribed
FROM mailing_recipients 
WHERE mailing_id = $1;

-- name: GetMailingPerformance :many
SELECT 
    DATE(created_at) as date,
    COUNT(*) as sent,
    COUNT(CASE WHEN opened_date IS NOT NULL THEN 1 END) as opened,
    COUNT(CASE WHEN clicked_date IS NOT NULL THEN 1 END) as clicked
FROM mailing_recipients 
WHERE mailing_id = $1 AND status IN ('Sent', 'Delivered', 'Opened', 'Clicked')
GROUP BY DATE(created_at)
ORDER BY date;

-- name: GetTopClickedUrls :many
SELECT 
    mtu.original_url,
    mtu.click_count,
    mtu.unique_clicks
FROM mailing_trackable_urls mtu
WHERE mtu.mailing_id = $1
ORDER BY mtu.click_count DESC
LIMIT $2;

-- name: GetContactCommunicationHistory :many
SELECT 
    'Email' as type,
    m.name as campaign_name,
    mr.status,
    mr.sent_date,
    mr.opened_date,
    mr.clicked_date
FROM mailing_recipients mr
INNER JOIN mailings m ON mr.mailing_id = m.id
WHERE mr.contact_id = $1 AND mr.status IN ('Sent', 'Delivered', 'Opened', 'Clicked')
UNION ALL
SELECT 
    'SMS' as type,
    sm.message as campaign_name,
    sm.status,
    sm.sent_at as sent_date,
    NULL as opened_date,
    NULL as clicked_date
FROM sms_messages sm
WHERE sm.contact_id = $1
ORDER BY sent_date DESC
LIMIT $2;

-- name: GetOptOutContacts :many
SELECT 
    c.id, c.first_name, c.last_name, c.email,
    cp.email_opt_out, cp.sms_opt_out, cp.mail_opt_out, cp.phone_opt_out
FROM contacts c
INNER JOIN communication_preferences cp ON c.id = cp.contact_id
WHERE cp.email_opt_out = $1 OR cp.sms_opt_out = $2 OR cp.mail_opt_out = $3 OR cp.phone_opt_out = $4
ORDER BY c.last_name, c.first_name
LIMIT $5 OFFSET $6;

-- name: CountContactsByOptOutStatus :one
SELECT 
    COUNT(CASE WHEN email_opt_out = true THEN 1 END) as email_opt_out_count,
    COUNT(CASE WHEN sms_opt_out = true THEN 1 END) as sms_opt_out_count,
    COUNT(CASE WHEN mail_opt_out = true THEN 1 END) as mail_opt_out_count,
    COUNT(CASE WHEN phone_opt_out = true THEN 1 END) as phone_opt_out_count
FROM communication_preferences;
