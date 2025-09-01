-- Seed data for core infrastructure tables
-- This provides initial data needed for the system to function

-- Location types
INSERT INTO location_types (name, display_name, description, vcard_name) VALUES
    ('Home', 'Home', 'Home address', 'HOME'),
    ('Work', 'Work', 'Work address', 'WORK'),
    ('Billing', 'Billing', 'Billing address', 'BILLING'),
    ('Main', 'Main', 'Main address', 'MAIN'),
    ('Other', 'Other', 'Other address', 'OTHER');

-- Financial types
INSERT INTO financial_types (name, description, is_deductible, is_reserved) VALUES
    ('Donation', 'General donation', TRUE, FALSE),
    ('Membership', 'Membership dues', TRUE, FALSE),
    ('Event', 'Event registration fee', FALSE, FALSE),
    ('Grant', 'Grant funding', FALSE, FALSE),
    ('Sponsorship', 'Event sponsorship', TRUE, FALSE),
    ('In Kind', 'In-kind contribution', TRUE, FALSE);

-- Payment instruments
INSERT INTO payment_instruments (name, description) VALUES
    ('Credit Card', 'Credit card payment'),
    ('Check', 'Check payment'),
    ('Cash', 'Cash payment'),
    ('EFT', 'Electronic funds transfer'),
    ('Debit Card', 'Debit card payment'),
    ('Money Order', 'Money order'),
    ('PayPal', 'PayPal payment'),
    ('Stripe', 'Stripe payment'),
    ('Other', 'Other payment method');

-- Event types
INSERT INTO event_types (name, description) VALUES
    ('Conference', 'Conference or symposium'),
    ('Workshop', 'Training workshop'),
    ('Fundraiser', 'Fundraising event'),
    ('Meeting', 'General meeting'),
    ('Seminar', 'Educational seminar'),
    ('Webinar', 'Online webinar'),
    ('Training', 'Training session'),
    ('Networking', 'Networking event'),
    ('Award Ceremony', 'Award or recognition event'),
    ('Other', 'Other event type');

-- Participant status types
INSERT INTO participant_status_types (name, label, class, is_counted, weight) VALUES
    ('Registered', 'Registered', 'Positive', TRUE, 1),
    ('Attended', 'Attended', 'Positive', TRUE, 2),
    ('No-show', 'No-show', 'Negative', FALSE, 3),
    ('Cancelled', 'Cancelled', 'Negative', FALSE, 4),
    ('Pending from waitlist', 'Pending from waitlist', 'Pending', FALSE, 5),
    ('Waitlist', 'Waitlist', 'Pending', FALSE, 6),
    ('Partially attended', 'Partially attended', 'Positive', TRUE, 7),
    ('Pending approval', 'Pending approval', 'Pending', FALSE, 8),
    ('Rejected', 'Rejected', 'Negative', FALSE, 9);

-- Countries (major countries)
INSERT INTO countries (name, iso_code, numeric_code) VALUES
    ('United States', 'US', '840'),
    ('Canada', 'CA', '124'),
    ('United Kingdom', 'GB', '826'),
    ('Germany', 'DE', '276'),
    ('France', 'FR', '250'),
    ('Australia', 'AU', '036'),
    ('Japan', 'JP', '392'),
    ('China', 'CN', '156'),
    ('India', 'IN', '356'),
    ('Brazil', 'BR', '076'),
    ('Mexico', 'MX', '484'),
    ('South Africa', 'ZA', '710');

