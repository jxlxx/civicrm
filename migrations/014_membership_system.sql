-- Membership system tables
-- These tables handle the complete membership management system for CiviCRM

-- Membership types (Individual, Family, Corporate, etc.)
CREATE TABLE membership_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    member_of_contact_id UUID REFERENCES contacts(id), -- Organization offering membership
    financial_type_id UUID REFERENCES financial_types(id),
    minimum_fee DECIMAL(10,2) DEFAULT 0,
    duration_unit TEXT NOT NULL, -- year, month, day
    duration_interval INTEGER NOT NULL DEFAULT 1,
    period_type TEXT NOT NULL, -- rolling, fixed
    fixed_period_start_day INTEGER, -- Day of year for fixed periods
    fixed_period_rollover_day INTEGER, -- Day of year for rollovers
    relationship_type_id UUID REFERENCES relationship_types(id),
    relationship_direction TEXT, -- a_b or b_a
    visibility TEXT DEFAULT 'Public', -- Public, Admin
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Membership status (New, Current, Grace, Expired, etc.)
CREATE TABLE membership_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    start_event TEXT, -- start, join, etc.
    end_event TEXT, -- end, leave, etc.
    is_current_member BOOLEAN DEFAULT FALSE,
    is_admin BOOLEAN DEFAULT FALSE,
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Memberships (individual membership records)
CREATE TABLE memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    membership_type_id UUID NOT NULL REFERENCES membership_types(id),
    status_id UUID NOT NULL REFERENCES membership_status(id),
    join_date DATE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    source TEXT,
    is_override BOOLEAN DEFAULT FALSE,
    status_override_end_date DATE,
    is_pay_later BOOLEAN DEFAULT FALSE,
    contribution_id UUID REFERENCES contributions(id),
    campaign_id UUID, -- Will reference campaigns when we add them
    is_test BOOLEAN DEFAULT FALSE,
    num_terms INTEGER DEFAULT 1,
    max_related_contacts INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Membership payments (tracks payments for memberships)
CREATE TABLE membership_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    membership_id UUID NOT NULL REFERENCES memberships(id) ON DELETE CASCADE,
    contribution_id UUID NOT NULL REFERENCES contributions(id),
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_currency TEXT DEFAULT 'USD',
    payment_date DATE NOT NULL,
    payment_status TEXT DEFAULT 'Completed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Membership logs (audit trail for membership changes)
CREATE TABLE membership_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    membership_id UUID NOT NULL REFERENCES memberships(id) ON DELETE CASCADE,
    modified_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    modified_by_contact_id UUID REFERENCES contacts(id),
    status_id UUID REFERENCES membership_status(id),
    start_date DATE,
    end_date DATE,
    membership_type_id UUID REFERENCES membership_types(id),
    is_override BOOLEAN DEFAULT FALSE,
    status_override_end_date DATE,
    log_type TEXT DEFAULT 'Membership Status Change',
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_membership_types_name ON membership_types(name);
CREATE INDEX idx_membership_types_is_active ON membership_types(is_active);
CREATE INDEX idx_membership_types_weight ON membership_types(weight);

CREATE INDEX idx_membership_status_name ON membership_status(name);
CREATE INDEX idx_membership_status_is_current_member ON membership_status(is_current_member);
CREATE INDEX idx_membership_status_weight ON membership_status(weight);

CREATE INDEX idx_memberships_contact_id ON memberships(contact_id);
CREATE INDEX idx_memberships_membership_type_id ON memberships(membership_type_id);
CREATE INDEX idx_memberships_status_id ON memberships(status_id);
CREATE INDEX idx_memberships_join_date ON memberships(join_date);
CREATE INDEX idx_memberships_start_date ON memberships(start_date);
CREATE INDEX idx_memberships_end_date ON memberships(end_date);
CREATE INDEX idx_memberships_is_test ON memberships(is_test);
CREATE INDEX idx_memberships_campaign_id ON memberships(campaign_id);

CREATE INDEX idx_membership_payments_membership_id ON membership_payments(membership_id);
CREATE INDEX idx_membership_payments_contribution_id ON membership_payments(contribution_id);
CREATE INDEX idx_membership_payments_payment_date ON membership_payments(payment_date);

CREATE INDEX idx_membership_logs_membership_id ON membership_logs(membership_id);
CREATE INDEX idx_membership_logs_modified_date ON membership_logs(modified_date);
CREATE INDEX idx_membership_logs_status_id ON membership_logs(status_id);

-- Add triggers for updated_at
CREATE TRIGGER update_membership_types_updated_at BEFORE UPDATE ON membership_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_membership_status_updated_at BEFORE UPDATE ON membership_status
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_memberships_updated_at BEFORE UPDATE ON memberships
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_membership_payments_updated_at BEFORE UPDATE ON membership_payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_membership_logs_updated_at BEFORE UPDATE ON membership_logs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_membership_logs_updated_at ON membership_logs;
DROP TRIGGER IF EXISTS update_membership_payments_updated_at ON membership_payments;
DROP TRIGGER IF EXISTS update_memberships_updated_at ON memberships;
DROP TRIGGER IF EXISTS update_membership_status_updated_at ON membership_status;
DROP TRIGGER IF EXISTS update_membership_types_updated_at ON membership_types;

-- Drop indexes
DROP INDEX IF EXISTS idx_membership_logs_status_id;
DROP INDEX IF EXISTS idx_membership_logs_modified_date;
DROP INDEX IF EXISTS idx_membership_logs_membership_id;
DROP INDEX IF EXISTS idx_membership_payments_payment_date;
DROP INDEX IF EXISTS idx_membership_payments_contribution_id;
DROP INDEX IF EXISTS idx_membership_payments_membership_id;
DROP INDEX IF EXISTS idx_memberships_campaign_id;
DROP INDEX IF EXISTS idx_memberships_is_test;
DROP INDEX IF EXISTS idx_memberships_end_date;
DROP INDEX IF EXISTS idx_memberships_start_date;
DROP INDEX IF EXISTS idx_memberships_join_date;
DROP INDEX IF EXISTS idx_memberships_status_id;
DROP INDEX IF EXISTS idx_memberships_membership_type_id;
DROP INDEX IF EXISTS idx_memberships_contact_id;
DROP INDEX IF EXISTS idx_membership_status_weight;
DROP INDEX IF EXISTS idx_membership_status_is_current_member;
DROP INDEX IF EXISTS idx_membership_status_name;
DROP INDEX IF EXISTS idx_membership_types_weight;
DROP INDEX IF EXISTS idx_membership_types_is_active;
DROP INDEX IF EXISTS idx_membership_types_name;

-- Drop tables
DROP TABLE IF EXISTS membership_logs;
DROP TABLE IF EXISTS membership_payments;
DROP TABLE IF EXISTS memberships;
DROP TABLE IF EXISTS membership_status;
DROP TABLE IF EXISTS membership_types;
