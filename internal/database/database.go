package database

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/jxlxx/civicrm/internal/config"
	"github.com/jxlxx/civicrm/internal/logger"
	_ "github.com/lib/pq"
)

// Database represents the database connection manager
type Database struct {
	config *config.DatabaseConfig
	db     *sql.DB
	logger *logger.Logger
}

// New creates a new database connection
func New(config *config.DatabaseConfig) (*Database, error) {
	db := &Database{
		config: config,
	}

	// Build connection string
	dsn, err := db.buildDSN()
	if err != nil {
		return nil, fmt.Errorf("failed to build DSN: %w", err)
	}

	// Open database connection
	sqlDB, err := sql.Open(config.Driver, dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Configure connection pool
	sqlDB.SetMaxOpenConns(config.MaxConns)
	sqlDB.SetMaxIdleConns(config.MaxConns / 2)
	sqlDB.SetConnMaxLifetime(time.Hour)

	// Test connection
	ctx, cancel := context.WithTimeout(context.Background(), config.Timeout)
	defer cancel()

	if err := sqlDB.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	db.db = sqlDB
	return db, nil
}

// buildDSN builds the database connection string
func (db *Database) buildDSN() (string, error) {
	switch db.config.Driver {
	case "postgres":
		return fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
			db.config.Host, db.config.Port, db.config.Username, db.config.Password,
			db.config.Database, db.config.SSLMode), nil
	case "mysql":
		return fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?parseTime=true&timeout=%s",
			db.config.Username, db.config.Password, db.config.Host, db.config.Port,
			db.config.Database, db.config.Timeout), nil
	default:
		return "", fmt.Errorf("unsupported database driver: %s", db.config.Driver)
	}
}

// Close closes the database connection
func (db *Database) Close() error {
	if db.db != nil {
		return db.db.Close()
	}
	return nil
}

// Ping checks if the database is accessible
func (db *Database) Ping(ctx context.Context) error {
	return db.db.PingContext(ctx)
}

// Begin starts a new transaction
func (db *Database) Begin(ctx context.Context) (*sql.Tx, error) {
	return db.db.BeginTx(ctx, nil)
}

// Exec executes a query without returning rows
func (db *Database) Exec(ctx context.Context, query string, args ...interface{}) (sql.Result, error) {
	return db.db.ExecContext(ctx, query, args...)
}

// Query executes a query that returns rows
func (db *Database) Query(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error) {
	return db.db.QueryContext(ctx, query, args...)
}

// QueryRow executes a query that returns a single row
func (db *Database) QueryRow(ctx context.Context, query string, args ...interface{}) *sql.Row {
	return db.db.QueryRowContext(ctx, query, args...)
}

// Prepare creates a prepared statement
func (db *Database) Prepare(ctx context.Context, query string) (*sql.Stmt, error) {
	return db.db.PrepareContext(ctx, query)
}

// Stats returns database statistics
func (db *Database) Stats() sql.DBStats {
	return db.db.Stats()
}

// SetLogger sets the logger for the database
func (db *Database) SetLogger(logger *logger.Logger) {
	db.logger = logger
}

// Transaction executes a function within a transaction
func (db *Database) Transaction(ctx context.Context, fn func(*sql.Tx) error) error {
	tx, err := db.Begin(ctx)
	if err != nil {
		return err
	}

	defer func() {
		if p := recover(); p != nil {
			tx.Rollback()
			panic(p)
		}
	}()

	if err := fn(tx); err != nil {
		if rbErr := tx.Rollback(); rbErr != nil {
			return fmt.Errorf("tx failed: %v, rollback failed: %v", err, rbErr)
		}
		return err
	}

	return tx.Commit()
}
