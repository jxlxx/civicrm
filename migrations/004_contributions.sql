CREATE TABLE contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    contribution_type TEXT,
    status TEXT DEFAULT 'Completed',
    received_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_contributions_contact_id ON contributions(contact_id);
CREATE INDEX idx_contributions_received_date ON contributions(received_date);

CREATE TRIGGER update_contributions_updated_at BEFORE UPDATE ON contributions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

DROP TRIGGER IF EXISTS update_contributions_updated_at ON contributions;
DROP INDEX IF EXISTS idx_contributions_received_date;
DROP INDEX IF EXISTS idx_contributions_contact_id;
DROP TABLE IF EXISTS contributions;
