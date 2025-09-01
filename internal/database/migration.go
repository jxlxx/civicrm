package database

import (
	"context"
	"fmt"
	"sort"
	"time"

	"github.com/jxlxx/civicrm/internal/logger"
)

// Migration represents a database migration
type Migration struct {
	Version     int64
	Name        string
	Description string
	SQL         string
	CreatedAt   time.Time
}

// MigrationManager handles database migrations
type MigrationManager struct {
	db     *Database
	logger *logger.Logger
}

// NewMigrationManager creates a new migration manager
func NewMigrationManager(db *Database, logger *logger.Logger) *MigrationManager {
	return &MigrationManager{
		db:     db,
		logger: logger,
	}
}

// Initialize creates the migrations table if it doesn't exist
func (mm *MigrationManager) Initialize(ctx context.Context) error {
	createTableSQL := `
		CREATE TABLE IF NOT EXISTS migrations (
			version BIGINT PRIMARY KEY,
			name VARCHAR(255) NOT NULL,
			description TEXT,
			sql_content TEXT NOT NULL,
			created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
			executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
		);
	`

	_, err := mm.db.Exec(ctx, createTableSQL)
	if err != nil {
		return fmt.Errorf("failed to create migrations table: %w", err)
	}

	mm.logger.Info("Migrations table initialized")
	return nil
}

// GetAppliedMigrations returns all applied migrations
func (mm *MigrationManager) GetAppliedMigrations(ctx context.Context) ([]Migration, error) {
	query := `
		SELECT version, name, description, sql_content, created_at
		FROM migrations
		ORDER BY version ASC
	`

	rows, err := mm.db.Query(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("failed to query migrations: %w", err)
	}
	defer rows.Close()

	var migrations []Migration
	for rows.Next() {
		var migration Migration
		err := rows.Scan(
			&migration.Version,
			&migration.Name,
			&migration.Description,
			&migration.SQL,
			&migration.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan migration: %w", err)
		}
		migrations = append(migrations, migration)
	}

	return migrations, nil
}

// GetPendingMigrations returns migrations that haven't been applied
func (mm *MigrationManager) GetPendingMigrations(ctx context.Context, availableMigrations []Migration) ([]Migration, error) {
	appliedMigrations, err := mm.GetAppliedMigrations(ctx)
	if err != nil {
		return nil, err
	}

	appliedVersions := make(map[int64]bool)
	for _, migration := range appliedMigrations {
		appliedVersions[migration.Version] = true
	}

	var pendingMigrations []Migration
	for _, migration := range availableMigrations {
		if !appliedVersions[migration.Version] {
			pendingMigrations = append(pendingMigrations, migration)
		}
	}

	// Sort by version
	sort.Slice(pendingMigrations, func(i, j int) bool {
		return pendingMigrations[i].Version < pendingMigrations[j].Version
	})

	return pendingMigrations, nil
}

// ApplyMigration applies a single migration
func (mm *MigrationManager) ApplyMigration(ctx context.Context, migration Migration) error {
	// Start transaction
	tx, err := mm.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}

	// Execute migration SQL
	_, err = tx.ExecContext(ctx, migration.SQL)
	if err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to execute migration %s: %w", migration.Name, err)
	}

	// Record migration in migrations table
	insertSQL := `
		INSERT INTO migrations (version, name, description, sql_content, created_at)
		VALUES ($1, $2, $3, $4, $5)
	`

	_, err = tx.ExecContext(ctx, insertSQL,
		migration.Version,
		migration.Name,
		migration.Description,
		migration.SQL,
		time.Now(),
	)
	if err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to record migration %s: %w", migration.Name, err)
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit migration %s: %w", migration.Name, err)
	}

	mm.logger.Info("Migration applied successfully",
		"version", migration.Version,
		"name", migration.Name,
	)

	return nil
}

// RollbackMigration rolls back a migration
func (mm *MigrationManager) RollbackMigration(ctx context.Context, version int64) error {
	// Get migration details
	query := `
		SELECT name, sql_content FROM migrations WHERE version = $1
	`
	var name, sqlContent string
	err := mm.db.QueryRow(ctx, query, version).Scan(&name, &sqlContent)
	if err != nil {
		return fmt.Errorf("failed to get migration %d: %w", version, err)
	}

	// Start transaction
	tx, err := mm.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}

	// Execute rollback SQL (this would need to be defined in the migration)
	// For now, we'll just remove the migration record
	deleteSQL := `DELETE FROM migrations WHERE version = $1`
	_, err = tx.ExecContext(ctx, deleteSQL, version)
	if err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to rollback migration %d: %w", version, err)
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit rollback for migration %d: %w", version, err)
	}

	mm.logger.Info("Migration rolled back successfully",
		"version", version,
		"name", name,
	)

	return nil
}

// Migrate applies all pending migrations
func (mm *MigrationManager) Migrate(ctx context.Context, availableMigrations []Migration) error {
	// Initialize migrations table if needed
	if err := mm.Initialize(ctx); err != nil {
		return err
	}

	// Get pending migrations
	pendingMigrations, err := mm.GetPendingMigrations(ctx, availableMigrations)
	if err != nil {
		return fmt.Errorf("failed to get pending migrations: %w", err)
	}

	if len(pendingMigrations) == 0 {
		mm.logger.Info("No pending migrations")
		return nil
	}

	mm.logger.Info("Starting migration process",
		"pending_count", len(pendingMigrations),
	)

	// Apply each pending migration
	for _, migration := range pendingMigrations {
		mm.logger.Info("Applying migration",
			"version", migration.Version,
			"name", migration.Name,
		)

		if err := mm.ApplyMigration(ctx, migration); err != nil {
			return fmt.Errorf("migration failed at version %d (%s): %w", migration.Version, migration.Name, err)
		}
	}

	mm.logger.Info("Migration process completed successfully",
		"migrations_applied", len(pendingMigrations),
	)

	return nil
}

// GetMigrationStatus returns the current migration status
func (mm *MigrationManager) GetMigrationStatus(ctx context.Context, availableMigrations []Migration) (*MigrationStatus, error) {
	appliedMigrations, err := mm.GetAppliedMigrations(ctx)
	if err != nil {
		return nil, err
	}

	pendingMigrations, err := mm.GetPendingMigrations(ctx, availableMigrations)
	if err != nil {
		return nil, err
	}

	// Find the latest applied version
	var latestVersion int64
	if len(appliedMigrations) > 0 {
		latestVersion = appliedMigrations[len(appliedMigrations)-1].Version
	}

	return &MigrationStatus{
		CurrentVersion:    latestVersion,
		AppliedCount:      len(appliedMigrations),
		PendingCount:      len(pendingMigrations),
		TotalAvailable:    len(availableMigrations),
		AppliedMigrations: appliedMigrations,
		PendingMigrations: pendingMigrations,
	}, nil
}

// MigrationStatus represents the current migration status
type MigrationStatus struct {
	CurrentVersion    int64       `json:"current_version"`
	AppliedCount      int         `json:"applied_count"`
	PendingCount      int         `json:"pending_count"`
	TotalAvailable    int         `json:"total_available"`
	AppliedMigrations []Migration `json:"applied_migrations"`
	PendingMigrations []Migration `json:"pending_migrations"`
}
