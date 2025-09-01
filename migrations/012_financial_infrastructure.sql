-- Financial infrastructure tables
-- These tables handle the complete financial system for CiviCRM

-- Financial accounts (chart of accounts)
CREATE TABLE financial_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    account_type_code TEXT, -- Asset, Liability, Revenue, Expense, etc.
    account_code TEXT, -- Account number/code
    parent_id UUID REFERENCES financial_accounts(id),
    is_header_account BOOLEAN DEFAULT FALSE,
    is_deductible BOOLEAN DEFAULT FALSE,
    is_tax BOOLEAN DEFAULT FALSE,
    is_reserved BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Price sets (for events, memberships, etc.)
CREATE TABLE price_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    extends TEXT, -- Event, Membership, Contribution, etc.
    financial_type_id UUID REFERENCES financial_types(id),
    is_active BOOLEAN DEFAULT TRUE,
    is_quick_config BOOLEAN DEFAULT FALSE,
    min_amount DECIMAL(10,2),
    max_amount DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Price fields (individual price options within a price set)
CREATE TABLE price_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    price_set_id UUID NOT NULL REFERENCES price_sets(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    label TEXT NOT NULL,
    html_type TEXT NOT NULL, -- Text, Select, Radio, CheckBox
    price DECIMAL(10,2),
    is_required BOOLEAN DEFAULT FALSE,
    is_display_amounts BOOLEAN DEFAULT TRUE,
    weight INTEGER DEFAULT 0,
    help_pre TEXT,
    help_post TEXT,
    options_per_line INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    is_enter_qty BOOLEAN DEFAULT FALSE,
    default_value TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Price field values (specific price options)
CREATE TABLE price_field_values (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    price_field_id UUID NOT NULL REFERENCES price_fields(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    label TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    financial_type_id UUID REFERENCES financial_types(id),
    membership_type_id UUID, -- Will reference membership_types when we add them
    membership_num_terms INTEGER,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Line items (breakdown of contributions)
CREATE TABLE line_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_table TEXT NOT NULL, -- civicrm_contribution, civicrm_participant, etc.
    entity_id UUID NOT NULL,
    price_field_id UUID REFERENCES price_fields(id),
    price_field_value_id UUID REFERENCES price_field_values(id),
    label TEXT NOT NULL,
    qty INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    line_total DECIMAL(10,2) NOT NULL,
    financial_type_id UUID REFERENCES financial_types(id),
    non_deductible_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_financial_accounts_parent_id ON financial_accounts(parent_id);
CREATE INDEX idx_financial_accounts_account_type_code ON financial_accounts(account_type_code);
CREATE INDEX idx_financial_accounts_account_code ON financial_accounts(account_code);
CREATE INDEX idx_financial_accounts_is_active ON financial_accounts(is_active);

CREATE INDEX idx_price_sets_extends ON price_sets(extends);
CREATE INDEX idx_price_sets_financial_type_id ON price_sets(financial_type_id);
CREATE INDEX idx_price_sets_is_active ON price_sets(is_active);

CREATE INDEX idx_price_fields_price_set_id ON price_fields(price_set_id);
CREATE INDEX idx_price_fields_html_type ON price_fields(html_type);
CREATE INDEX idx_price_fields_is_active ON price_fields(is_active);
CREATE INDEX idx_price_fields_weight ON price_fields(weight);

CREATE INDEX idx_price_field_values_price_field_id ON price_field_values(price_field_id);
CREATE INDEX idx_price_field_values_financial_type_id ON price_field_values(financial_type_id);
CREATE INDEX idx_price_field_values_is_active ON price_field_values(is_active);
CREATE INDEX idx_price_field_values_weight ON price_field_values(weight);

CREATE INDEX idx_line_items_entity_table ON line_items(entity_table);
CREATE INDEX idx_line_items_entity_id ON line_items(entity_id);
CREATE INDEX idx_line_items_price_field_id ON line_items(price_field_id);
CREATE INDEX idx_line_items_financial_type_id ON line_items(financial_type_id);

-- Add triggers for updated_at
CREATE TRIGGER update_financial_accounts_updated_at BEFORE UPDATE ON financial_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_price_sets_updated_at BEFORE UPDATE ON price_sets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_price_fields_updated_at BEFORE UPDATE ON price_fields
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_price_field_values_updated_at BEFORE UPDATE ON price_field_values
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_line_items_updated_at BEFORE UPDATE ON line_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_line_items_updated_at ON line_items;
DROP TRIGGER IF EXISTS update_price_field_values_updated_at ON price_field_values;
DROP TRIGGER IF EXISTS update_price_fields_updated_at ON price_fields;
DROP TRIGGER IF EXISTS update_price_sets_updated_at ON price_sets;
DROP TRIGGER IF EXISTS update_financial_accounts_updated_at ON financial_accounts;

-- Drop indexes
DROP INDEX IF EXISTS idx_line_items_financial_type_id;
DROP INDEX IF EXISTS idx_line_items_price_field_id;
DROP INDEX IF EXISTS idx_line_items_entity_id;
DROP INDEX IF EXISTS idx_line_items_entity_table;
DROP INDEX IF EXISTS idx_price_field_values_weight;
DROP INDEX IF EXISTS idx_price_field_values_is_active;
DROP INDEX IF EXISTS idx_price_field_values_financial_type_id;
DROP INDEX IF EXISTS idx_price_field_values_price_field_id;
DROP INDEX IF EXISTS idx_price_fields_weight;
DROP INDEX IF EXISTS idx_price_fields_is_active;
DROP INDEX IF EXISTS idx_price_fields_html_type;
DROP INDEX IF EXISTS idx_price_fields_price_set_id;
DROP INDEX IF EXISTS idx_price_sets_is_active;
DROP INDEX IF EXISTS idx_price_sets_financial_type_id;
DROP INDEX IF EXISTS idx_price_sets_extends;
DROP INDEX IF EXISTS idx_financial_accounts_is_active;
DROP INDEX IF EXISTS idx_financial_accounts_account_code;
DROP INDEX IF EXISTS idx_financial_accounts_account_type_code;
DROP INDEX IF EXISTS idx_financial_accounts_parent_id;

-- Drop tables
DROP TABLE IF EXISTS line_items;
DROP TABLE IF EXISTS price_field_values;
DROP TABLE IF EXISTS price_fields;
DROP TABLE IF EXISTS price_sets;
DROP TABLE IF EXISTS financial_accounts;
