# CiviCRM Data Models & Database Strategy

## Overview

This document outlines the database architecture and data modeling strategy for the CiviCRM Go implementation. We'll use **sqlc** for type-safe SQL code generation, ensuring database operations are fast, safe, and maintainable.

## 🎯 **Current Implementation Status**

### **✅ Completed Systems (47% Complete)**

#### **1. Core Contact Management** 
- **Contact Types**: Individual, Organization, Household
- **Contact Details**: Addresses, Emails, Phones, Websites, IMs
- **Relationships**: Contact-to-contact relationships with types
- **Groups**: Hierarchical group management with nesting

#### **2. Financial Infrastructure**
- **Contributions**: Donation tracking with soft credits
- **Financial Types**: Transaction categorization
- **Payment Instruments**: Payment method tracking
- **Price Sets**: Flexible pricing structures
- **Line Items**: Detailed contribution breakdowns

#### **3. Event Management**
- **Events**: Complete event lifecycle management
- **Participants**: Event registration and tracking
- **Event Fees**: Flexible pricing and discounting
- **Event Templates**: Reusable event configurations

#### **4. Activity System**
- **Activities**: Calls, meetings, notes, and more
- **Activity Types**: Configurable activity categories
- **Activity Contacts**: Role-based participation tracking
- **Activity Status**: Workflow state management

#### **5. Membership System**
- **Membership Types**: Individual, Family, Corporate, etc.
- **Membership Status**: New, Current, Grace, Expired, etc.
- **Membership Payments**: Payment tracking and reconciliation
- **Membership Logs**: Complete audit trail

#### **6. Case Management**
- **Case Types**: Legal, Medical, Social Work, etc.
- **Case Status**: Open, Closed, Urgent with color coding
- **Case Contacts**: Role-based case participation
- **Case Activities**: Activity integration for case tracking

#### **7. Campaign Management**
- **Campaigns**: Fundraising, advocacy, outreach campaigns
- **Campaign Types**: 10 campaign categories
- **Campaign Status**: 12 status types with workflow
- **Campaign Integration**: Links to activities, contributions, events

#### **8. Tagging System**
- **Tag Sets**: Entity-specific tag categories
- **Tags**: Flexible tagging with colors and icons
- **Entity Tags**: Universal tagging across all entities

#### **9. Survey System** ✅ **NEW!**
- **Surveys**: 5 survey types with sample questions
- **Survey Questions**: Multiple question types (text, radio, checkbox, select, textarea)
- **Survey Responses**: Response tracking with status management
- **Survey Analytics**: Comprehensive response analysis and reporting
- **Campaign Integration**: Surveys linked to campaigns and target groups

### **🚧 Next Priority: Reporting & Analytics System**
- **Report Templates**: Report definition and configuration
- **Report Instances**: Individual report executions
- **Dashboard**: Dashboard configurations and widgets

## Database Technology Stack

### Primary Database
- **PostgreSQL 13+** - Primary database with advanced features
- **MySQL 8.0+** - Alternative database option for compatibility

### Tools & Libraries
- **sqlc** - SQL code generation for type-safe database operations
- **lib/pq** - PostgreSQL driver
- **go-sql-driver/mysql** - MySQL driver
- **database/sql** - Go's standard database interface

## Database Architecture

### Schema Organization
```
internal/database/
├── schema/           # SQL schema files (migrations)
│   ├── 001_base_tables.sql
│   ├── 002_contact_tables.sql
│   ├── 003_contribution_tables.sql
│   ├── 004_event_tables.sql
│   └── 005_extension_tables.sql
├── queries/          # SQL query files
│   ├── contacts.sql
│   ├── contributions.sql
│   ├── events.sql
│   └── reports.sql
├── generated/        # sqlc generated code
│   ├── db.go        # Database interface
│   ├── models.go     # Generated structs
│   └── querier.go    # Query implementations
└── migrations/       # Migration management
    ├── manager.go    # Migration orchestration
    └── runner.go     # Migration execution
```

