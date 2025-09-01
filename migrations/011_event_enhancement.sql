-- Event enhancement tables
-- These tables provide advanced event management capabilities

-- Participants (separate from event_registrations for more flexibility)
CREATE TABLE participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    status_id UUID NOT NULL REFERENCES participant_status_types(id),
    role_id UUID, -- Will reference participant_roles when we add them
    register_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    source TEXT,
    fee_level TEXT,
    is_test BOOLEAN DEFAULT FALSE,
    is_pay_later BOOLEAN DEFAULT FALSE,
    fee_amount DECIMAL(10,2) DEFAULT 0,
    registered_by_id UUID REFERENCES contacts(id),
    discount_id UUID, -- Will reference discounts when we add them
    fee_currency TEXT DEFAULT 'USD',
    campaign_id UUID, -- Will reference campaigns when we add them
    discount_amount DECIMAL(10,2) DEFAULT 0,
    cart_id UUID, -- Will reference shopping_cart when we add them
    must_wait BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Event fees (pricing structure for events)
CREATE TABLE event_fees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    label TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    is_active BOOLEAN DEFAULT TRUE,
    weight INTEGER DEFAULT 0,
    help_pre TEXT,
    help_post TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Discounts (for events, memberships, etc.)
CREATE TABLE discounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    discount_type_id UUID, -- Will reference discount_types when we add them
    amount DECIMAL(10,2),
    percentage DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Discount links (connects discounts to events, memberships, etc.)
CREATE TABLE discount_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    discount_id UUID NOT NULL REFERENCES discounts(id) ON DELETE CASCADE,
    entity_table TEXT NOT NULL, -- civicrm_event, civicrm_membership, etc.
    entity_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Event templates (for recurring events)
CREATE TABLE event_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    event_type_id UUID REFERENCES event_types(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_participants_event_id ON participants(event_id);
CREATE INDEX idx_participants_contact_id ON participants(contact_id);
CREATE INDEX idx_participants_status_id ON participants(status_id);
CREATE INDEX idx_participants_register_date ON participants(register_date);
CREATE INDEX idx_participants_is_test ON participants(is_test);
CREATE INDEX idx_participants_campaign_id ON participants(campaign_id);

CREATE INDEX idx_event_fees_event_id ON event_fees(event_id);
CREATE INDEX idx_event_fees_is_active ON event_fees(is_active);
CREATE INDEX idx_event_fees_weight ON event_fees(weight);

CREATE INDEX idx_discounts_is_active ON discounts(is_active);
CREATE INDEX idx_discounts_discount_type_id ON discounts(discount_type_id);

CREATE INDEX idx_discount_links_discount_id ON discount_links(discount_id);
CREATE INDEX idx_discount_links_entity_table ON discount_links(entity_table);
CREATE INDEX idx_discount_links_entity_id ON discount_links(entity_id);

CREATE INDEX idx_event_templates_event_type_id ON event_templates(event_type_id);
CREATE INDEX idx_event_templates_is_active ON event_templates(is_active);

-- Add triggers for updated_at
CREATE TRIGGER update_participants_updated_at BEFORE UPDATE ON participants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_fees_updated_at BEFORE UPDATE ON event_fees
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_discounts_updated_at BEFORE UPDATE ON discounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_discount_links_updated_at BEFORE UPDATE ON discount_links
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_templates_updated_at BEFORE UPDATE ON event_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_event_templates_updated_at ON event_templates;
DROP TRIGGER IF EXISTS update_discount_links_updated_at ON discount_links;
DROP TRIGGER IF EXISTS update_discounts_updated_at ON discounts;
DROP TRIGGER IF EXISTS update_event_fees_updated_at ON event_fees;
DROP TRIGGER IF EXISTS update_participants_updated_at ON participants;

-- Drop indexes
DROP INDEX IF EXISTS idx_event_templates_is_active;
DROP INDEX IF EXISTS idx_event_templates_event_type_id;
DROP INDEX IF EXISTS idx_discount_links_entity_id;
DROP INDEX IF EXISTS idx_discount_links_entity_table;
DROP INDEX IF EXISTS idx_discount_links_discount_id;
DROP INDEX IF EXISTS idx_discounts_discount_type_id;
DROP INDEX IF EXISTS idx_discounts_is_active;
DROP INDEX IF EXISTS idx_event_fees_weight;
DROP INDEX IF EXISTS idx_event_fees_is_active;
DROP INDEX IF EXISTS idx_event_fees_event_id;
DROP INDEX IF EXISTS idx_participants_campaign_id;
DROP INDEX IF EXISTS idx_participants_is_test;
DROP INDEX IF EXISTS idx_participants_register_date;
DROP INDEX IF EXISTS idx_participants_status_id;
DROP INDEX IF EXISTS idx_participants_contact_id;
DROP INDEX IF EXISTS idx_participants_event_id;

-- Drop tables
DROP TABLE IF EXISTS event_templates;
DROP TABLE IF EXISTS discount_links;
DROP TABLE IF EXISTS discounts;
DROP TABLE IF EXISTS event_fees;
DROP TABLE IF EXISTS participants;
