-- Reporting and Analytics system tables
-- These tables handle comprehensive reporting, analytics, and dashboard functionality

-- Report templates (report definitions and configurations)
CREATE TABLE report_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    report_type TEXT NOT NULL, -- contact, contribution, event, membership, case, survey, etc.
    query_template TEXT NOT NULL, -- SQL template or query definition
    parameters JSONB, -- JSON configuration for report parameters
    is_active BOOLEAN DEFAULT TRUE,
    is_system BOOLEAN DEFAULT FALSE, -- System vs custom reports
    created_by UUID REFERENCES contacts(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Report instances (individual report executions)
CREATE TABLE report_instances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_template_id UUID NOT NULL REFERENCES report_templates(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    parameters JSONB, -- Runtime parameters for this instance
    schedule TEXT, -- Cron-like schedule for recurring reports
    last_run TIMESTAMP WITH TIME ZONE,
    next_run TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    created_by UUID REFERENCES contacts(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Report results (stored report data for performance)
CREATE TABLE report_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_instance_id UUID NOT NULL REFERENCES report_instances(id) ON DELETE CASCADE,
    execution_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    result_data JSONB, -- Stored report results
    row_count INTEGER DEFAULT 0,
    execution_time_ms INTEGER, -- Execution time in milliseconds
    status TEXT DEFAULT 'Completed', -- Completed, Failed, Partial
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Dashboards (dashboard configurations)
CREATE TABLE dashboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    layout JSONB, -- Dashboard layout configuration
    is_active BOOLEAN DEFAULT TRUE,
    is_default BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES contacts(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Dashboard widgets (individual dashboard components)
CREATE TABLE dashboard_widgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dashboard_id UUID NOT NULL REFERENCES dashboards(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    widget_type TEXT NOT NULL, -- chart, table, metric, list, etc.
    configuration JSONB, -- Widget-specific configuration
    position_x INTEGER DEFAULT 0,
    position_y INTEGER DEFAULT 0,
    width INTEGER DEFAULT 1,
    height INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Report subscriptions (who gets which reports)
CREATE TABLE report_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_instance_id UUID NOT NULL REFERENCES report_instances(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    delivery_method TEXT NOT NULL, -- email, dashboard, api, etc.
    delivery_config JSONB, -- Email templates, API endpoints, etc.
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Report permissions (access control for reports)
CREATE TABLE report_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_template_id UUID NOT NULL REFERENCES report_templates(id) ON DELETE CASCADE,
    role_id UUID, -- NULL for public access
    permission_type TEXT NOT NULL, -- view, edit, delete, execute
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_report_templates_name ON report_templates(name);
CREATE INDEX idx_report_templates_report_type ON report_templates(report_type);
CREATE INDEX idx_report_templates_is_active ON report_templates(is_active);
CREATE INDEX idx_report_templates_is_system ON report_templates(is_system);

CREATE INDEX idx_report_instances_template_id ON report_instances(report_template_id);
CREATE INDEX idx_report_instances_name ON report_instances(name);
CREATE INDEX idx_report_instances_is_active ON report_instances(is_active);
CREATE INDEX idx_report_instances_next_run ON report_instances(next_run);

CREATE INDEX idx_report_results_instance_id ON report_results(report_instance_id);
CREATE INDEX idx_report_results_execution_date ON report_results(execution_date);
CREATE INDEX idx_report_results_status ON report_results(status);

CREATE INDEX idx_dashboards_name ON dashboards(name);
CREATE INDEX idx_dashboards_is_active ON dashboards(is_active);
CREATE INDEX idx_dashboards_is_default ON dashboards(is_default);

CREATE INDEX idx_dashboard_widgets_dashboard_id ON dashboard_widgets(dashboard_id);
CREATE INDEX idx_dashboard_widgets_widget_type ON dashboard_widgets(widget_type);
CREATE INDEX idx_dashboard_widgets_is_active ON dashboard_widgets(is_active);

CREATE INDEX idx_report_subscriptions_instance_id ON report_subscriptions(report_instance_id);
CREATE INDEX idx_report_subscriptions_contact_id ON report_subscriptions(contact_id);
CREATE INDEX idx_report_subscriptions_is_active ON report_subscriptions(is_active);

CREATE INDEX idx_report_permissions_template_id ON report_permissions(report_template_id);
CREATE INDEX idx_report_permissions_role_id ON report_permissions(role_id);
CREATE INDEX idx_report_permissions_is_active ON report_permissions(is_active);

-- Add triggers for updated_at
CREATE TRIGGER update_report_templates_updated_at BEFORE UPDATE ON report_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_report_instances_updated_at BEFORE UPDATE ON report_instances
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_report_results_updated_at BEFORE UPDATE ON report_results
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dashboards_updated_at BEFORE UPDATE ON dashboards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dashboard_widgets_updated_at BEFORE UPDATE ON dashboard_widgets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_report_subscriptions_updated_at BEFORE UPDATE ON report_subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_report_permissions_updated_at BEFORE UPDATE ON report_permissions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_report_permissions_updated_at ON report_permissions;
DROP TRIGGER IF EXISTS update_report_subscriptions_updated_at ON report_subscriptions;
DROP TRIGGER IF EXISTS update_dashboard_widgets_updated_at ON dashboard_widgets;
DROP TRIGGER IF EXISTS update_dashboards_updated_at ON dashboards;
DROP TRIGGER IF EXISTS update_report_results_updated_at ON report_results;
DROP TRIGGER IF EXISTS update_report_instances_updated_at ON report_instances;
DROP TRIGGER IF EXISTS update_report_templates_updated_at ON report_templates;

-- Drop indexes
DROP INDEX IF EXISTS idx_report_permissions_is_active;
DROP INDEX IF EXISTS idx_report_permissions_role_id;
DROP INDEX IF EXISTS idx_report_permissions_template_id;
DROP INDEX IF EXISTS idx_report_subscriptions_is_active;
DROP INDEX IF EXISTS idx_report_subscriptions_contact_id;
DROP INDEX IF EXISTS idx_report_subscriptions_instance_id;
DROP INDEX IF EXISTS idx_dashboard_widgets_is_active;
DROP INDEX IF EXISTS idx_dashboard_widgets_widget_type;
DROP INDEX IF EXISTS idx_dashboard_widgets_dashboard_id;
DROP INDEX IF EXISTS idx_dashboards_is_default;
DROP INDEX IF EXISTS idx_dashboards_is_active;
DROP INDEX IF EXISTS idx_dashboards_name;
DROP INDEX IF EXISTS idx_report_results_status;
DROP INDEX IF EXISTS idx_report_results_execution_date;
DROP INDEX IF EXISTS idx_report_results_instance_id;
DROP INDEX IF EXISTS idx_report_instances_next_run;
DROP INDEX IF EXISTS idx_report_instances_is_active;
DROP INDEX IF EXISTS idx_report_instances_name;
DROP INDEX IF EXISTS idx_report_instances_template_id;
DROP INDEX IF EXISTS idx_report_templates_is_system;
DROP INDEX IF EXISTS idx_report_templates_is_active;
DROP INDEX IF EXISTS idx_report_templates_report_type;
DROP INDEX IF EXISTS idx_report_templates_name;

-- Drop tables
DROP TABLE IF EXISTS report_permissions;
DROP TABLE IF EXISTS report_subscriptions;
DROP TABLE IF EXISTS dashboard_widgets;
DROP TABLE IF EXISTS dashboards;
DROP TABLE IF EXISTS report_results;
DROP TABLE IF EXISTS report_instances;
DROP TABLE IF EXISTS report_templates;
