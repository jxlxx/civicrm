-- Contact relationships and group management
-- These tables handle how contacts relate to each other and to groups

-- Relationship types (Employee of, Spouse of, etc.)
CREATE TABLE relationship_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_a_b TEXT NOT NULL, -- "Employee of"
    name_b_a TEXT NOT NULL, -- "Has Employee"
    description TEXT,
    contact_type_a TEXT, -- Individual, Organization, Household
    contact_type_b TEXT, -- Individual, Organization, Household
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Contact relationships
CREATE TABLE relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id_a UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    contact_id_b UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    relationship_type_id UUID NOT NULL REFERENCES relationship_types(id),
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    is_permission_a_b BOOLEAN DEFAULT FALSE, -- Can A see B's data?
    is_permission_b_a BOOLEAN DEFAULT FALSE, -- Can B see A's data?
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Groups
CREATE TABLE groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    title TEXT,
    description TEXT,
    source TEXT,
    saved_search_id UUID, -- Will reference saved searches when we add them
    is_active BOOLEAN DEFAULT TRUE,
    visibility TEXT DEFAULT 'User and User Admin Only', -- Public, Admin Only, User and User Admin Only
    where_clause TEXT,
    select_tables TEXT,
    where_tables TEXT,
    group_type TEXT, -- Access Control, Mailing List, etc.
    cache_date TIMESTAMP WITH TIME ZONE,
    refresh_date TIMESTAMP WITH TIME ZONE,
    parents TEXT, -- Serialized array of parent group IDs
    children TEXT, -- Serialized array of child group IDs
    is_hidden BOOLEAN DEFAULT FALSE,
    is_reserved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Group contacts (membership)
CREATE TABLE group_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'Added', -- Added, Removed, Pending
    location_id UUID, -- Will reference addresses when we add them
    email_id UUID, -- Will reference emails when we add them
    phone_id UUID, -- Will reference phones when we add them
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Group nesting (hierarchical groups)
CREATE TABLE group_nesting (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    child_group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_relationship_types_name_a_b ON relationship_types(name_a_b);
CREATE INDEX idx_relationship_types_name_b_a ON relationship_types(name_b_a);
CREATE INDEX idx_relationship_types_contact_type_a ON relationship_types(contact_type_a);
CREATE INDEX idx_relationship_types_contact_type_b ON relationship_types(contact_type_b);

CREATE INDEX idx_relationships_contact_id_a ON relationships(contact_id_a);
CREATE INDEX idx_relationships_contact_id_b ON relationships(contact_id_b);
CREATE INDEX idx_relationships_relationship_type_id ON relationships(relationship_type_id);
CREATE INDEX idx_relationships_is_active ON relationships(is_active);
CREATE INDEX idx_relationships_start_date ON relationships(start_date);
CREATE INDEX idx_relationships_end_date ON relationships(end_date);

CREATE INDEX idx_groups_name ON groups(name);
CREATE INDEX idx_groups_is_active ON groups(is_active);
CREATE INDEX idx_groups_visibility ON groups(visibility);
CREATE INDEX idx_groups_group_type ON groups(group_type);

CREATE INDEX idx_group_contacts_group_id ON group_contacts(group_id);
CREATE INDEX idx_group_contacts_contact_id ON group_contacts(contact_id);
CREATE INDEX idx_group_contacts_status ON group_contacts(status);

CREATE INDEX idx_group_nesting_parent_group_id ON group_nesting(parent_group_id);
CREATE INDEX idx_group_nesting_child_group_id ON group_nesting(child_group_id);

-- Add triggers for updated_at
CREATE TRIGGER update_relationship_types_updated_at BEFORE UPDATE ON relationship_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_relationships_updated_at BEFORE UPDATE ON relationships
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_groups_updated_at BEFORE UPDATE ON groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_contacts_updated_at BEFORE UPDATE ON group_contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_nesting_updated_at BEFORE UPDATE ON group_nesting
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_group_nesting_updated_at ON group_nesting;
DROP TRIGGER IF EXISTS update_group_contacts_updated_at ON group_contacts;
DROP TRIGGER IF EXISTS update_groups_updated_at ON groups;
DROP TRIGGER IF EXISTS update_relationships_updated_at ON relationships;
DROP TRIGGER IF EXISTS update_relationship_types_updated_at ON relationship_types;

-- Drop indexes
DROP INDEX IF EXISTS idx_group_nesting_child_group_id;
DROP INDEX IF EXISTS idx_group_nesting_parent_group_id;
DROP INDEX IF EXISTS idx_group_contacts_status;
DROP INDEX IF EXISTS idx_group_contacts_contact_id;
DROP INDEX IF EXISTS idx_group_contacts_group_id;
DROP INDEX IF EXISTS idx_groups_group_type;
DROP INDEX IF EXISTS idx_groups_visibility;
DROP INDEX IF EXISTS idx_groups_is_active;
DROP INDEX IF EXISTS idx_groups_name;
DROP INDEX IF EXISTS idx_relationships_end_date;
DROP INDEX IF EXISTS idx_relationships_start_date;
DROP INDEX IF EXISTS idx_relationships_is_active;
DROP INDEX IF EXISTS idx_relationships_relationship_type_id;
DROP INDEX IF EXISTS idx_relationships_contact_id_b;
DROP INDEX IF EXISTS idx_relationships_contact_id_a;
DROP INDEX IF EXISTS idx_relationship_types_contact_type_b;
DROP INDEX IF EXISTS idx_relationship_types_contact_type_a;
DROP INDEX IF EXISTS idx_relationship_types_name_b_a;
DROP INDEX IF EXISTS idx_relationship_types_name_a_b;

-- Drop tables
DROP TABLE IF EXISTS group_nesting;
DROP TABLE IF EXISTS group_contacts;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS relationships;
DROP TABLE IF EXISTS relationship_types;
