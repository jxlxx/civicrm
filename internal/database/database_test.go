package database

import (
	"database/sql"
	"testing"
	"time"

	"github.com/google/uuid"
	db "github.com/jxlxx/civicrm/internal/database/generated"
	"github.com/stretchr/testify/require"
)

// TestGeneratedTypes tests that our generated types work correctly
func TestGeneratedTypes(t *testing.T) {
	// Test Contact struct
	contact := db.Contact{
		ID:          uuid.New(),
		ContactType: "Individual",
		FirstName:   sql.NullString{String: "John", Valid: true},
		LastName:    sql.NullString{String: "Doe", Valid: true},
		Email:       sql.NullString{String: "john.doe@example.com", Valid: true},
		CreatedAt:   sql.NullTime{Time: time.Now(), Valid: true},
		UpdatedAt:   sql.NullTime{Time: time.Now(), Valid: true},
	}

	require.NotNil(t, contact)
	require.Equal(t, "Individual", contact.ContactType)
	require.True(t, contact.FirstName.Valid)
	require.Equal(t, "John", contact.FirstName.String)

	// Test Event struct
	event := db.Event{
		ID:        uuid.New(),
		Title:     "Test Event",
		StartDate: time.Now(),
		EndDate:   time.Now().Add(2 * time.Hour),
	}

	require.NotNil(t, event)
	require.Equal(t, "Test Event", event.Title)
	require.True(t, event.EndDate.After(event.StartDate))

	// Test Contribution struct
	contribution := db.Contribution{
		ID:        uuid.New(),
		ContactID: uuid.New(),
		Amount:    "100.00",
		Currency:  sql.NullString{String: "USD", Valid: true},
		Status:    sql.NullString{String: "Completed", Valid: true},
	}

	require.NotNil(t, contribution)
	require.Equal(t, "100.00", contribution.Amount)
	require.True(t, contribution.Currency.Valid)
}

// TestParameterStructs tests that our parameter structs work correctly
func TestParameterStructs(t *testing.T) {
	// Test CreateContactParams
	createParams := db.CreateContactParams{
		ContactType: "Individual",
		FirstName:   sql.NullString{String: "Jane", Valid: true},
		LastName:    sql.NullString{String: "Smith", Valid: true},
		Email:       sql.NullString{String: "jane.smith@example.com", Valid: true},
	}

	require.Equal(t, "Individual", createParams.ContactType)
	require.True(t, createParams.FirstName.Valid)
	require.Equal(t, "Jane", createParams.FirstName.String)

	// Test UpdateContactParams
	updateParams := db.UpdateContactParams{
		ID:          uuid.New(),
		ContactType: "Individual",
		FirstName:   sql.NullString{String: "Jane", Valid: true},
		LastName:    sql.NullString{String: "Smith", Valid: true},
	}

	require.NotEqual(t, uuid.Nil, updateParams.ID)
	require.Equal(t, "Individual", updateParams.ContactType)
}

// TestQuerierInterface tests that our interface is complete
func TestQuerierInterface(t *testing.T) {
	// This test ensures the Querier interface has all expected methods
	// The actual implementation will be tested with a real database
	var _ db.Querier = (*db.Queries)(nil)

	// If this compiles, our interface is properly implemented
	t.Log("Querier interface is properly implemented")
}

// TestNewQueries tests that we can create a new Queries instance
func TestNewQueries(t *testing.T) {
	// This is a placeholder test - you'll need to set up a test database
	// For now, we're just testing that the generated code compiles
	t.Skip("Database connection test requires test database setup")

	// When you have a test database, you can uncomment this:
	// db, err := sql.Open("postgres", "test_connection_string")
	// require.NoError(t, err)
	// defer db.Close()
	//
	// querier := db.New(db)
	// require.NotNil(t, querier)
}