### Table Naming Convention
- **Singular form** - `contact`, `contribution`, `event`
- **Snake case** - `contact_type`, `first_name`, `created_at`
- **Consistent prefixes** - `civicrm_` for core tables (optional)

## Migration Strategy

### Migration Files
Each migration file follows the pattern: `{version}_{description}.sql`

#### **Completed Migrations**
- **001_utilities.sql** - Database utility functions
- **002_contacts.sql** - Core contact tables
- **003_events.sql** - Event management tables
- **004_contributions.sql** - Contribution tracking
- **005_event_registrations.sql** - Event registration system
- **006_core_infrastructure.sql** - Lookup tables and core data
- **007_contact_details.sql** - Contact detail tables
- **008_contact_relationships.sql** - Contact relationships and groups
- **009_seed_core_data.sql** - Core infrastructure seed data
- **010_financial_infrastructure.sql** - Financial system tables
- **011_event_enhancement.sql** - Event enhancement tables
- **012_activity_system.sql** - Activity management system
- **013_seed_activity_data.sql** - Activity system seed data
- **014_membership_system.sql** - Membership management tables
- **015_seed_membership_data.sql** - Membership system seed data
- **016_case_management.sql** - Case management system
- **017_seed_case_data.sql** - Case management seed data
- **018_campaign_management.sql** - Campaign management system
- **019_seed_campaign_data.sql** - Campaign system seed data
- **020_tagging_system.sql** - Universal tagging system
- **021_survey_system.sql** - Survey management system
- **022_seed_survey_data.sql** - Survey system seed data

```sql
-- 001_base_tables.sql
CREATE TABLE IF NOT EXISTS civicrm_contact (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_type VARCHAR(50) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_contact_email ON civicrm_contact(email);
CREATE INDEX IF NOT EXISTS idx_contact_type ON civicrm_contact(contact_type);
CREATE INDEX IF NOT EXISTS idx_contact_created ON civicrm_contact(created_at);
```

### Migration Management
- **Version tracking** - `civicrm_migrations` table
- **Up/down migrations** - Rollback capability
- **Transaction safety** - All migrations run in transactions
- **Dependency ordering** - Foreign key constraints respected

### Migration Commands
```bash
# Generate new migration
sqlc migrate create add_contact_tables

# Apply pending migrations
sqlc migrate up

# Rollback last migration
sqlc migrate down

# Check migration status
sqlc migrate status
```

## SQL Code Generation with sqlc

### Configuration (`sqlc.yaml`)
```yaml
version: "2"
sql:
  - engine: "postgresql"
    queries: "internal/database/queries/"
    schema: "internal/database/schema/"
    gen:
      go:
        package: "db"
        out: "internal/database/generated"
        emit_json_tags: true
        emit_prepared_queries: false
        emit_interface: true
        emit_exact_table_names: false
        emit_empty_slices: true
        emit_exported_queries: true
        emit_result_struct_pointers: false
        emit_params_struct_pointers: false
        emit_methods_with_db_argument: false
        json_tags_case_style: "snake"
```

### Query Files
Each entity has its own query file with CRUD operations:

```sql
-- internal/database/queries/contacts.sql

-- name: CreateContact :one
INSERT INTO civicrm_contact (
    contact_type, first_name, last_name, email, phone
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetContact :one
SELECT * FROM civicrm_contact WHERE id = $1;

-- name: GetContactByEmail :one
SELECT * FROM civicrm_contact WHERE email = $1;

-- name: ListContacts :many
SELECT * FROM civicrm_contact 
WHERE contact_type = $1 
ORDER BY created_at DESC 
LIMIT $2 OFFSET $3;

-- name: UpdateContact :one
UPDATE civicrm_contact 
SET first_name = $2, last_name = $3, email = $4, phone = $5, updated_at = NOW()
WHERE id = $1 
RETURNING *;

-- name: DeleteContact :exec
DELETE FROM civicrm_contact WHERE id = $1;

-- name: CountContacts :one
SELECT COUNT(*) FROM civicrm_contact WHERE contact_type = $1;
```

### Generated Code
sqlc automatically generates:

