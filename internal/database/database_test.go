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

// TestActivitiesTable tests the activities table generated code
func TestActivitiesTable(t *testing.T) {
	// Test that we can create an activity instance
	activity := db.Activity{
		ID:                uuid.New(),
		ActivityTypeID:    uuid.New(),
		Subject:           sql.NullString{String: "Follow-up Call", Valid: true},
		ActivityDateTime:  time.Now(),
		Duration:          sql.NullInt32{Int32: 30, Valid: true},
		Location:          sql.NullString{String: "Office", Valid: true},
		Details:           sql.NullString{String: "Discuss project progress", Valid: true},
		IsTest:            sql.NullBool{Bool: false, Valid: true},
		IsAuto:            sql.NullBool{Bool: false, Valid: true},
		IsCurrentRevision: sql.NullBool{Bool: true, Valid: true},
		Result:            sql.NullString{String: "Completed", Valid: true},
		IsDeleted:         sql.NullBool{Bool: false, Valid: true},
		EngagementLevel:   sql.NullInt32{Int32: 5, Valid: true},
		Weight:            sql.NullInt32{Int32: 1, Valid: true},
		IsStar:            sql.NullBool{Bool: false, Valid: true},
	}

	require.NotNil(t, activity)
	require.Equal(t, "Follow-up Call", activity.Subject.String)
	require.True(t, activity.Duration.Valid)
	require.Equal(t, int32(30), activity.Duration.Int32)
	require.True(t, activity.IsCurrentRevision.Bool)

	// Test that we can create activity parameters
	createParams := db.CreateActivityParams{
		ActivityTypeID:    uuid.New(),
		Subject:           sql.NullString{String: "Team Meeting", Valid: true},
		ActivityDateTime:  time.Now(),
		Duration:          sql.NullInt32{Int32: 60, Valid: true},
		Location:          sql.NullString{String: "Conference Room", Valid: true},
		Details:           sql.NullString{String: "Weekly team sync", Valid: true},
		IsTest:            sql.NullBool{Bool: false, Valid: true},
		IsAuto:            sql.NullBool{Bool: false, Valid: true},
		IsCurrentRevision: sql.NullBool{Bool: true, Valid: true},
		Result:            sql.NullString{String: "Scheduled", Valid: true},
		IsDeleted:         sql.NullBool{Bool: false, Valid: true},
		EngagementLevel:   sql.NullInt32{Int32: 3, Valid: true},
		Weight:            sql.NullInt32{Int32: 1, Valid: true},
		IsStar:            sql.NullBool{Bool: false, Valid: true},
	}

	require.Equal(t, "Team Meeting", createParams.Subject.String)
	require.True(t, createParams.Duration.Valid)
	require.Equal(t, int32(60), createParams.Duration.Int32)
	require.True(t, createParams.IsCurrentRevision.Bool)
}
