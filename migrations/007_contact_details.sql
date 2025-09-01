-- Normalized contact detail tables
-- These tables store contact information in a normalized structure

-- Addresses (separate from contacts table)
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    location_type_id UUID REFERENCES location_types(id),
    is_primary BOOLEAN DEFAULT FALSE,
    is_billing BOOLEAN DEFAULT FALSE,
    street_address TEXT,
    street_number TEXT,
    street_name TEXT,
    street_unit TEXT,
    city TEXT,
    state_province_id UUID REFERENCES state_provinces(id),
    postal_code TEXT,
    country_id UUID REFERENCES countries(id),
    geo_code_1 DECIMAL(10,8), -- Latitude
    geo_code_2 DECIMAL(11,8), -- Longitude
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Phone numbers
CREATE TABLE phones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    location_type_id UUID REFERENCES location_types(id),
    phone_type TEXT, -- Phone, Mobile, Fax, Pager
    is_primary BOOLEAN DEFAULT FALSE,
    phone TEXT NOT NULL,
    phone_ext TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Email addresses
CREATE TABLE emails (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    location_type_id UUID REFERENCES location_types(id),
    is_primary BOOLEAN DEFAULT FALSE,
    is_billing BOOLEAN DEFAULT FALSE,
    email TEXT NOT NULL,
    on_hold BOOLEAN DEFAULT FALSE,
    is_bulkmail BOOLEAN DEFAULT FALSE,
    hold_date TIMESTAMP WITH TIME ZONE,
    reset_date TIMESTAMP WITH TIME ZONE,
    signature_text TEXT,
    signature_html TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Websites
CREATE TABLE websites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    website_type_id UUID, -- Will reference option_values when we add them
    url TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- IM (Instant Messaging)
CREATE TABLE ims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    location_type_id UUID REFERENCES location_types(id),
    provider_id UUID, -- Will reference option_values when we add them
    name TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    is_billing BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_addresses_contact_id ON addresses(contact_id);
CREATE INDEX idx_addresses_location_type_id ON addresses(location_type_id);
CREATE INDEX idx_addresses_is_primary ON addresses(is_primary);
CREATE INDEX idx_addresses_city ON addresses(city);
CREATE INDEX idx_addresses_postal_code ON addresses(postal_code);

CREATE INDEX idx_phones_contact_id ON phones(contact_id);
CREATE INDEX idx_phones_location_type_id ON phones(location_type_id);
CREATE INDEX idx_phones_is_primary ON phones(is_primary);
CREATE INDEX idx_phones_phone ON phones(phone);

CREATE INDEX idx_emails_contact_id ON emails(contact_id);
CREATE INDEX idx_emails_location_type_id ON emails(location_type_id);
CREATE INDEX idx_emails_is_primary ON emails(is_primary);
CREATE INDEX idx_emails_email ON emails(email);
CREATE INDEX idx_emails_on_hold ON emails(on_hold);

CREATE INDEX idx_websites_contact_id ON websites(contact_id);
CREATE INDEX idx_ims_contact_id ON ims(contact_id);
CREATE INDEX idx_ims_location_type_id ON ims(location_type_id);

-- Add triggers for updated_at
CREATE TRIGGER update_addresses_updated_at BEFORE UPDATE ON addresses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_phones_updated_at BEFORE UPDATE ON phones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_emails_updated_at BEFORE UPDATE ON emails
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_websites_updated_at BEFORE UPDATE ON websites
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ims_updated_at BEFORE UPDATE ON ims
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_ims_updated_at ON ims;
DROP TRIGGER IF EXISTS update_websites_updated_at ON websites;
DROP TRIGGER IF EXISTS update_emails_updated_at ON emails;
DROP TRIGGER IF EXISTS update_phones_updated_at ON phones;
DROP TRIGGER IF EXISTS update_addresses_updated_at ON addresses;

-- Drop indexes
DROP INDEX IF EXISTS idx_ims_location_type_id;
DROP INDEX IF EXISTS idx_ims_contact_id;
DROP INDEX IF EXISTS idx_websites_contact_id;
DROP INDEX IF EXISTS idx_emails_on_hold;
DROP INDEX IF EXISTS idx_emails_email;
DROP INDEX IF EXISTS idx_emails_is_primary;
DROP INDEX IF EXISTS idx_emails_location_type_id;
DROP INDEX IF EXISTS idx_emails_contact_id;
DROP INDEX IF EXISTS idx_phones_phone;
DROP INDEX IF EXISTS idx_phones_is_primary;
DROP INDEX IF EXISTS idx_phones_location_type_id;
DROP INDEX IF EXISTS idx_phones_contact_id;
DROP INDEX IF EXISTS idx_addresses_postal_code;
DROP INDEX IF EXISTS idx_addresses_city;
DROP INDEX IF EXISTS idx_addresses_is_primary;
DROP INDEX IF EXISTS idx_addresses_location_type_id;
DROP INDEX IF EXISTS idx_addresses_contact_id;

-- Drop tables
DROP TABLE IF EXISTS ims;
DROP TABLE IF EXISTS websites;
DROP TABLE IF EXISTS emails;
DROP TABLE IF EXISTS phones;
DROP TABLE IF EXISTS addresses;
