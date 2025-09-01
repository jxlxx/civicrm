-- Core infrastructure tables for CiviCRM
-- These tables provide the foundation for the system

-- Location types (Home, Work, Billing, etc.)
CREATE TABLE location_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    description TEXT,
    vcard_name TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Financial types (Donation, Membership, Event, etc.)
CREATE TABLE financial_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_deductible BOOLEAN DEFAULT FALSE,
    is_reserved BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payment instruments (Credit Card, Check, Cash, etc.)
CREATE TABLE payment_instruments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Event types (Conference, Workshop, Fundraiser, etc.)
CREATE TABLE event_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Participant status types (Registered, Attended, Cancelled, etc.)
CREATE TABLE participant_status_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    class TEXT, -- Positive, Negative, Pending, Cancelled
    is_active BOOLEAN DEFAULT TRUE,
    is_counted BOOLEAN DEFAULT TRUE,
    weight INTEGER DEFAULT 0,
    visibility_id INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Countries
CREATE TABLE countries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    iso_code TEXT UNIQUE,
    numeric_code TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- States/Provinces
CREATE TABLE state_provinces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    abbreviation TEXT,
    country_id UUID REFERENCES countries(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_location_types_name ON location_types(name);
CREATE INDEX idx_financial_types_name ON financial_types(name);
CREATE INDEX idx_payment_instruments_name ON payment_instruments(name);
CREATE INDEX idx_event_types_name ON event_types(name);
CREATE INDEX idx_participant_status_types_name ON participant_status_types(name);
CREATE INDEX idx_countries_iso_code ON countries(iso_code);
CREATE INDEX idx_state_provinces_country_id ON state_provinces(country_id);
CREATE INDEX idx_state_provinces_abbreviation ON state_provinces(abbreviation);

-- Add triggers for updated_at
CREATE TRIGGER update_location_types_updated_at BEFORE UPDATE ON location_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_financial_types_updated_at BEFORE UPDATE ON financial_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payment_instruments_updated_at BEFORE UPDATE ON payment_instruments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_types_updated_at BEFORE UPDATE ON event_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_participant_status_types_updated_at BEFORE UPDATE ON participant_status_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_countries_updated_at BEFORE UPDATE ON countries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_state_provinces_updated_at BEFORE UPDATE ON state_provinces
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_state_provinces_updated_at ON state_provinces;
DROP TRIGGER IF EXISTS update_countries_updated_at ON countries;
DROP TRIGGER IF EXISTS update_participant_status_types_updated_at ON participant_status_types;
DROP TRIGGER IF EXISTS update_event_types_updated_at ON event_types;
DROP TRIGGER IF EXISTS update_payment_instruments_updated_at ON payment_instruments;
DROP TRIGGER IF EXISTS update_financial_types_updated_at ON financial_types;
DROP TRIGGER IF EXISTS update_location_types_updated_at ON location_types;

-- Drop indexes
DROP INDEX IF EXISTS idx_state_provinces_abbreviation;
DROP INDEX IF EXISTS idx_state_provinces_country_id;
DROP INDEX IF EXISTS idx_countries_iso_code;
DROP INDEX IF EXISTS idx_participant_status_types_name;
DROP INDEX IF EXISTS idx_event_types_name;
DROP INDEX IF EXISTS idx_payment_instruments_name;
DROP INDEX IF EXISTS idx_financial_types_name;
DROP INDEX IF EXISTS idx_location_types_name;

-- Drop tables
DROP TABLE IF EXISTS state_provinces;
DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS participant_status_types;
DROP TABLE IF EXISTS event_types;
DROP TABLE IF EXISTS payment_instruments;
DROP TABLE IF EXISTS financial_types;
DROP TABLE IF EXISTS location_types;
