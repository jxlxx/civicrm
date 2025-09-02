-- Migration: 029_custom_fields_system.sql
-- Description: Add custom fields system for extensible entity fields
-- Date: 2024-12-19

-- Custom Groups - Define groups of custom fields
CREATE TABLE IF NOT EXISTS custom_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    extends VARCHAR(255) NOT NULL, -- 'Contact', 'Contribution', 'Event', 'Activity', etc.
    table_name VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    is_multiple BOOLEAN DEFAULT FALSE, -- Whether multiple records per entity
    collapse_display BOOLEAN DEFAULT FALSE, -- Collapse in UI
    help_pre TEXT, -- Help text before fields
    help_post TEXT, -- Help text after fields
    weight INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Custom Fields - Individual custom field definitions
CREATE TABLE IF NOT EXISTS custom_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    custom_group_id UUID NOT NULL REFERENCES custom_groups(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    label VARCHAR(255) NOT NULL,
    data_type VARCHAR(50) NOT NULL, -- 'String', 'Int', 'Float', 'Date', 'Boolean', 'Money', 'Link'
    html_type VARCHAR(50) NOT NULL, -- 'Text', 'Select', 'Radio', 'Checkbox', 'TextArea', 'Select Country', etc.
    is_required BOOLEAN DEFAULT FALSE,
    is_searchable BOOLEAN DEFAULT FALSE,
    is_search_range BOOLEAN DEFAULT FALSE, -- For date/numeric range searches
    is_view BOOLEAN DEFAULT FALSE, -- Read-only field
    is_active BOOLEAN DEFAULT TRUE,
    weight INTEGER DEFAULT 0,
    help_pre TEXT, -- Help text before field
    help_post TEXT, -- Help text after field
    default_value TEXT, -- Default value for the field
    text_length INTEGER, -- Max length for text fields
    start_date_years INTEGER, -- Years back for date fields
    end_date_years INTEGER, -- Years forward for date fields
    date_format VARCHAR(20), -- Date format string
    time_format VARCHAR(20), -- Time format string
    option_group_id UUID, -- For select/radio/checkbox fields
    filter VARCHAR(255), -- Filter criteria
    in_selector BOOLEAN DEFAULT FALSE, -- Show in contact selector
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Custom Field Options - For select/radio/checkbox fields
CREATE TABLE IF NOT EXISTS custom_field_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    custom_field_id UUID NOT NULL REFERENCES custom_fields(id) ON DELETE CASCADE,
    label VARCHAR(255) NOT NULL,
    value VARCHAR(255) NOT NULL,
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Custom Values - Store actual custom field values
CREATE TABLE IF NOT EXISTS custom_values (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    custom_field_id UUID NOT NULL REFERENCES custom_fields(id) ON DELETE CASCADE,
    entity_table VARCHAR(255) NOT NULL, -- 'contacts', 'contributions', 'events', etc.
    entity_id UUID NOT NULL, -- ID of the entity
    value_text TEXT, -- For text fields
    value_int INTEGER, -- For integer fields
    value_float DECIMAL(10,2), -- For float/money fields
    value_date DATE, -- For date fields
    value_boolean BOOLEAN, -- For boolean fields
    value_link VARCHAR(500), -- For link fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_custom_groups_extends ON custom_groups(extends);
CREATE INDEX IF NOT EXISTS idx_custom_groups_is_active ON custom_groups(is_active);
CREATE INDEX IF NOT EXISTS idx_custom_fields_group_id ON custom_fields(custom_group_id);
CREATE INDEX IF NOT EXISTS idx_custom_fields_is_active ON custom_fields(is_active);
CREATE INDEX IF NOT EXISTS idx_custom_field_options_field_id ON custom_field_options(custom_field_id);
CREATE INDEX IF NOT EXISTS idx_custom_values_entity ON custom_values(entity_table, entity_id);
CREATE INDEX IF NOT EXISTS idx_custom_values_field_id ON custom_values(custom_field_id);

-- Unique constraints
CREATE UNIQUE INDEX IF NOT EXISTS idx_custom_groups_name ON custom_groups(name);
CREATE UNIQUE INDEX IF NOT EXISTS idx_custom_fields_name_group ON custom_fields(custom_group_id, name);
CREATE UNIQUE INDEX IF NOT EXISTS idx_custom_values_unique ON custom_values(custom_field_id, entity_table, entity_id);

-- Add comments for documentation
COMMENT ON TABLE custom_groups IS 'Groups of custom fields that extend CiviCRM entities';
COMMENT ON TABLE custom_fields IS 'Individual custom field definitions within custom groups';
COMMENT ON TABLE custom_field_options IS 'Options for select/radio/checkbox custom fields';
COMMENT ON TABLE custom_values IS 'Actual values stored for custom fields on entities';
