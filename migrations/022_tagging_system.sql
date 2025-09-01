-- Tagging system tables
-- These tables handle the complete tagging system for CiviCRM

-- Tag sets (categories of tags like "Campaign Tags", "Case Tags", etc.)
CREATE TABLE tag_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    description TEXT,
    entity_table TEXT NOT NULL, -- Which entity this tag set applies to
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    weight INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tags (individual tags within tag sets)
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tag_set_id UUID REFERENCES tag_sets(id),
    name TEXT NOT NULL,
    description TEXT,
    color TEXT, -- Hex color for UI
    icon TEXT, -- Icon identifier
    is_active BOOLEAN DEFAULT TRUE,
    is_reserved BOOLEAN DEFAULT FALSE,
    weight INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Entity tags (links tags to various entities)
CREATE TABLE entity_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_table TEXT NOT NULL, -- Which table the entity is in
    entity_id UUID NOT NULL, -- ID of the tagged entity
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_tag_sets_name ON tag_sets(name);
CREATE INDEX idx_tag_sets_entity_table ON tag_sets(entity_table);
CREATE INDEX idx_tag_sets_is_active ON tag_sets(is_active);
CREATE INDEX idx_tag_sets_weight ON tag_sets(weight);

CREATE INDEX idx_tags_tag_set_id ON tags(tag_set_id);
CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_tags_is_active ON tags(is_active);
CREATE INDEX idx_tags_weight ON tags(weight);

CREATE INDEX idx_entity_tags_entity_table ON entity_tags(entity_table);
CREATE INDEX idx_entity_tags_entity_id ON entity_tags(entity_id);
CREATE INDEX idx_entity_tags_tag_id ON entity_tags(tag_id);
CREATE UNIQUE INDEX idx_entity_tags_unique ON entity_tags(entity_table, entity_id, tag_id);

-- Add triggers for updated_at
CREATE TRIGGER update_tag_sets_updated_at BEFORE UPDATE ON tag_sets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tags_updated_at BEFORE UPDATE ON tags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_entity_tags_updated_at BEFORE UPDATE ON entity_tags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_entity_tags_updated_at ON entity_tags;
DROP TRIGGER IF EXISTS update_tags_updated_at ON tags;
DROP TRIGGER IF EXISTS update_tag_sets_updated_at ON tag_sets;

-- Drop indexes
DROP INDEX IF EXISTS idx_entity_tags_unique;
DROP INDEX IF EXISTS idx_entity_tags_tag_id;
DROP INDEX IF EXISTS idx_entity_tags_entity_id;
DROP INDEX IF EXISTS idx_entity_tags_entity_table;
DROP INDEX IF EXISTS idx_tags_weight;
DROP INDEX IF EXISTS idx_tags_is_active;
DROP INDEX IF EXISTS idx_tags_name;
DROP INDEX IF EXISTS idx_tags_tag_set_id;
DROP INDEX IF EXISTS idx_tag_sets_weight;
DROP INDEX IF EXISTS idx_tag_sets_is_active;
DROP INDEX IF EXISTS idx_tag_sets_entity_table;
DROP INDEX IF EXISTS idx_tag_sets_name;

-- Drop tables
DROP TABLE IF EXISTS entity_tags;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS tag_sets;
