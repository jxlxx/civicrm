# Database Migrations

This directory contains database migrations for CiviCRM using [Tern](https://github.com/jackc/tern), a PostgreSQL migration tool.

## Getting Started

### 1. Install Tern
```bash
make install-tern
```

### 2. Configure Database
Copy the example configuration:
```bash
cp tern.conf.example tern.conf
```

Edit `tern.conf` with your database credentials or set environment variables:
```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=civicrm
export DB_USER=civicrm
export DB_PASSWORD=your_password
```

### 3. Create Your First Migration
```bash
make migrate-new
# Enter: create_contacts_table
```

This creates a new migration file like `001_create_contacts_table.sql`

### 4. Edit Migration File
Edit the generated SQL file with your schema changes:

```sql
-- 001_create_contacts_table.sql
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Down migration (rollback)
DROP TABLE contacts;
```

### 5. Run Migrations
```bash
make migrate
```

## Available Commands

- `make migrate` - Run all pending migrations
- `make migrate-new` - Create a new migration file
- `make migrate-status` - Show migration status
- `make migrate-rollback` - Rollback to specific version

## Migration Best Practices

1. **Always include down migrations** for rollback capability
2. **Use descriptive names** for migration files
3. **Test migrations** in development before production
4. **Keep migrations small** and focused on single changes
5. **Use transactions** for complex migrations (Tern handles this automatically)

## Migration File Naming

Tern automatically numbers migrations sequentially:
- `001_create_contacts_table.sql`
- `002_add_contact_indexes.sql`
- `003_alter_contacts_add_phone.sql`

## Rollback

To rollback to a specific version:
```bash
make migrate-rollback
# Enter: 2  # Rollback to version 2
```

## Environment Variables

The following environment variables can be used in `tern.conf`:
- `DB_HOST` - Database host
- `DB_PORT` - Database port
- `DB_NAME` - Database name
- `DB_USER` - Database username
- `DB_PASSWORD` - Database password
- `DB_SSL_MODE` - SSL mode (disable, require, verify-ca, verify-full)

## Troubleshooting

- **Connection issues**: Check database credentials and network connectivity
- **Migration errors**: Check SQL syntax and database constraints
- **Version conflicts**: Ensure migrations are applied in order
- **Rollback issues**: Verify down migrations are correct

For more information, see the [Tern documentation](https://github.com/jackc/tern).
