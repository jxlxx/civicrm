# CiviCRM Data Models & Database Strategy

## Overview

This document outlines the database architecture and data modeling strategy for the CiviCRM Go implementation. We'll use **sqlc** for type-safe SQL code generation, ensuring database operations are fast, safe, and maintainable.

## 🎯 **Current Implementation Status**

### **✅ Completed Systems (82% Complete)**

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

#### **9. Survey System** ✅ **COMPLETE**
- **Surveys**: 5 survey types with sample questions
- **Survey Questions**: Multiple question types (text, radio, checkbox, select, textarea)
- **Survey Responses**: Response tracking with status management
- **Survey Analytics**: Comprehensive response analysis and reporting
- **Campaign Integration**: Surveys linked to campaigns and target groups

#### **10. Reporting & Analytics System** ✅ **NEW!**
- **Report Templates**: 6 system report types with SQL templates
- **Report Instances**: Scheduled and on-demand report execution
- **Report Results**: Performance metrics and stored results
- **Dashboards**: 4 pre-configured dashboards with widgets
- **Dashboard Widgets**: Multiple widget types (metrics, charts, lists)
- **Report Subscriptions**: Automated report delivery
- **Report Permissions**: Role-based access control

#### **11. Custom Fields System** ✅ **NEW!**
- **Custom Groups**: Extensible field groups for any entity
- **Custom Fields**: Flexible field types (text, date, boolean, select, etc.)
- **Custom Field Options**: Options for select/radio/checkbox fields
- **Custom Values**: Stored values for custom fields on entities
- **Entity Support**: Extends contacts, contributions, events, activities

#### **12. Communication System** ✅ **NEW!**
- **Message Templates**: Reusable templates for emails, SMS, letters
- **Mailing Lists**: Contact groups for mass communications
- **Mailings**: Email campaigns with tracking and analytics
- **Mailing Recipients**: Individual recipient management
- **Email Tracking**: Open tracking, click tracking, bounce handling
- **SMS Messages**: SMS communication management
- **Communication Preferences**: Contact opt-out and preference management

#### **13. Pledge System** ✅ **NEW!**
- **Pledge Blocks**: Campaign blocks for pledge drives
- **Pledges**: Recurring donation commitments
- **Pledge Payments**: Scheduled payment tracking
- **Pledge Groups**: Team fundraising and peer-to-peer campaigns
- **Pledge Reminders**: Automated payment reminders
- **Pledge Logs**: Complete audit trail for pledge changes

#### **14. Authentication & Authorization System** ✅ **NEW!**
- **Users**: User accounts with password hashing and admin flags
- **ACL Roles**: Predefined roles (administrator, user, everyone, authenticated)
- **ACL Rules**: Fine-grained permissions for View/Edit/Delete/Create operations
- **ACL Entity Roles**: Role assignments to users and contacts
- **ACL Cache**: Performance optimization for permission checks
- **UF Match**: Links between users and CiviCRM contacts
- **Permission System**: Comprehensive permission checking across all entities

### **✅ System & Configuration (COMPLETE)**
- **Domain**: Multi-domain support with complete management
- **Setting**: System settings and configuration with domain isolation
- **Navigation**: Menu and navigation management with hierarchical structure
- **User Framework**: Custom form system with groups, fields, and joins
- **Background Jobs**: Scheduled job management with execution tracking
- **Queue System**: Background processing queue management

## Database Technology Stack

### Primary Database
- **PostgreSQL 15+** - Primary database with advanced features
- **MySQL 8.0+** - Alternative database option for compatibility

### Tools & Libraries
- **sqlc** - SQL code generation for type-safe database operations
- **lib/pq** - PostgreSQL driver
- **go-sql-driver/mysql** - MySQL driver
- **database/sql** - Go's standard database interface

## Database Architecture

### ACL System Architecture
The Access Control List (ACL) system provides enterprise-grade security with fine-grained permissions:

#### **Core ACL Tables**
- **`acl_roles`**: Predefined roles (administrator, user, everyone, authenticated)
- **`acls`**: Permission rules linking roles to operations on specific objects
- **`acl_entity_roles`**: Role assignments to users and contacts
- **`acl_cache`**: Performance optimization for permission checks
- **`acl_contact_cache`**: User-specific accessible contact lists

#### **Permission Operations**
- **View**: Read access to records
- **Edit**: Modify existing records
- **Delete**: Remove records
- **Create**: Add new records

#### **ACL Rule Structure**
```sql
-- Example: Administrator can view all contacts
INSERT INTO acls (name, deny, entity_table, entity_id, operation, object_table, object_id, priority) VALUES
    ('Admin View All Contacts', FALSE, 'acl_roles', 
     (SELECT id FROM acl_roles WHERE name = 'administrator'), 
     'View', 'contacts', NULL, 1);
```

#### **Performance Features**
- **ACL Caching**: Automatic caching of permission results
- **Contact Cache**: Pre-computed lists of accessible contacts per user
- **Priority System**: Higher priority rules override lower ones
- **Deny Override**: Deny rules can override allow rules

