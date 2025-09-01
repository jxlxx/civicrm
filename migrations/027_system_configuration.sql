-- System Configuration Migration
-- Adds domain management, system settings, and navigation system
-- This completes the core infrastructure for multi-domain support and system configuration

-- Domain management for multi-domain support
CREATE TABLE IF NOT EXISTS domains (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- System settings and configuration
CREATE TABLE IF NOT EXISTS settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    value TEXT,
    description TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(domain_id, name)
);

-- Navigation menu system
CREATE TABLE IF NOT EXISTS navigation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES navigation(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    label VARCHAR(255) NOT NULL,
    url VARCHAR(500),
    icon VARCHAR(100),
    permission VARCHAR(255),
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_visible BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Menu structure and hierarchy
CREATE TABLE IF NOT EXISTS menu_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    navigation_id UUID NOT NULL REFERENCES navigation(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    label VARCHAR(255) NOT NULL,
    url VARCHAR(500),
    icon VARCHAR(100),
    permission VARCHAR(255),
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_visible BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User framework groups for custom forms
CREATE TABLE IF NOT EXISTS uf_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User framework fields for custom forms
CREATE TABLE IF NOT EXISTS uf_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uf_group_id UUID NOT NULL REFERENCES uf_groups(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    label VARCHAR(255) NOT NULL,
    field_type VARCHAR(50) NOT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    weight INTEGER DEFAULT 0,
    help_pre TEXT,
    help_post TEXT,
    options TEXT, -- JSON for select/radio/checkbox options
    validation_rules TEXT, -- JSON for validation rules
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User framework joins for linking custom forms to entities
CREATE TABLE IF NOT EXISTS uf_joins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uf_group_id UUID NOT NULL REFERENCES uf_groups(id) ON DELETE CASCADE,
    entity_table VARCHAR(255) NOT NULL,
    entity_id UUID NOT NULL,
    weight INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Background job management
CREATE TABLE IF NOT EXISTS jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    job_type VARCHAR(100) NOT NULL,
    parameters TEXT, -- JSON parameters
    schedule VARCHAR(100), -- Cron-like schedule
    is_active BOOLEAN DEFAULT TRUE,
    last_run TIMESTAMP WITH TIME ZONE,
    next_run TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Job execution logs
CREATE TABLE IF NOT EXISTS job_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL, -- 'running', 'completed', 'failed'
    message TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    execution_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Queue management for background processing
CREATE TABLE IF NOT EXISTS queues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain_id UUID NOT NULL REFERENCES domains(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    max_retries INTEGER DEFAULT 3,
    retry_delay_seconds INTEGER DEFAULT 300,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Queue items for background processing
CREATE TABLE IF NOT EXISTS queue_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    queue_id UUID NOT NULL REFERENCES queues(id) ON DELETE CASCADE,
    data TEXT NOT NULL, -- JSON data for the job
    priority INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    attempts INTEGER DEFAULT 0,
    scheduled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_domains_name ON domains(name);
CREATE INDEX IF NOT EXISTS idx_domains_is_active ON domains(is_active);

CREATE INDEX IF NOT EXISTS idx_settings_domain_name ON settings(domain_id, name);
CREATE INDEX IF NOT EXISTS idx_settings_is_system ON settings(is_system);

CREATE INDEX IF NOT EXISTS idx_navigation_domain_parent ON navigation(domain_id, parent_id);
CREATE INDEX IF NOT EXISTS idx_navigation_weight ON navigation(weight);
CREATE INDEX IF NOT EXISTS idx_navigation_is_active ON navigation(is_active);

CREATE INDEX IF NOT EXISTS idx_menu_items_navigation_weight ON menu_items(navigation_id, weight);
CREATE INDEX IF NOT EXISTS idx_menu_items_is_active ON menu_items(is_active);

CREATE INDEX IF NOT EXISTS idx_uf_groups_domain ON uf_groups(domain_id);
CREATE INDEX IF NOT EXISTS idx_uf_groups_is_active ON uf_groups(is_active);

CREATE INDEX IF NOT EXISTS idx_uf_fields_uf_group_weight ON uf_fields(uf_group_id, weight);
CREATE INDEX IF NOT EXISTS idx_uf_fields_is_active ON uf_fields(is_active);

CREATE INDEX IF NOT EXISTS idx_uf_joins_uf_group_entity ON uf_joins(uf_group_id, entity_table);

CREATE INDEX IF NOT EXISTS idx_jobs_domain_schedule ON jobs(domain_id, schedule);
CREATE INDEX IF NOT EXISTS idx_jobs_is_active ON jobs(is_active);
CREATE INDEX IF NOT EXISTS idx_jobs_next_run ON jobs(next_run);

CREATE INDEX IF NOT EXISTS idx_job_logs_job_status ON job_logs(job_id, status);
CREATE INDEX IF NOT EXISTS idx_job_logs_started_at ON job_logs(started_at);

CREATE INDEX IF NOT EXISTS idx_queues_domain ON queues(domain_id);
CREATE INDEX IF NOT EXISTS idx_queues_is_active ON queues(is_active);

CREATE INDEX IF NOT EXISTS idx_queue_items_queue_status_priority ON queue_items(queue_id, status, priority);
CREATE INDEX IF NOT EXISTS idx_queue_items_scheduled_at ON queue_items(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_queue_items_status_attempts ON queue_items(status, attempts);

-- Add triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_domains_updated_at BEFORE UPDATE ON domains
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_settings_updated_at BEFORE UPDATE ON settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_navigation_updated_at BEFORE UPDATE ON navigation
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_menu_items_updated_at BEFORE UPDATE ON menu_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_uf_groups_updated_at BEFORE UPDATE ON uf_groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_uf_fields_updated_at BEFORE UPDATE ON uf_fields
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_uf_joins_updated_at BEFORE UPDATE ON uf_joins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_queues_updated_at BEFORE UPDATE ON queues
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_queue_items_updated_at BEFORE UPDATE ON queue_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