-- States/Provinces for US and Canada
INSERT INTO state_provinces (name, abbreviation, country_id) VALUES
    -- US States
    ('Alabama', 'AL', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Alaska', 'AK', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Arizona', 'AZ', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('California', 'CA', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Colorado', 'CO', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Connecticut', 'CT', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Delaware', 'DE', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Florida', 'FL', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Georgia', 'GA', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Hawaii', 'HI', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Illinois', 'IL', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Indiana', 'IN', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Iowa', 'IA', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Kansas', 'KS', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Kentucky', 'KY', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Louisiana', 'LA', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Maine', 'ME', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Maryland', 'MD', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Massachusetts', 'MA', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Michigan', 'MI', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Minnesota', 'MN', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Mississippi', 'MS', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Missouri', 'MO', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Montana', 'MT', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Nebraska', 'NE', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Nevada', 'NV', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('New Hampshire', 'NH', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('New Jersey', 'NJ', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('New Mexico', 'NM', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('New York', 'NY', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('North Carolina', 'NC', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('North Dakota', 'ND', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Ohio', 'OH', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Oklahoma', 'OK', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Oregon', 'OR', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Pennsylvania', 'PA', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Rhode Island', 'RI', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('South Carolina', 'SC', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('South Dakota', 'SD', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Tennessee', 'TN', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Texas', 'TX', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Utah', 'UT', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Vermont', 'VT', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Virginia', 'VA', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Washington', 'WA', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('West Virginia', 'WV', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Wisconsin', 'WI', (SELECT id FROM countries WHERE iso_code = 'US')),
    ('Wyoming', 'WY', (SELECT id FROM countries WHERE iso_code = 'US')),
    -- Canadian Provinces
    ('Alberta', 'AB', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('British Columbia', 'BC', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('Manitoba', 'MB', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('New Brunswick', 'NB', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('Newfoundland and Labrador', 'NL', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('Nova Scotia', 'NS', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('Ontario', 'ON', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('Prince Edward Island', 'PE', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('Quebec', 'QC', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('Saskatchewan', 'SK', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('Northwest Territories', 'NT', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('Nunavut', 'NU', (SELECT id FROM countries WHERE iso_code = 'CA')),
    ('Yukon', 'YT', (SELECT id FROM countries WHERE iso_code = 'CA'));

-- Relationship types
INSERT INTO relationship_types (name_a_b, name_b_a, description, contact_type_a, contact_type_b) VALUES
    ('Employee of', 'Has Employee', 'Employment relationship', 'Individual', 'Organization'),
    ('Spouse of', 'Spouse of', 'Spousal relationship', 'Individual', 'Individual'),
    ('Child of', 'Parent of', 'Parent-child relationship', 'Individual', 'Individual'),
    ('Parent of', 'Child of', 'Parent-child relationship', 'Individual', 'Individual'),
    ('Volunteer for', 'Has Volunteer', 'Volunteer relationship', 'Individual', 'Organization'),
    ('Member of', 'Has Member', 'Membership relationship', 'Individual', 'Organization'),
    ('Donor to', 'Has Donor', 'Donor relationship', 'Individual', 'Organization'),
    ('Board Member of', 'Has Board Member', 'Board membership', 'Individual', 'Organization'),
    ('Partner of', 'Partner of', 'Partnership relationship', 'Individual', 'Individual'),
    ('Sibling of', 'Sibling of', 'Sibling relationship', 'Individual', 'Individual');

-- ACL System Seed Data
-- Basic roles for the permission system

-- Create basic ACL roles
INSERT INTO acl_roles (name, label, description) VALUES
    ('administrator', 'Administrator', 'Full system access with all permissions'),
    ('user', 'User', 'Standard user with basic permissions'),
    ('everyone', 'Everyone', 'Anonymous user permissions'),
    ('authenticated', 'Authenticated User', 'Logged-in user permissions');

-- Create basic ACL rules for administrators (full access)
INSERT INTO acls (name, deny, entity_table, entity_id, operation, object_table, object_id, priority) VALUES
    ('Admin View All Contacts', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'administrator'), 'View', 'contacts', NULL, 1),
    ('Admin Edit All Contacts', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'administrator'), 'Edit', 'contacts', NULL, 1),
    ('Admin Delete All Contacts', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'administrator'), 'Delete', 'contacts', NULL, 1),
    ('Admin View All Groups', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'administrator'), 'View', 'groups', NULL, 1),
    ('Admin Edit All Groups', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'administrator'), 'Edit', 'groups', NULL, 1),
    ('Admin View All Events', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'administrator'), 'View', 'events', NULL, 1),
    ('Admin Edit All Events', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'administrator'), 'Edit', 'events', NULL, 1);

-- Create basic ACL rules for authenticated users (limited access)
INSERT INTO acls (name, deny, entity_table, entity_id, operation, object_table, object_id, priority) VALUES
    ('User View Own Contact', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'authenticated'), 'View', 'contacts', NULL, 10),
    ('User Edit Own Contact', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'authenticated'), 'Edit', 'contacts', NULL, 10),
    ('User View Public Events', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'authenticated'), 'View', 'events', NULL, 10),
    ('User View Public Groups', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'authenticated'), 'View', 'groups', NULL, 10);

-- Create basic ACL rules for everyone (anonymous access)
INSERT INTO acls (name, deny, entity_table, entity_id, operation, object_table, object_id, priority) VALUES
    ('Public View Public Events', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'everyone'), 'View', 'events', NULL, 100),
    ('Public View Public Groups', FALSE, 'acl_roles', (SELECT id FROM acl_roles WHERE name = 'everyone'), 'View', 'groups', NULL, 100);

-- Create default admin user
-- Note: In production, you should change this password!
INSERT INTO users (username, email, hashed_password, is_admin) VALUES
    ('admin', 'admin@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', TRUE); -- password: password

-- Create admin contact and link to user
INSERT INTO contacts (contact_type, first_name, last_name, email, is_active) VALUES
    ('Individual', 'System', 'Administrator', 'admin@example.com', TRUE);

-- Link admin user to admin contact via uf_match
INSERT INTO uf_match (uf_id, uf_name, contact_id) VALUES
    ((SELECT id FROM users WHERE username = 'admin'), 'admin', (SELECT id FROM contacts WHERE email = 'admin@example.com'));

-- Assign admin user to administrator role
INSERT INTO acl_entity_roles (acl_role_id, entity_table, entity_id) VALUES
    ((SELECT id FROM acl_roles WHERE name = 'administrator'), 'users', (SELECT id FROM users WHERE username = 'admin'));
