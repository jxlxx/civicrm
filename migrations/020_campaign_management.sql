-- Campaign management system tables
-- These tables handle the complete campaign management system for CiviCRM

-- Campaigns (fundraising, advocacy, outreach campaigns)
CREATE TABLE campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    campaign_type_id UUID, -- Will reference campaign_types when we add them
    status_id UUID, -- Will reference campaign_status when we add them
    parent_id UUID REFERENCES campaigns(id), -- For nested campaigns
    is_active BOOLEAN DEFAULT TRUE,
    start_date DATE,
    end_date DATE,
    goal_revenue DECIMAL(15,2),
    goal_contacts INTEGER,
    actual_revenue DECIMAL(15,2),
    actual_contacts INTEGER,
    external_identifier TEXT,
    created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    modified_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campaign types (Fundraising, Advocacy, Outreach, etc.)
CREATE TABLE campaign_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    weight INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campaign status (Planned, Active, Completed, Cancelled, etc.)
CREATE TABLE campaign_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    grouping TEXT, -- Planned, Active, Completed, etc.
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    color TEXT, -- Hex color for UI
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campaign contacts (participants in campaigns)
CREATE TABLE campaign_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    role TEXT NOT NULL, -- Donor, Volunteer, Advocate, etc.
    status TEXT DEFAULT 'Added', -- Added, Removed, Opt-out, etc.
    join_date DATE DEFAULT CURRENT_DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campaign groups (target audience groups)
CREATE TABLE campaign_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campaign activities (activities specific to campaigns)
CREATE TABLE campaign_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campaign contributions (contributions linked to campaigns)
CREATE TABLE campaign_contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    contribution_id UUID NOT NULL REFERENCES contributions(id) ON DELETE CASCADE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Campaign events (events linked to campaigns)
CREATE TABLE campaign_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_campaigns_name ON campaigns(name);
CREATE INDEX idx_campaigns_campaign_type_id ON campaigns(campaign_type_id);
CREATE INDEX idx_campaigns_status_id ON campaigns(status_id);
CREATE INDEX idx_campaigns_parent_id ON campaigns(parent_id);
CREATE INDEX idx_campaigns_is_active ON campaigns(is_active);
CREATE INDEX idx_campaigns_start_date ON campaigns(start_date);
CREATE INDEX idx_campaigns_end_date ON campaigns(end_date);
CREATE INDEX idx_campaigns_external_identifier ON campaigns(external_identifier);

CREATE INDEX idx_campaign_types_name ON campaign_types(name);
CREATE INDEX idx_campaign_types_is_active ON campaign_types(is_active);
CREATE INDEX idx_campaign_types_weight ON campaign_types(weight);

CREATE INDEX idx_campaign_status_name ON campaign_status(name);
CREATE INDEX idx_campaign_status_grouping ON campaign_status(grouping);
CREATE INDEX idx_campaign_status_weight ON campaign_status(weight);

CREATE INDEX idx_campaign_contacts_campaign_id ON campaign_contacts(campaign_id);
CREATE INDEX idx_campaign_contacts_contact_id ON campaign_contacts(contact_id);
CREATE INDEX idx_campaign_contacts_role ON campaign_contacts(role);
CREATE INDEX idx_campaign_contacts_status ON campaign_contacts(status);
CREATE INDEX idx_campaign_contacts_is_active ON campaign_contacts(is_active);

CREATE INDEX idx_campaign_groups_campaign_id ON campaign_groups(campaign_id);
CREATE INDEX idx_campaign_groups_group_id ON campaign_groups(group_id);
CREATE INDEX idx_campaign_groups_is_active ON campaign_groups(is_active);

CREATE INDEX idx_campaign_activities_campaign_id ON campaign_activities(campaign_id);
CREATE INDEX idx_campaign_activities_activity_id ON campaign_activities(activity_id);
CREATE INDEX idx_campaign_activities_is_deleted ON campaign_activities(is_deleted);

CREATE INDEX idx_campaign_contributions_campaign_id ON campaign_contributions(campaign_id);
CREATE INDEX idx_campaign_contributions_contribution_id ON campaign_contributions(contribution_id);
CREATE INDEX idx_campaign_contributions_is_deleted ON campaign_contributions(is_deleted);

