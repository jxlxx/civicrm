-- Activity system tables
-- These tables form the core of CiviCRM's activity tracking system

-- Activity types (Call, Meeting, Email, etc.)
CREATE TABLE activity_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    is_target BOOLEAN DEFAULT FALSE,
    is_multi_record BOOLEAN DEFAULT FALSE,
    is_component BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activities (core activity records)
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_type_id UUID NOT NULL REFERENCES activity_types(id),
    subject TEXT,
    activity_date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration INTEGER, -- in minutes
    location TEXT,
    phone_id UUID, -- Will reference phones when we add them
    phone_number TEXT,
    details TEXT,
    status_id UUID, -- Will reference activity_status when we add them
    priority_id UUID, -- Will reference activity_priority when we add them
    parent_id UUID REFERENCES activities(id),
    is_test BOOLEAN DEFAULT FALSE,
    medium_id UUID, -- Will reference activity_medium when we add them
    is_auto BOOLEAN DEFAULT FALSE,
    relationship_id UUID, -- Will reference relationships when we add them
    is_current_revision BOOLEAN DEFAULT TRUE,
    original_id UUID REFERENCES activities(id),
    result TEXT,
    is_deleted BOOLEAN DEFAULT FALSE,
    campaign_id UUID, -- Will reference campaigns when we add them
    engagement_level INTEGER,
    weight INTEGER DEFAULT 0,
    is_star BOOLEAN DEFAULT FALSE,
    created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    modified_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity contacts (participants in activities)
CREATE TABLE activity_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    record_type_id UUID, -- Will reference activity_contact_record_types when we add them
    role TEXT, -- Assignee, Source, Target, etc.
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity assignments (who is assigned to activities)
CREATE TABLE activity_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    assignee_contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity status (Scheduled, Completed, Cancelled, etc.)
CREATE TABLE activity_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity priority (Low, Normal, High, Urgent)
CREATE TABLE activity_priority (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity medium (Phone, Email, In Person, etc.)
CREATE TABLE activity_medium (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_activity_types_name ON activity_types(name);
CREATE INDEX idx_activity_types_is_active ON activity_types(is_active);

CREATE INDEX idx_activities_activity_type_id ON activities(activity_type_id);
CREATE INDEX idx_activities_activity_date_time ON activities(activity_date_time);
CREATE INDEX idx_activities_status_id ON activities(status_id);
CREATE INDEX idx_activities_is_deleted ON activities(is_deleted);
CREATE INDEX idx_activities_campaign_id ON activities(campaign_id);
CREATE INDEX idx_activities_parent_id ON activities(parent_id);
CREATE INDEX idx_activities_created_date ON activities(created_date);

CREATE INDEX idx_activity_contacts_activity_id ON activity_contacts(activity_id);
CREATE INDEX idx_activity_contacts_contact_id ON activity_contacts(contact_id);
CREATE INDEX idx_activity_contacts_record_type_id ON activity_contacts(record_type_id);
CREATE INDEX idx_activity_contacts_role ON activity_contacts(role);

CREATE INDEX idx_activity_assignments_activity_id ON activity_assignments(activity_id);
CREATE INDEX idx_activity_assignments_assignee_contact_id ON activity_assignments(assignee_contact_id);

CREATE INDEX idx_activity_status_name ON activity_status(name);
CREATE INDEX idx_activity_status_weight ON activity_status(weight);

CREATE INDEX idx_activity_priority_name ON activity_priority(name);
CREATE INDEX idx_activity_priority_weight ON activity_priority(weight);

CREATE INDEX idx_activity_medium_name ON activity_medium(name);
CREATE INDEX idx_activity_medium_weight ON activity_medium(weight);

-- Add triggers for updated_at
CREATE TRIGGER update_activity_types_updated_at BEFORE UPDATE ON activity_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activities_updated_at BEFORE UPDATE ON activities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activity_contacts_updated_at BEFORE UPDATE ON activity_contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activity_assignments_updated_at BEFORE UPDATE ON activity_assignments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activity_status_updated_at BEFORE UPDATE ON activity_status
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activity_priority_updated_at BEFORE UPDATE ON activity_priority
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activity_medium_updated_at BEFORE UPDATE ON activity_medium
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_activity_medium_updated_at ON activity_medium;
DROP TRIGGER IF EXISTS update_activity_priority_updated_at ON activity_priority;
DROP TRIGGER IF EXISTS update_activity_status_updated_at ON activity_status;
DROP TRIGGER IF EXISTS update_activity_assignments_updated_at ON activity_assignments;
DROP TRIGGER IF EXISTS update_activity_contacts_updated_at ON activity_contacts;
DROP TRIGGER IF EXISTS update_activities_updated_at ON activities;
DROP TRIGGER IF EXISTS update_activity_types_updated_at ON activity_types;

-- Drop indexes
DROP INDEX IF EXISTS idx_activity_medium_weight;
DROP INDEX IF EXISTS idx_activity_medium_name;
DROP INDEX IF EXISTS idx_activity_priority_weight;
DROP INDEX IF EXISTS idx_activity_priority_name;
DROP INDEX IF EXISTS idx_activity_status_weight;
DROP INDEX IF EXISTS idx_activity_status_name;
DROP INDEX IF EXISTS idx_activity_assignments_assignee_contact_id;
DROP INDEX IF EXISTS idx_activity_assignments_activity_id;
DROP INDEX IF EXISTS idx_activity_contacts_role;
DROP INDEX IF EXISTS idx_activity_contacts_record_type_id;
DROP INDEX IF EXISTS idx_activity_contacts_contact_id;
DROP INDEX IF EXISTS idx_activity_contacts_activity_id;
DROP INDEX IF EXISTS idx_activities_created_date;
DROP INDEX IF EXISTS idx_activities_parent_id;
DROP INDEX IF EXISTS idx_activities_campaign_id;
DROP INDEX IF EXISTS idx_activities_is_deleted;
DROP INDEX IF EXISTS idx_activities_status_id;
DROP INDEX IF EXISTS idx_activities_activity_date_time;
DROP INDEX IF EXISTS idx_activities_activity_type_id;
DROP INDEX IF EXISTS idx_activity_types_is_active;
DROP INDEX IF EXISTS idx_activity_types_name;

-- Drop tables
DROP TABLE IF EXISTS activity_medium;
DROP TABLE IF EXISTS activity_priority;
DROP TABLE IF EXISTS activity_status;
DROP TABLE IF EXISTS activity_assignments;
DROP TABLE IF EXISTS activity_contacts;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS activity_types;