#### **Security Features**
- **Multi-Domain**: Separate ACL rules per domain
- **Contact-Level**: Fine-grained control over contact access
- **Operation-Specific**: Different permissions for different operations
- **Role-Based**: Flexible role assignment system

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
- **002_acls.sql** - Access Control List system tables
- **003_users.sql** - User authentication and authorization tables
- **004_contacts.sql** - Core contact tables
- **005_events.sql** - Event management tables
- **006_contributions.sql** - Contribution tracking
- **007_event_registrations.sql** - Event registration system
- **008_core_infrastructure.sql** - Lookup tables and core data
- **009_contact_details.sql** - Contact detail tables
- **010_contact_relationships.sql** - Contact relationships and groups
- **011_seed_core_data.sql** - Core infrastructure seed data (includes ACL roles and admin user)
- **012_financial_infrastructure.sql** - Financial system tables
- **013_event_enhancement.sql** - Event enhancement tables
- **014_activity_system.sql** - Activity management system
- **015_seed_activity_data.sql** - Activity system seed data
- **016_membership_system.sql** - Membership management tables
- **017_seed_membership_data.sql** - Membership system seed data
- **018_case_management.sql** - Case management system
- **019_seed_case_data.sql** - Case management seed data
- **020_campaign_management.sql** - Campaign management system
- **021_seed_campaign_data.sql** - Campaign system seed data
- **022_tagging_system.sql** - Universal tagging system
- **023_survey_system.sql** - Survey management system
- **024_seed_survey_data.sql** - Survey system seed data
- **025_reporting_system.sql** - Reporting and analytics system
- **026_seed_reporting_data.sql** - Reporting system seed data
- **027_system_configuration.sql** - System configuration tables
- **028_seed_system_configuration.sql** - System configuration seed data
- **029_custom_fields_system.sql** - Custom fields system tables
- **030_communication_system.sql** - Communication system tables
- **031_pledge_system.sql** - Pledge system tables
- **032_seed_custom_fields_data.sql** - Custom fields seed data
- **033_seed_communication_data.sql** - Communication system seed data
- **034_seed_pledge_data.sql** - Pledge system seed data

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

# Migrate to specific version
make migrate-to VERSION=10

# Check current migration status
make migrate-status

# Rollback to specific version
make migrate-rollback
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

#### **ACL & Permission Queries**
The ACL system includes comprehensive query files for security operations:

- **`acls.sql`**: ACL role and rule management
- **`users.sql`**: User authentication and management  
- **`permissions.sql`**: Permission checking and accessible data retrieval

#### **Permission Checking Examples**
```sql
-- Check if user can view a specific contact
-- name: CheckContactPermission :one
SELECT COUNT(*) > 0 as has_permission FROM acls a
INNER JOIN acl_entity_roles aer ON a.entity_id = aer.acl_role_id
WHERE aer.entity_table = 'users' 
AND aer.entity_id = $1 
AND a.entity_table = 'acl_roles'
AND a.operation = 'View'
AND a.object_table = 'contacts'
AND (a.object_id = $2 OR a.object_id IS NULL)
AND a.deny = false
AND a.is_active = true
AND aer.is_active = true
ORDER BY a.priority ASC
LIMIT 1;

-- Get all contacts user can view
-- name: GetUserAccessibleContacts :many
SELECT DISTINCT c.* FROM contacts c
INNER JOIN acl_contact_cache acc ON c.id = acc.contact_id
WHERE acc.user_id = $1 
AND acc.operation = 'View'
ORDER BY c.last_name, c.first_name
LIMIT $2 OFFSET $3;
```

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
- [x] **Report Template** - Report definitions and configurations
- [x] **Report Instance** - Individual report executions
- [x] **Report Result** - Stored report data and performance metrics
- [x] **Dashboard** - Dashboard configurations and layouts
- [x] **Dashboard Widget** - Individual dashboard components
- [x] **Report Subscription** - Report delivery and subscriptions
- [x] **Report Permission** - Access control for reports
- [ ] **Saved Search** - Saved search criteria
- [x] **Custom Field** - Custom field definitions
- [x] **Custom Group** - Custom field groups
- [x] **Custom Value** - Custom field values

### System & Configuration
- [x] **Domain** - Multi-domain support
- [x] **Setting** - System settings
- [x] **Navigation** - Navigation menu
- [x] **Menu** - Menu structure
- [x] **UF Group** - User framework groups
- [x] **UF Field** - User framework fields
- [x] **UF Join** - User framework joins
- [x] **UF Match** - User framework matching
- [x] **Job** - Background jobs
- [x] **Job Log** - Job execution logs
- [x] **Queue** - Queue management
- [x] **Queue Item** - Queue items

### Extension & Integration
- [ ] **Extension** - Extension management
- [ ] **Managed** - Managed entities
- [x] **Message Template** - Message templates
- [x] **SMS Provider** - SMS service providers
- [x] **Mailing** - Mailings
- [x] **Mailing Group** - Mailing group assignments
- [x] **Mailing Recipients** - Mailing recipients
- [x] **Mailing Trackable URL** - Trackable URLs in mailings
- [x] **Mailing Trackable Open** - Email open tracking

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
- [x] **Pledge** - Pledge records
- [x] **Pledge Block** - Pledge blocks
- [x] **Pledge Payment** - Pledge payments
- [ ] **Premium** - Premium products
- [ ] **Product** - Product catalog
- [ ] **Subscription** - Subscription records
- [ ] **Subscription History** - Subscription change history

### Total Entities: 95+
**Progress: 87/95 (92%)**

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