CREATE INDEX idx_campaign_events_campaign_id ON campaign_events(campaign_id);
CREATE INDEX idx_campaign_events_event_id ON campaign_events(event_id);
CREATE INDEX idx_campaign_events_is_deleted ON campaign_events(is_deleted);

-- Add triggers for updated_at
CREATE TRIGGER update_campaigns_updated_at BEFORE UPDATE ON campaigns
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaign_types_updated_at BEFORE UPDATE ON campaign_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaign_status_updated_at BEFORE UPDATE ON campaign_status
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaign_contacts_updated_at BEFORE UPDATE ON campaign_contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaign_groups_updated_at BEFORE UPDATE ON campaign_groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaign_activities_updated_at BEFORE UPDATE ON campaign_activities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaign_contributions_updated_at BEFORE UPDATE ON campaign_contributions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaign_events_updated_at BEFORE UPDATE ON campaign_events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_campaign_events_updated_at ON campaign_events;
DROP TRIGGER IF EXISTS update_campaign_contributions_updated_at ON campaign_contributions;
DROP TRIGGER IF EXISTS update_campaign_activities_updated_at ON campaign_activities;
DROP TRIGGER IF EXISTS update_campaign_groups_updated_at ON campaign_groups;
DROP TRIGGER IF EXISTS update_campaign_contacts_updated_at ON campaign_contacts;
DROP TRIGGER IF EXISTS update_campaign_status_updated_at ON campaign_status;
DROP TRIGGER IF EXISTS update_campaign_types_updated_at ON campaign_types;
DROP TRIGGER IF EXISTS update_campaigns_updated_at ON campaigns;

-- Drop indexes
DROP INDEX IF EXISTS idx_campaign_events_is_deleted;
DROP INDEX IF EXISTS idx_campaign_events_event_id;
DROP INDEX IF EXISTS idx_campaign_events_campaign_id;
DROP INDEX IF EXISTS idx_campaign_contributions_is_deleted;
DROP INDEX IF EXISTS idx_campaign_contributions_contribution_id;
DROP INDEX IF EXISTS idx_campaign_contributions_campaign_id;
DROP INDEX IF EXISTS idx_campaign_activities_is_deleted;
DROP INDEX IF EXISTS idx_campaign_activities_activity_id;
DROP INDEX IF EXISTS idx_campaign_activities_campaign_id;
DROP INDEX IF EXISTS idx_campaign_groups_is_active;
DROP INDEX IF EXISTS idx_campaign_groups_group_id;
DROP INDEX IF EXISTS idx_campaign_groups_campaign_id;
DROP INDEX IF EXISTS idx_campaign_contacts_is_active;
DROP INDEX IF EXISTS idx_campaign_contacts_status;
DROP INDEX IF EXISTS idx_campaign_contacts_role;
DROP INDEX IF EXISTS idx_campaign_contacts_contact_id;
DROP INDEX IF EXISTS idx_campaign_contacts_campaign_id;
DROP INDEX IF EXISTS idx_campaign_status_weight;
DROP INDEX IF EXISTS idx_campaign_status_grouping;
DROP INDEX IF EXISTS idx_campaign_status_name;
DROP INDEX IF EXISTS idx_campaign_types_weight;
DROP INDEX IF EXISTS idx_campaign_types_is_active;
DROP INDEX IF EXISTS idx_campaign_types_name;
DROP INDEX IF EXISTS idx_campaigns_external_identifier;
DROP INDEX IF EXISTS idx_campaigns_end_date;
DROP INDEX IF EXISTS idx_campaigns_start_date;
DROP INDEX IF EXISTS idx_campaigns_is_active;
DROP INDEX IF EXISTS idx_campaigns_parent_id;
DROP INDEX IF EXISTS idx_campaigns_status_id;
DROP INDEX IF EXISTS idx_campaigns_campaign_type_id;
DROP INDEX IF EXISTS idx_campaigns_name;

-- Drop tables
DROP TABLE IF EXISTS campaign_events;
DROP TABLE IF EXISTS campaign_contributions;
DROP TABLE IF EXISTS campaign_activities;
DROP TABLE IF EXISTS campaign_groups;
DROP TABLE IF EXISTS campaign_contacts;
DROP TABLE IF EXISTS campaign_status;
DROP TABLE IF EXISTS campaign_types;
DROP TABLE IF EXISTS campaigns;
