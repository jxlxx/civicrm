# CiviCRM Database Layer

This directory contains the database layer implementation using **sqlc** for type-safe SQL code generation.

## Directory Structure

```
internal/database/
├── database.go          # Database connection and configuration
├── queries/             # SQL query files
│   ├── contacts.sql     # Contact-related queries
│   ├── events.sql       # Event-related queries
│   ├── contributions.sql # Contribution-related queries
│   └── event_registrations.sql # Event registration queries
├── generated/           # sqlc generated Go code (auto-generated)
└── README.md           # This file
```

## Setup

### 1. Install sqlc

```bash
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
```

### 2. Generate Go Code

```bash
# From project root
sqlc generate
```

This will generate Go code in `internal/database/generated/` based on your SQL queries and schema.

### 3. Update Generated Code

After modifying SQL queries or schema, regenerate:

```bash
sqlc generate
```

## Usage

### Generated Code

sqlc generates:
- **Models**: Go structs for your database tables
- **Querier Interface**: Interface with all your query methods
- **DB Implementation**: Concrete implementation of the interface

### Example Usage

```go
package main

import (
    "context"
    "database/sql"
    "log"
    
    "civicrm/internal/database/generated"
)

func main() {
    db, err := sql.Open("postgres", "postgres://...")
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()
    
    // Create querier
    querier := generated.New(db)
    
    // Use generated methods
    contacts, err := querier.ListAllContacts(context.Background(), 10, 0)
    if err != nil {
        log.Fatal(err)
    }
    
    for _, contact := range contacts {
        log.Printf("Contact: %s %s", contact.FirstName, contact.LastName)
    }
}
```

## Query Naming Conventions

- **CreateX** - Insert new records
- **GetX** - Retrieve single records
- **ListX** - Retrieve multiple records with pagination
- **UpdateX** - Modify existing records
- **DeleteX** - Remove records
- **CountX** - Count records
- **SearchX** - Search with text matching

## Adding New Queries

1. Add SQL to the appropriate `.sql` file in `queries/`
2. Follow the naming convention: `-- name: QueryName :return_type`
3. Run `sqlc generate` to create Go code
4. Use the new query in your Go code

## Database Schema

The schema is defined in the `migrations/` directory at the project root. Each migration file follows the pattern:

```sql
-- {version}_{description}.sql
CREATE TABLE table_name (
    -- table definition
);

-- Add indexes and triggers

---- create above / drop below ----

-- Drop statements for rollback
```

## Best Practices

1. **Always use transactions** for multi-statement operations
2. **Use context.Context** for cancellation and timeouts
3. **Handle errors properly** - sqlc methods return errors
4. **Use prepared statements** - sqlc generates these automatically
5. **Test your queries** with the generated code

## Troubleshooting

### Common Issues

1. **sqlc generate fails**: Check your SQL syntax and sqlc.yaml configuration
2. **Missing generated code**: Ensure `sqlc generate` was run successfully
3. **Type mismatches**: Verify Go types match your database schema

### Debugging

- Use `sqlc vet` to validate your SQL
- Check `sqlc.yaml` configuration
- Verify database connection and schema
