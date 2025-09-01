-- ACL System Tables
-- Access Control List for fine-grained permissions

-- ACL roles (Administrator, User, etc.)
CREATE TABLE acl_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Core ACL rules table
CREATE TABLE acls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    deny BOOLEAN NOT NULL DEFAULT FALSE, -- FALSE = allow, TRUE = deny
    entity_table TEXT NOT NULL, -- 'contacts', 'groups', 'acl_roles'
    entity_id UUID, -- ID of the entity owning this ACL
    operation TEXT NOT NULL, -- 'View', 'Edit', 'Delete', 'Create'
    object_table TEXT, -- Table of data being controlled
    object_id UUID, -- Specific object ID (NULL = all objects)
    acl_table TEXT, -- For grant/revoke entries
    acl_id UUID, -- ID of ACL being granted/revoked
    is_active BOOLEAN DEFAULT TRUE,
    priority INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ACL caching table for performance
CREATE TABLE acl_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE,
    acl_id UUID NOT NULL REFERENCES acls(id) ON DELETE CASCADE,
    modified_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Contact access cache - pre-computed permissions
CREATE TABLE acl_contact_cache (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES contacts(id) ON DELETE CASCADE, -- User checking permissions
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE, -- Contact being accessed
    operation TEXT NOT NULL, -- 'View', 'Edit', 'Delete'
    domain_id UUID NOT NULL DEFAULT gen_random_uuid(), -- Multi-domain support
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Role assignments to entities
CREATE TABLE acl_entity_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    acl_role_id UUID NOT NULL REFERENCES acl_roles(id) ON DELETE CASCADE,
    entity_table TEXT NOT NULL, -- 'contacts', 'groups'
    entity_id UUID NOT NULL, -- ID of the entity
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for ACL performance
CREATE INDEX idx_acls_entity_table_entity_id ON acls(entity_table, entity_id);
CREATE INDEX idx_acls_operation ON acls(operation);
CREATE INDEX idx_acls_object_table_object_id ON acls(object_table, object_id);
CREATE INDEX idx_acls_priority ON acls(priority);
CREATE INDEX idx_acl_cache_contact_id ON acl_cache(contact_id);
CREATE INDEX idx_acl_cache_acl_id ON acl_cache(acl_id);
CREATE INDEX idx_acl_contact_cache_user_contact_operation ON acl_contact_cache(user_id, contact_id, operation);
CREATE INDEX idx_acl_contact_cache_operation ON acl_contact_cache(operation);
CREATE INDEX idx_acl_entity_roles_role_entity ON acl_entity_roles(acl_role_id, entity_table, entity_id);

-- Add triggers for updated_at
CREATE TRIGGER update_acl_roles_updated_at BEFORE UPDATE ON acl_roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_acls_updated_at BEFORE UPDATE ON acls
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_acl_entity_roles_updated_at BEFORE UPDATE ON acl_entity_roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_acl_entity_roles_updated_at ON acl_entity_roles;
DROP TRIGGER IF EXISTS update_acls_updated_at ON acls;
DROP TRIGGER IF EXISTS update_acl_roles_updated_at ON acl_roles;

-- Drop indexes
DROP INDEX IF EXISTS idx_acl_entity_roles_role_entity;
DROP INDEX IF EXISTS idx_acl_contact_cache_operation;
DROP INDEX IF EXISTS idx_acl_contact_cache_user_contact_operation;
DROP INDEX IF EXISTS idx_acl_cache_acl_id;
DROP INDEX IF EXISTS idx_acl_cache_contact_id;
DROP INDEX IF EXISTS idx_acls_priority;
DROP INDEX IF EXISTS idx_acls_object_table_object_id;
DROP INDEX IF EXISTS idx_acls_operation;
DROP INDEX IF EXISTS idx_acls_entity_table_entity_id;

-- Drop tables
DROP TABLE IF EXISTS acl_entity_roles;
DROP TABLE IF EXISTS acl_contact_cache;
DROP TABLE IF EXISTS acl_cache;
DROP TABLE IF EXISTS acls;
DROP TABLE IF EXISTS acl_roles;
