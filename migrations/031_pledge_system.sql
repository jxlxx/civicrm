-- Migration: 031_pledge_system.sql
-- Description: Add pledge system for managing pledge campaigns and recurring donations
-- Date: 2024-12-19

-- Pledge Blocks - Campaign blocks for pledge drives
CREATE TABLE IF NOT EXISTS pledge_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    campaign_id UUID REFERENCES campaigns(id),
    is_active BOOLEAN DEFAULT TRUE,
    start_date DATE,
    end_date DATE,
    goal_amount DECIMAL(12,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pledges - Individual pledge records
CREATE TABLE IF NOT EXISTS pledges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    campaign_id UUID REFERENCES campaigns(id),
    pledge_block_id UUID REFERENCES pledge_blocks(id),
    amount DECIMAL(12,2) NOT NULL,
    installments INTEGER DEFAULT 1,
    frequency VARCHAR(50) DEFAULT 'Monthly', -- 'Weekly', 'Bi-weekly', 'Monthly', 'Quarterly', 'Yearly'
    frequency_interval INTEGER DEFAULT 1, -- Every X weeks/months/etc.
    start_date DATE NOT NULL,
    end_date DATE,
    next_payment_date DATE,
    status VARCHAR(50) DEFAULT 'Pending', -- 'Pending', 'In Progress', 'Overdue', 'Completed', 'Cancelled'
    currency VARCHAR(3) DEFAULT 'USD',
    financial_type_id UUID REFERENCES financial_types(id),
    payment_instrument_id UUID REFERENCES payment_instruments(id),
    is_test BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pledge Payments - Individual payment records for pledges
CREATE TABLE IF NOT EXISTS pledge_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pledge_id UUID NOT NULL REFERENCES pledges(id) ON DELETE CASCADE,
    contribution_id UUID REFERENCES contributions(id),
    scheduled_amount DECIMAL(12,2) NOT NULL,
    actual_amount DECIMAL(12,2),
    scheduled_date DATE NOT NULL,
    actual_date DATE,
    status VARCHAR(50) DEFAULT 'Scheduled', -- 'Scheduled', 'Paid', 'Overdue', 'Cancelled', 'Failed'
    reminder_count INTEGER DEFAULT 0,
    reminder_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pledge Logs - Audit trail for pledge changes
CREATE TABLE IF NOT EXISTS pledge_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pledge_id UUID NOT NULL REFERENCES pledges(id) ON DELETE CASCADE,
    action VARCHAR(100) NOT NULL, -- 'Created', 'Modified', 'Payment Received', 'Status Changed', 'Cancelled'
    description TEXT,
    amount_before DECIMAL(12,2),
    amount_after DECIMAL(12,2),
    status_before VARCHAR(50),
    status_after VARCHAR(50),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pledge Reminders - Automated reminder system
CREATE TABLE IF NOT EXISTS pledge_reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pledge_id UUID NOT NULL REFERENCES pledges(id) ON DELETE CASCADE,
    pledge_payment_id UUID REFERENCES pledge_payments(id),
    reminder_type VARCHAR(50) NOT NULL, -- 'Payment Due', 'Payment Overdue', 'Pledge Expiring'
    scheduled_date DATE NOT NULL,
    sent_date DATE,
    status VARCHAR(50) DEFAULT 'Scheduled', -- 'Scheduled', 'Sent', 'Cancelled'
    message_template_id UUID REFERENCES message_templates(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pledge Groups - Group pledges for team fundraising
CREATE TABLE IF NOT EXISTS pledge_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    goal_amount DECIMAL(12,2),
    current_amount DECIMAL(12,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pledge Group Members - Members of pledge groups
CREATE TABLE IF NOT EXISTS pledge_group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pledge_group_id UUID NOT NULL REFERENCES pledge_groups(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    pledge_id UUID REFERENCES pledges(id),
    role VARCHAR(50) DEFAULT 'Member', -- 'Leader', 'Member', 'Supporter'
    is_active BOOLEAN DEFAULT TRUE,
    joined_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_pledge_blocks_campaign ON pledge_blocks(campaign_id, is_active);
CREATE INDEX IF NOT EXISTS idx_pledge_blocks_dates ON pledge_blocks(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_pledges_contact ON pledges(contact_id, status);
CREATE INDEX IF NOT EXISTS idx_pledges_campaign ON pledges(campaign_id, status);
CREATE INDEX IF NOT EXISTS idx_pledges_block ON pledges(pledge_block_id, status);
CREATE INDEX IF NOT EXISTS idx_pledges_dates ON pledges(start_date, end_date, next_payment_date);
CREATE INDEX IF NOT EXISTS idx_pledges_status ON pledges(status, next_payment_date);
CREATE INDEX IF NOT EXISTS idx_pledge_payments_pledge ON pledge_payments(pledge_id, status);
CREATE INDEX IF NOT EXISTS idx_pledge_payments_dates ON pledge_payments(scheduled_date, actual_date);
CREATE INDEX IF NOT EXISTS idx_pledge_payments_status ON pledge_payments(status, scheduled_date);
CREATE INDEX IF NOT EXISTS idx_pledge_logs_pledge ON pledge_logs(pledge_id);
CREATE INDEX IF NOT EXISTS idx_pledge_logs_created_by ON pledge_logs(created_by);
CREATE INDEX IF NOT EXISTS idx_pledge_reminders_pledge ON pledge_reminders(pledge_id, status);
CREATE INDEX IF NOT EXISTS idx_pledge_reminders_dates ON pledge_reminders(scheduled_date, sent_date);
CREATE INDEX IF NOT EXISTS idx_pledge_groups_is_active ON pledge_groups(is_active);
CREATE INDEX IF NOT EXISTS idx_pledge_group_members_group ON pledge_group_members(pledge_group_id, is_active);
CREATE INDEX IF NOT EXISTS idx_pledge_group_members_contact ON pledge_group_members(contact_id, is_active);

-- Unique constraints
CREATE UNIQUE INDEX IF NOT EXISTS idx_pledge_group_members_unique ON pledge_group_members(pledge_group_id, contact_id);

-- Add comments for documentation
COMMENT ON TABLE pledge_blocks IS 'Campaign blocks for pledge drives and fundraising campaigns';
COMMENT ON TABLE pledges IS 'Individual pledge records for recurring donations';
COMMENT ON TABLE pledge_payments IS 'Individual payment records for pledge installments';
COMMENT ON TABLE pledge_logs IS 'Audit trail for pledge changes and modifications';
COMMENT ON TABLE pledge_reminders IS 'Automated reminder system for pledge payments';
COMMENT ON TABLE pledge_groups IS 'Group pledges for team fundraising and peer-to-peer campaigns';
COMMENT ON TABLE pledge_group_members IS 'Members of pledge groups with roles and relationships';
