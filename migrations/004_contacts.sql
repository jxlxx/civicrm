CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_type TEXT NOT NULL CHECK (contact_type IN ('Individual', 'Organization', 'Household')),
    first_name TEXT,
    last_name TEXT,
    organization_name TEXT,
    email TEXT UNIQUE,
    phone TEXT,
    address_line_1 TEXT,
    address_line_2 TEXT,
    city TEXT,
    state_province TEXT,
    postal_code TEXT,
    country TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_contacts_contact_type ON contacts(contact_type);

CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

DROP TRIGGER IF EXISTS update_contacts_updated_at ON contacts;
DROP INDEX IF EXISTS idx_contacts_contact_type;
DROP INDEX IF EXISTS idx_contacts_email;
DROP TABLE IF EXISTS contacts;
