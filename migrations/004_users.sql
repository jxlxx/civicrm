-- User Management Tables
-- Authentication and authorization for system users

-- Users table for authentication and authorization
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    hashed_password TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Framework Match table - links CMS users to CiviCRM contacts
CREATE TABLE uf_match (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_id UUID NOT NULL DEFAULT gen_random_uuid(), -- Multi-domain support
    uf_id UUID NOT NULL, -- CMS user ID
    uf_name TEXT, -- CMS username
    contact_id UUID REFERENCES contacts(id) ON DELETE CASCADE, -- CiviCRM contact ID
    language TEXT, -- Preferred language
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for user performance
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_uf_match_uf_id ON uf_match(uf_id);
CREATE INDEX idx_uf_match_contact_id ON uf_match(contact_id);
CREATE INDEX idx_uf_match_uf_name ON uf_match(uf_name);

-- Add triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_uf_match_updated_at BEFORE UPDATE ON uf_match
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_uf_match_updated_at ON uf_match;
DROP TRIGGER IF EXISTS update_users_updated_at ON users;

-- Drop indexes
DROP INDEX IF EXISTS idx_uf_match_uf_name;
DROP INDEX IF EXISTS idx_uf_match_contact_id;
DROP INDEX IF EXISTS idx_uf_match_uf_id;
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_users_username;

-- Drop tables
DROP TABLE IF EXISTS uf_match;
DROP TABLE IF EXISTS users;
