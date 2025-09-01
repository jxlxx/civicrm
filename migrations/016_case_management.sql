-- Case management system tables
-- These tables handle the complete case management system for CiviCRM

-- Case types (Legal, Medical, Social Work, etc.)
CREATE TABLE case_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    weight INTEGER DEFAULT 0,
    definition TEXT, -- JSON definition of case structure
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Case status (Open, Closed, Urgent, etc.)
CREATE TABLE case_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    grouping TEXT, -- Open, Closed, etc.
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    color TEXT, -- Hex color for UI
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cases (core case records)
CREATE TABLE cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_type_id UUID NOT NULL REFERENCES case_types(id),
    subject TEXT NOT NULL,
    status_id UUID NOT NULL REFERENCES case_status(id),
    start_date DATE NOT NULL,
    end_date DATE,
    details TEXT,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    modified_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Case contacts (participants in cases)
CREATE TABLE case_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    role TEXT NOT NULL, -- Client, Case Worker, Advocate, etc.
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Case activities (activities specific to cases)
CREATE TABLE case_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Case tags (for categorizing cases)
CREATE TABLE case_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    tag_id UUID, -- Will reference tags when we add them
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_case_types_name ON case_types(name);
CREATE INDEX idx_case_types_is_active ON case_types(is_active);
CREATE INDEX idx_case_types_weight ON case_types(weight);

CREATE INDEX idx_case_status_name ON case_status(name);
CREATE INDEX idx_case_status_grouping ON case_status(grouping);
CREATE INDEX idx_case_status_weight ON case_status(weight);

CREATE INDEX idx_cases_case_type_id ON cases(case_type_id);
CREATE INDEX idx_cases_status_id ON cases(status_id);
CREATE INDEX idx_cases_start_date ON cases(start_date);
CREATE INDEX idx_cases_end_date ON cases(end_date);
CREATE INDEX idx_cases_is_deleted ON cases(is_deleted);
CREATE INDEX idx_cases_created_date ON cases(created_date);

CREATE INDEX idx_case_contacts_case_id ON case_contacts(case_id);
CREATE INDEX idx_case_contacts_contact_id ON case_contacts(contact_id);
CREATE INDEX idx_case_contacts_role ON case_contacts(role);
CREATE INDEX idx_case_contacts_is_active ON case_contacts(is_active);

CREATE INDEX idx_case_activities_case_id ON case_activities(case_id);
CREATE INDEX idx_case_activities_activity_id ON case_activities(activity_id);
CREATE INDEX idx_case_activities_is_deleted ON case_activities(is_deleted);

CREATE INDEX idx_case_tags_case_id ON case_tags(case_id);
CREATE INDEX idx_case_tags_tag_id ON case_tags(tag_id);

-- Add triggers for updated_at
CREATE TRIGGER update_case_types_updated_at BEFORE UPDATE ON case_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_case_status_updated_at BEFORE UPDATE ON case_status
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cases_updated_at BEFORE UPDATE ON cases
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_case_contacts_updated_at BEFORE UPDATE ON case_contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_case_activities_updated_at BEFORE UPDATE ON case_activities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_case_tags_updated_at BEFORE UPDATE ON case_tags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_case_tags_updated_at ON case_tags;
DROP TRIGGER IF EXISTS update_case_activities_updated_at ON case_activities;
DROP TRIGGER IF EXISTS update_case_contacts_updated_at ON case_contacts;
DROP TRIGGER IF EXISTS update_cases_updated_at ON cases;
DROP TRIGGER IF EXISTS update_case_status_updated_at ON case_status;
DROP TRIGGER IF EXISTS update_case_types_updated_at ON case_types;

-- Drop indexes
DROP INDEX IF EXISTS idx_case_tags_tag_id;
DROP INDEX IF EXISTS idx_case_tags_case_id;
DROP INDEX IF EXISTS idx_case_activities_is_deleted;
DROP INDEX IF EXISTS idx_case_activities_activity_id;
DROP INDEX IF EXISTS idx_case_activities_case_id;
DROP INDEX IF EXISTS idx_case_contacts_is_active;
DROP INDEX IF EXISTS idx_case_contacts_role;
DROP INDEX IF EXISTS idx_case_contacts_contact_id;
DROP INDEX IF EXISTS idx_case_contacts_case_id;
DROP INDEX IF EXISTS idx_cases_created_date;
DROP INDEX IF EXISTS idx_cases_is_deleted;
DROP INDEX IF EXISTS idx_cases_end_date;
DROP INDEX IF EXISTS idx_cases_start_date;
DROP INDEX IF EXISTS idx_cases_status_id;
DROP INDEX IF EXISTS idx_cases_case_type_id;
DROP INDEX IF EXISTS idx_case_status_weight;
DROP INDEX IF EXISTS idx_case_status_grouping;
DROP INDEX IF EXISTS idx_case_status_name;
DROP INDEX IF EXISTS idx_case_types_weight;
DROP INDEX IF EXISTS idx_case_types_is_active;
DROP INDEX IF EXISTS idx_case_types_name;

-- Drop tables
DROP TABLE IF EXISTS case_tags;
DROP TABLE IF EXISTS case_activities;
DROP TABLE IF EXISTS case_contacts;
DROP TABLE IF EXISTS cases;
DROP TABLE IF EXISTS case_status;
DROP TABLE IF EXISTS case_types;