```go
// internal/database/generated/models.go
type CivicrmContact struct {
    ID          uuid.UUID `json:"id"`
    ContactType string    `json:"contact_type"`
    FirstName   *string   `json:"first_name"`
    LastName    *string   `json:"last_name"`
    Email       *string   `json:"email"`
    Phone       *string   `json:"phone"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
}

// internal/database/generated/querier.go
type Querier interface {
    CreateContact(ctx context.Context, arg CreateContactParams) (CivicrmContact, error)
    GetContact(ctx context.Context, id uuid.UUID) (CivicrmContact, error)
    GetContactByEmail(ctx context.Context, email string) (CivicrmContact, error)
    ListContacts(ctx context.Context, arg ListContactsParams) ([]CivicrmContact, error)
    UpdateContact(ctx context.Context, arg UpdateContactParams) (CivicrmContact, error)
    DeleteContact(ctx context.Context, id uuid.UUID) error
    CountContacts(ctx context.Context, contactType string) (int64, error)
}
```

## Seed Data Strategy

### Initial Data
- **System configuration** - Default settings, options
- **Reference data** - Countries, states, contact types
- **Admin user** - Initial administrator account
- **Sample data** - Example contacts, contributions (optional)

### Seed Data Files
```sql
-- internal/database/seed/001_initial_data.sql
INSERT INTO civicrm_contact_type (name, label, description) VALUES
    ('Individual', 'Individual', 'Individual contact'),
    ('Organization', 'Organization', 'Organization contact'),
    ('Household', 'Household', 'Household contact');

INSERT INTO civicrm_country (name, iso_code, is_active) VALUES
    ('United States', 'US', true),
    ('Canada', 'CA', true),
    ('United Kingdom', 'GB', true);
```

### Seed Data Management
- **Environment-specific** - Different data for dev/staging/prod
- **Version controlled** - Seed data in git
- **Automated** - Part of migration process
- **Conditional** - Only insert if not exists

## Data Access Layer

### Repository Pattern
```go
// internal/domain/contact/repository.go
type ContactRepository interface {
    Create(ctx context.Context, contact *Contact) error
    GetByID(ctx context.Context, id string) (*Contact, error)
    GetByEmail(ctx context.Context, email string) (*Contact, error)
    Update(ctx context.Context, contact *Contact) error
    Delete(ctx context.Context, id string) error
    List(ctx context.Context, filter ContactFilter) ([]*Contact, error)
}

