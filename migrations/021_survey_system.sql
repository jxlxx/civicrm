-- Survey system tables
-- These tables handle the complete survey system for CiviCRM

-- Surveys (survey definitions and configurations)
CREATE TABLE surveys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    instructions TEXT,
    thank_you_text TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_default BOOLEAN DEFAULT FALSE,
    created_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    modified_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Survey questions (individual questions within surveys)
CREATE TABLE survey_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    survey_id UUID NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL, -- text, textarea, select, radio, checkbox, date, etc.
    question_options TEXT, -- JSON array for select/radio/checkbox options
    is_required BOOLEAN DEFAULT FALSE,
    weight INTEGER DEFAULT 0,
    help_text TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Survey responses (individual survey submissions)
CREATE TABLE survey_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    survey_id UUID NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    response_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'Completed', -- Completed, Partial, Abandoned
    ip_address INET,
    user_agent TEXT,
    is_test BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Survey response answers (individual answers to questions)
CREATE TABLE survey_response_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    survey_response_id UUID NOT NULL REFERENCES survey_responses(id) ON DELETE CASCADE,
    survey_question_id UUID NOT NULL REFERENCES survey_questions(id) ON DELETE CASCADE,
    answer_text TEXT,
    answer_numeric DECIMAL(15,2),
    answer_date DATE,
    answer_boolean BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Survey campaigns (surveys linked to campaigns)
CREATE TABLE survey_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    survey_id UUID NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Survey groups (surveys targeted at specific groups)
CREATE TABLE survey_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    survey_id UUID NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_surveys_title ON surveys(title);
CREATE INDEX idx_surveys_is_active ON surveys(is_active);
CREATE INDEX idx_surveys_is_default ON surveys(is_default);
CREATE INDEX idx_surveys_created_date ON surveys(created_date);

CREATE INDEX idx_survey_questions_survey_id ON survey_questions(survey_id);
CREATE INDEX idx_survey_questions_question_type ON survey_questions(question_type);
CREATE INDEX idx_survey_questions_is_active ON survey_questions(is_active);
CREATE INDEX idx_survey_questions_weight ON survey_questions(weight);

CREATE INDEX idx_survey_responses_survey_id ON survey_responses(survey_id);
CREATE INDEX idx_survey_responses_contact_id ON survey_responses(contact_id);
CREATE INDEX idx_survey_responses_response_date ON survey_responses(response_date);
CREATE INDEX idx_survey_responses_status ON survey_responses(status);
CREATE INDEX idx_survey_responses_is_test ON survey_responses(is_test);

CREATE INDEX idx_survey_response_answers_response_id ON survey_response_answers(survey_response_id);
CREATE INDEX idx_survey_response_answers_question_id ON survey_response_answers(survey_question_id);

CREATE INDEX idx_survey_campaigns_survey_id ON survey_campaigns(survey_id);
CREATE INDEX idx_survey_campaigns_campaign_id ON survey_campaigns(campaign_id);
CREATE INDEX idx_survey_campaigns_is_active ON survey_campaigns(is_active);

CREATE INDEX idx_survey_groups_survey_id ON survey_groups(survey_id);
CREATE INDEX idx_survey_groups_group_id ON survey_groups(group_id);
CREATE INDEX idx_survey_groups_is_active ON survey_groups(is_active);

-- Add triggers for updated_at
CREATE TRIGGER update_surveys_updated_at BEFORE UPDATE ON surveys
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_questions_updated_at BEFORE UPDATE ON survey_questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_responses_updated_at BEFORE UPDATE ON survey_responses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_response_answers_updated_at BEFORE UPDATE ON survey_response_answers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_campaigns_updated_at BEFORE UPDATE ON survey_campaigns
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_survey_groups_updated_at BEFORE UPDATE ON survey_groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

---- create above / drop below ----

-- Drop triggers
DROP TRIGGER IF EXISTS update_survey_groups_updated_at ON survey_groups;
DROP TRIGGER IF EXISTS update_survey_campaigns_updated_at ON survey_campaigns;
DROP TRIGGER IF EXISTS update_survey_response_answers_updated_at ON survey_response_answers;
DROP TRIGGER IF EXISTS update_survey_responses_updated_at ON survey_responses;
DROP TRIGGER IF EXISTS update_survey_questions_updated_at ON survey_questions;
DROP TRIGGER IF EXISTS update_surveys_updated_at ON surveys;

-- Drop indexes
DROP INDEX IF EXISTS idx_survey_groups_is_active;
DROP INDEX IF EXISTS idx_survey_groups_group_id;
DROP INDEX IF EXISTS idx_survey_groups_survey_id;
DROP INDEX IF EXISTS idx_survey_campaigns_is_active;
DROP INDEX IF EXISTS idx_survey_campaigns_campaign_id;
DROP INDEX IF EXISTS idx_survey_campaigns_survey_id;
DROP INDEX IF EXISTS idx_survey_response_answers_question_id;
DROP INDEX IF EXISTS idx_survey_response_answers_response_id;
DROP INDEX IF EXISTS idx_survey_responses_is_test;
DROP INDEX IF EXISTS idx_survey_responses_status;
DROP INDEX IF EXISTS idx_survey_responses_response_date;
DROP INDEX IF EXISTS idx_survey_responses_contact_id;
DROP INDEX IF EXISTS idx_survey_responses_survey_id;
DROP INDEX IF EXISTS idx_survey_questions_weight;
DROP INDEX IF EXISTS idx_survey_questions_is_active;
DROP INDEX IF EXISTS idx_survey_questions_question_type;
DROP INDEX IF EXISTS idx_survey_questions_survey_id;
DROP INDEX IF EXISTS idx_surveys_created_date;
DROP INDEX IF EXISTS idx_surveys_is_default;
DROP INDEX IF EXISTS idx_surveys_is_active;
DROP INDEX IF EXISTS idx_surveys_title;

-- Drop tables
DROP TABLE IF EXISTS survey_groups;
DROP TABLE IF EXISTS survey_campaigns;
DROP TABLE IF EXISTS survey_response_answers;
DROP TABLE IF EXISTS survey_responses;
DROP TABLE IF EXISTS survey_questions;
DROP TABLE IF EXISTS surveys;
