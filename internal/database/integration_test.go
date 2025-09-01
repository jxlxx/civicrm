package database

import (
	"context"
	"database/sql"
	"os"
	"testing"

	db "github.com/jxlxx/civicrm/internal/database/generated"
	"github.com/stretchr/testify/require"
)

// TestDatabaseIntegration tests actual database operations
// This requires a test database to be set up
func TestDatabaseIntegration(t *testing.T) {
	// Skip if no test database configured
	dbURL := os.Getenv("TEST_DATABASE_URL")
	if dbURL == "" {
		t.Skip("TEST_DATABASE_URL not set - skipping integration tests")
	}

	// Connect to test database
	database, err := sql.Open("postgres", dbURL)
	require.NoError(t, err)
	defer database.Close()

	// Test connection
	err = database.Ping()
	require.NoError(t, err)

	// Create querier
	querier := db.New(database)
	require.NotNil(t, querier)

	// Test basic operations
	ctx := context.Background()

	// Test creating a contact
	contact, err := querier.CreateContact(ctx, db.CreateContactParams{
		ContactType: "Individual",
		FirstName:   sql.NullString{String: "Test", Valid: true},
		LastName:    sql.NullString{String: "User", Valid: true},
		Email:       sql.NullString{String: "test@example.com", Valid: true},
	})
	require.NoError(t, err)
	require.NotNil(t, contact)
	require.Equal(t, "Individual", contact.ContactType)

	// Test retrieving the contact
	retrieved, err := querier.GetContact(ctx, contact.ID)
	require.NoError(t, err)
	require.Equal(t, contact.ID, retrieved.ID)
	require.Equal(t, "Test", retrieved.FirstName.String)

	// Test updating the contact
	updated, err := querier.UpdateContact(ctx, db.UpdateContactParams{
		ID:          contact.ID,
		ContactType: "Individual",
		FirstName:   sql.NullString{String: "Updated", Valid: true},
		LastName:    sql.NullString{String: "User", Valid: true},
		Email:       sql.NullString{String: "updated@example.com", Valid: true},
	})
	require.NoError(t, err)
	require.Equal(t, "Updated", updated.FirstName.String)

	// Test deleting the contact
	err = querier.DeleteContact(ctx, contact.ID)
	require.NoError(t, err)

	// Verify deletion
	_, err = querier.GetContact(ctx, contact.ID)
	require.Error(t, err) // Should fail to find deleted contact
}

// TestDatabaseMigrations tests that all our migrations work
func TestDatabaseMigrations(t *testing.T) {
	// This would test running migrations up and down
	// For now, we'll skip it since it requires a test database
	t.Skip("Migration testing requires test database setup")
}