type ContactRepositoryImpl struct {
    db     *sql.DB
    querier db.Querier
    cache  cache.Manager
}
```

### Service Layer
```go
// internal/domain/contact/service.go
type ContactService interface {
    CreateContact(ctx context.Context, req CreateContactRequest) (*Contact, error)
    GetContact(ctx context.Context, id string) (*Contact, error)
    UpdateContact(ctx context.Context, id string, req UpdateContactRequest) (*Contact, error)
    DeleteContact(ctx context.Context, id string) error
    ListContacts(ctx context.Context, req ListContactsRequest) (*ContactListResponse, error)
}
```

## Database Relationships

### Core Relationships
1. **Contact → Contact** - Relationships between contacts
2. **Contact → Contribution** - Contact's donations
3. **Contact → Event** - Contact's event registrations
4. **Contact → Group** - Contact's group memberships
5. **Contact → Address** - Contact's addresses
6. **Contact → Email** - Contact's email addresses
7. **Contact → Phone** - Contact's phone numbers

### Foreign Key Strategy
- **Soft constraints** - Application-level validation
- **Hard constraints** - Database-level foreign keys for critical relationships
- **Cascade options** - Careful consideration of delete behaviors

## Performance Considerations

### Indexing Strategy
- **Primary keys** - UUID with proper indexing
- **Search fields** - Email, name, phone number indexes
- **Date fields** - Created/updated timestamp indexes
- **Composite indexes** - Multi-column queries
- **Partial indexes** - Conditional indexing for active records

### Query Optimization
- **Prepared statements** - sqlc generates these automatically
- **Connection pooling** - Efficient connection management
- **Read replicas** - Separate read/write databases for scale
- **Query analysis** - Regular query performance review

## Testing Strategy

### Database Testing
- **Test database** - Separate test instance
- **Migrations** - Test all migrations up/down
- **Seed data** - Test data insertion and cleanup
- **Transactions** - Test rollback scenarios

### Mock Strategy
- **Interface-based** - Easy mocking of repositories
- **Generated mocks** - Use sqlc interfaces for testing
- **Test doubles** - In-memory implementations for unit tests

## Migration Workflow

### Development Process
1. **Create migration** - Add new schema file
2. **Update queries** - Add/modify SQL queries
3. **Generate code** - Run `sqlc generate`
4. **Update repositories** - Use new generated code
5. **Test** - Verify functionality
6. **Commit** - Version control changes

### Deployment Process
1. **Schema validation** - Verify migration compatibility
2. **Backup** - Database backup before migration
3. **Apply migrations** - Run pending migrations
4. **Verify** - Check data integrity
5. **Rollback plan** - Ready to revert if needed

---

## CiviCRM Entity Checklist

This checklist tracks all entities from the original PHP CiviCRM project. Check off each entity as we implement it in Go.

### Core Contact Entities
- [x] **Contact** - Base contact entity (Individual, Organization, Household)
- [x] **Individual** - Individual contact type
- [x] **Organization** - Organization contact type
- [x] **Household** - Household contact type
- [x] **Contact Type** - Contact type definitions
- [x] **Contact Sub Type** - Contact subtype definitions

### Contact Relationships & Groups
- [x] **Relationship** - Relationships between contacts
- [x] **Relationship Type** - Relationship type definitions
- [x] **Group** - Contact groups
- [x] **Group Contact** - Group membership
- [x] **Group Nesting** - Hierarchical groups
- [x] **Group Organization** - Organization group relationships

### Contact Details
- [x] **Address** - Contact addresses
- [x] **Email** - Contact email addresses
- [x] **Phone** - Contact phone numbers
- [x] **IM** - Instant messaging handles
- [x] **Website** - Contact websites
- [x] **Note** - Contact notes
- [x] **Tag** - Contact tags
- [x] **Entity Tag** - Tag assignments

### Financial Entities
- [x] **Contribution** - Financial contributions
- [x] **Contribution Page** - Online contribution pages
- [x] **Contribution Product** - Products for contributions
- [x] **Contribution Recur** - Recurring contributions
- [x] **Contribution Soft** - Soft credits
- [x] **Financial Account** - Financial account structure
- [x] **Financial Type** - Financial transaction types
- [x] **Payment Instrument** - Payment methods
- [x] **Line Item** - Contribution line items
- [x] **Price Field** - Price field definitions
- [x] **Price Field Value** - Price field values
- [ ] **Price Set** - Price set definitions
- [ ] **Price Set Entity** - Price set assignments

### Event Management
- [x] **Event** - Events
- [x] **Event Registration** - Event registrations
- [x] **Participant** - Event participants
- [x] **Participant Payment** - Participant payments
- [x] **Event Template** - Event templates
- [x] **Event Type** - Event type definitions
- [x] **Discount** - Event discounts
- [x] **Fee Level** - Event fee levels
- [x] **Fee** - Event fees

### Membership
- [x] **Membership** - Membership records
- [x] **Membership Type** - Membership type definitions
- [x] **Membership Status** - Membership status definitions
- [x] **Membership Payment** - Membership payments
- [x] **Membership Log** - Membership change history

### Case Management
- [x] **Case** - Case records
- [x] **Case Type** - Case type definitions
- [x] **Case Contact** - Case participants
- [x] **Case Activity** - Case activities
- [x] **Case Role** - Case role definitions

### Activity & Communication
- [x] **Activity** - Activities (calls, meetings, etc.)
- [x] **Activity Contact** - Activity participants
- [x] **Activity Type** - Activity type definitions
- [x] **Survey** - Surveys
- [x] **Survey Respondent** - Survey responses

### Campaign Management
- [x] **Campaign** - Campaigns
- [x] **Campaign Type** - Campaign type definitions
- [x] **Campaign Status** - Campaign status definitions
- [x] **Campaign Contact** - Campaign participants
- [x] **Campaign Group** - Campaign group assignments
- [x] **Campaign Activity** - Campaign activities
- [x] **Campaign Contribution** - Campaign contributions
- [x] **Campaign Event** - Campaign events

### Tagging System
- [x] **Tag Set** - Tag set definitions
- [x] **Tag** - Individual tags
- [x] **Entity Tag** - Tag assignments to entities

### Survey System
- [x] **Survey** - Survey definitions and configurations
- [x] **Survey Question** - Individual survey questions
- [x] **Survey Response** - Individual survey submissions
- [x] **Survey Response Answer** - Individual answers to questions
- [x] **Survey Campaign** - Surveys linked to campaigns
- [x] **Survey Group** - Surveys targeted at specific groups

### Reporting & Analytics
- [ ] **Report Instance** - Report instances
- [ ] **Report Template** - Report templates
- [ ] **Dashboard** - Dashboard configurations
- [ ] **Dashboard Contact** - Dashboard assignments
- [ ] **Saved Search** - Saved search criteria
- [ ] **Custom Field** - Custom field definitions
- [ ] **Custom Group** - Custom field groups
- [ ] **Custom Value** - Custom field values

### System & Configuration
- [ ] **Domain** - Multi-domain support
- [ ] **Setting** - System settings
- [ ] **Navigation** - Navigation menu
- [ ] **Menu** - Menu structure
- [ ] **UF Group** - User framework groups
- [ ] **UF Field** - User framework fields
- [ ] **UF Join** - User framework joins
- [ ] **UF Match** - User framework matching
- [ ] **Job** - Background jobs
- [ ] **Job Log** - Job execution logs
- [ ] **Queue** - Queue management
- [ ] **Queue Item** - Queue items

### Extension & Integration
- [ ] **Extension** - Extension management
- [ ] **Managed** - Managed entities
- [ ] **Message Template** - Message templates
- [ ] **SMS Provider** - SMS service providers
- [ ] **Mailing** - Mailings
- [ ] **Mailing Group** - Mailing group assignments
- [ ] **Mailing Recipients** - Mailing recipients
- [ ] **Mailing Trackable URL** - Trackable URLs in mailings
- [ ] **Mailing Trackable Open** - Email open tracking

### Audit & Logging
- [ ] **Log** - System logs
- [ ] **System Log** - System activity logs
- [ ] **Recent Items** - Recently accessed items
- [ ] **Dedupe Exception** - Deduplication exceptions
- [ ] **Dedupe Rule** - Deduplication rules
- [ ] **Dedupe Rule Group** - Deduplication rule groups

### Additional Entities
- [ ] **PCP** - Personal campaign pages
- [ ] **PCP Block** - PCP blocks
- [ ] **Grant** - Grant records
- [ ] **Grant Program** - Grant programs
- [ ] **Pledge** - Pledge records
- [ ] **Pledge Block** - Pledge blocks
- [ ] **Pledge Payment** - Pledge payments
- [ ] **Premium** - Premium products
- [ ] **Product** - Product catalog
- [ ] **Subscription** - Subscription records
- [ ] **Subscription History** - Subscription change history

### Total Entities: 95+
**Progress: 51/95 (54%)**

---

## Implementation Priority

### Phase 1: Foundation (Weeks 1-4)
1. Contact (Individual, Organization, Household)
2. Contact Type & Sub Type
3. Basic Address, Email, Phone

### Phase 2: Core Business (Weeks 5-8)
1. Contribution & Financial entities
2. Event & Participant
3. Membership

### Phase 3: Advanced Features (Weeks 9-12)
1. Case Management
2. Activity & Communication
3. Reporting & Analytics

### Phase 4: Integration (Weeks 13-16)
1. Extension System
2. External Integrations
3. Advanced Customization

This checklist will be updated as we implement each entity, providing a clear view of our progress toward full CiviCRM functionality.
