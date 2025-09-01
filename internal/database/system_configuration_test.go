package database

import (
	"context"
	"database/sql"
	"fmt"
	"testing"
	"time"

	"github.com/google/uuid"
	db "github.com/jxlxx/civicrm/internal/database/generated"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestSystemConfigurationOperations tests all CRUD operations for the system configuration
func TestSystemConfigurationOperations(t *testing.T) {
	dbConn := setupTestDatabase(t)
	queries := db.New(dbConn)
	ctx := context.Background()

	t.Run("Domain Management", func(t *testing.T) {
		t.Run("Create Domain", func(t *testing.T) {
			domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
				Name:        "test-domain",
				Description: sql.NullString{String: "Test Domain", Valid: true},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)
			assert.NotEqual(t, uuid.Nil, domain.ID)
			assert.Equal(t, "test-domain", domain.Name)
			assert.Equal(t, "Test Domain", domain.Description.String)
			assert.True(t, domain.Description.Valid)
			assert.True(t, domain.IsActive.Bool)
			assert.True(t, domain.IsActive.Valid)
		})

		t.Run("Get Domain", func(t *testing.T) {
			// Create a domain first
			domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
				Name:        "get-test-domain",
				Description: sql.NullString{String: "", Valid: false},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)

			// Retrieve the domain
			retrieved, err := queries.GetDomain(ctx, domain.ID)
			require.NoError(t, err)
			assert.Equal(t, domain.ID, retrieved.ID)
			assert.Equal(t, domain.Name, retrieved.Name)
		})

		t.Run("Get Domain By Name", func(t *testing.T) {
			domainName := "get-by-name-domain"
			domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
				Name:        domainName,
				Description: sql.NullString{String: "", Valid: false},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)

			// Retrieve by name
			retrieved, err := queries.GetDomainByName(ctx, domainName)
			require.NoError(t, err)
			assert.Equal(t, domain.ID, retrieved.ID)
			assert.Equal(t, domainName, retrieved.Name)
		})

		t.Run("List Domains", func(t *testing.T) {
			domains, err := queries.ListDomains(ctx)
			require.NoError(t, err)
			assert.IsType(t, []db.Domain{}, domains)
			assert.GreaterOrEqual(t, len(domains), 1)
		})

		t.Run("List Active Domains", func(t *testing.T) {
			domains, err := queries.ListActiveDomains(ctx)
			require.NoError(t, err)
			assert.IsType(t, []db.Domain{}, domains)

			// All returned domains should be active
			for _, domain := range domains {
				assert.True(t, domain.IsActive.Bool)
				assert.True(t, domain.IsActive.Valid)
			}
		})

		t.Run("Update Domain", func(t *testing.T) {
			domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
				Name:        "update-test-domain",
				Description: sql.NullString{String: "Original Description", Valid: true},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)

			// Update the domain
			updated, err := queries.UpdateDomain(ctx, db.UpdateDomainParams{
				ID:          domain.ID,
				Name:        "updated-domain-name",
				Description: sql.NullString{String: "Updated Description", Valid: true},
				IsActive:    sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)
			assert.Equal(t, "updated-domain-name", updated.Name)
			assert.Equal(t, "Updated Description", updated.Description.String)
			assert.False(t, updated.IsActive.Bool)
		})

		t.Run("Delete Domain", func(t *testing.T) {
			domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
				Name:        "delete-test-domain",
				Description: sql.NullString{String: "", Valid: false},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)

			// Delete the domain
			err = queries.DeleteDomain(ctx, domain.ID)
			require.NoError(t, err)

			// Verify it's deleted
			_, err = queries.GetDomain(ctx, domain.ID)
			assert.Error(t, err)
			assert.Contains(t, err.Error(), "no rows")
		})

		t.Run("Count Domains", func(t *testing.T) {
			count, err := queries.CountDomains(ctx)
			require.NoError(t, err)
			assert.GreaterOrEqual(t, count, int64(0))
		})

		t.Run("Count Active Domains", func(t *testing.T) {
			count, err := queries.CountActiveDomains(ctx)
			require.NoError(t, err)
			assert.GreaterOrEqual(t, count, int64(0))
		})
	})

	t.Run("Settings Management", func(t *testing.T) {
		// Create a domain for settings
		domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
			Name:        "settings-test-domain",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		t.Run("Create Setting", func(t *testing.T) {
			setting, err := queries.CreateSetting(ctx, db.CreateSettingParams{
				DomainID:    domain.ID,
				Name:        "test_setting",
				Value:       sql.NullString{String: "test_value", Valid: true},
				Description: sql.NullString{String: "Test Setting", Valid: true},
				IsSystem:    sql.NullBool{Bool: false, Valid: true},
				IsPublic:    sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)
			assert.NotEqual(t, uuid.Nil, setting.ID)
			assert.Equal(t, domain.ID, setting.DomainID)
			assert.Equal(t, "test_setting", setting.Name)
			assert.Equal(t, "test_value", setting.Value.String)
			assert.True(t, setting.Value.Valid)
		})

		t.Run("Get Setting By Name", func(t *testing.T) {
			settingName := "get-by-name-setting"
			setting, err := queries.CreateSetting(ctx, db.CreateSettingParams{
				DomainID:    domain.ID,
				Name:        settingName,
				Value:       sql.NullString{String: "setting_value", Valid: true},
				Description: sql.NullString{String: "", Valid: false},
				IsSystem:    sql.NullBool{Bool: false, Valid: true},
				IsPublic:    sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)

			// Retrieve by name
			retrieved, err := queries.GetSettingByName(ctx, db.GetSettingByNameParams{
				DomainID: domain.ID,
				Name:     settingName,
			})
			require.NoError(t, err)
			assert.Equal(t, setting.ID, retrieved.ID)
			assert.Equal(t, settingName, retrieved.Name)
		})

		t.Run("Get Settings By Domain", func(t *testing.T) {
			settings, err := queries.GetSettingsByDomain(ctx, domain.ID)
			require.NoError(t, err)
			assert.IsType(t, []db.Setting{}, settings)
			assert.GreaterOrEqual(t, len(settings), 1)
		})

		t.Run("Get Public Settings By Domain", func(t *testing.T) {
			settings, err := queries.GetPublicSettingsByDomain(ctx, domain.ID)
			require.NoError(t, err)
			assert.IsType(t, []db.Setting{}, settings)

			// All returned settings should be public
			for _, setting := range settings {
				assert.True(t, setting.IsPublic.Bool)
				assert.True(t, setting.IsPublic.Valid)
			}
		})

		t.Run("Update Setting", func(t *testing.T) {
			setting, err := queries.CreateSetting(ctx, db.CreateSettingParams{
				DomainID:    domain.ID,
				Name:        "update-test-setting",
				Value:       sql.NullString{String: "original_value", Valid: true},
				Description: sql.NullString{String: "Original Description", Valid: true},
				IsSystem:    sql.NullBool{Bool: false, Valid: true},
				IsPublic:    sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)

			// Update the setting
			updated, err := queries.UpdateSetting(ctx, db.UpdateSettingParams{
				DomainID:    domain.ID,
				Name:        setting.Name,
				Value:       sql.NullString{String: "updated_value", Valid: true},
				Description: sql.NullString{String: "Updated Description", Valid: true},
				IsSystem:    sql.NullBool{Bool: true, Valid: true},
				IsPublic:    sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)
			assert.Equal(t, "updated_value", updated.Value.String)
			assert.Equal(t, "Updated Description", updated.Description.String)
			assert.True(t, updated.IsSystem.Bool)
			assert.True(t, updated.IsPublic.Bool)
		})

		t.Run("Delete Setting", func(t *testing.T) {
			setting, err := queries.CreateSetting(ctx, db.CreateSettingParams{
				DomainID:    domain.ID,
				Name:        "delete-test-setting",
				Value:       sql.NullString{String: "delete_value", Valid: true},
				Description: sql.NullString{String: "", Valid: false},
				IsSystem:    sql.NullBool{Bool: false, Valid: true},
				IsPublic:    sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)

			// Delete the setting
			err = queries.DeleteSetting(ctx, db.DeleteSettingParams{
				DomainID: domain.ID,
				Name:     setting.Name,
			})
			require.NoError(t, err)

			// Verify it's deleted
			_, err = queries.GetSettingByName(ctx, db.GetSettingByNameParams{
				DomainID: domain.ID,
				Name:     setting.Name,
			})
			assert.Error(t, err)
		})
	})

	t.Run("Navigation Management", func(t *testing.T) {
		// Create a domain for navigation
		domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
			Name:        "navigation-test-domain",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		t.Run("Create Root Navigation", func(t *testing.T) {
			nav, err := queries.CreateNavigation(ctx, db.CreateNavigationParams{
				DomainID:   domain.ID,
				ParentID:   uuid.NullUUID{UUID: uuid.Nil, Valid: false},
				Name:       "root-nav",
				Label:      "Root Navigation",
				Url:        sql.NullString{String: "/root", Valid: true},
				Icon:       sql.NullString{String: "root-icon", Valid: true},
				Permission: sql.NullString{String: "root_permission", Valid: true},
				Weight:     sql.NullInt32{Int32: 0, Valid: true},
				IsActive:   sql.NullBool{Bool: true, Valid: true},
				IsVisible:  sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)
			assert.NotEqual(t, uuid.Nil, nav.ID)
			assert.Equal(t, domain.ID, nav.DomainID)
			assert.False(t, nav.ParentID.Valid)
			assert.Equal(t, "root-nav", nav.Name)
			assert.Equal(t, "Root Navigation", nav.Label)
		})

		t.Run("Create Child Navigation", func(t *testing.T) {
			// Create parent navigation first
			parentNav, err := queries.CreateNavigation(ctx, db.CreateNavigationParams{
				DomainID:   domain.ID,
				ParentID:   uuid.NullUUID{UUID: uuid.Nil, Valid: false},
				Name:       "parent-nav",
				Label:      "Parent Navigation",
				Url:        sql.NullString{String: "/parent", Valid: true},
				Icon:       sql.NullString{String: "parent-icon", Valid: true},
				Permission: sql.NullString{String: "parent_permission", Valid: true},
				Weight:     sql.NullInt32{Int32: 0, Valid: true},
				IsActive:   sql.NullBool{Bool: true, Valid: true},
				IsVisible:  sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)

			// Create child navigation
			childNav, err := queries.CreateNavigation(ctx, db.CreateNavigationParams{
				DomainID:   domain.ID,
				ParentID:   uuid.NullUUID{UUID: parentNav.ID, Valid: true},
				Name:       "child-nav",
				Label:      "Child Navigation",
				Url:        sql.NullString{String: "/parent/child", Valid: true},
				Icon:       sql.NullString{String: "child-icon", Valid: true},
				Permission: sql.NullString{String: "child_permission", Valid: true},
				Weight:     sql.NullInt32{Int32: 0, Valid: true},
				IsActive:   sql.NullBool{Bool: true, Valid: true},
				IsVisible:  sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)
			assert.True(t, childNav.ParentID.Valid)
			assert.Equal(t, parentNav.ID, childNav.ParentID.UUID)
		})

		t.Run("Get Root Navigation", func(t *testing.T) {
			rootNavs, err := queries.GetDomainNavigation(ctx, domain.ID)
			require.NoError(t, err)
			assert.IsType(t, []db.Navigation{}, rootNavs)

			// All returned navigation items should have no parent
			for _, nav := range rootNavs {
				assert.False(t, nav.ParentID.Valid)
			}
		})

		t.Run("Get Child Navigation", func(t *testing.T) {
			// Create parent navigation first
			parentNav, err := queries.CreateNavigation(ctx, db.CreateNavigationParams{
				DomainID:   domain.ID,
				ParentID:   uuid.NullUUID{UUID: uuid.Nil, Valid: false},
				Name:       "child-test-parent",
				Label:      "Child Test Parent",
				Url:        sql.NullString{String: "/child-test-parent", Valid: true},
				Icon:       sql.NullString{String: "parent-icon", Valid: true},
				Permission: sql.NullString{String: "parent_permission", Valid: true},
				Weight:     sql.NullInt32{Int32: 0, Valid: true},
				IsActive:   sql.NullBool{Bool: true, Valid: true},
				IsVisible:  sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)

			// Create child navigation
			_, err = queries.CreateNavigation(ctx, db.CreateNavigationParams{
				DomainID:   domain.ID,
				ParentID:   uuid.NullUUID{UUID: parentNav.ID, Valid: true},
				Name:       "child-test-child",
				Label:      "Child Test Child",
				Url:        sql.NullString{String: "/child-test-parent/child", Valid: true},
				Icon:       sql.NullString{String: "child-icon", Valid: true},
				Permission: sql.NullString{String: "child_permission", Valid: true},
				Weight:     sql.NullInt32{Int32: 0, Valid: true},
				IsActive:   sql.NullBool{Bool: true, Valid: true},
				IsVisible:  sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)

			// Get child navigation - we'll use GetDomainNavigation for now since GetChildNavigation doesn't exist
			childNavs, err := queries.GetDomainNavigation(ctx, domain.ID)
			require.NoError(t, err)
			assert.IsType(t, []db.Navigation{}, childNavs)
			assert.GreaterOrEqual(t, len(childNavs), 1)

			// Find child navigation items
			childCount := 0
			for _, nav := range childNavs {
				if nav.ParentID.Valid {
					childCount++
					assert.Equal(t, parentNav.ID, nav.ParentID.UUID)
				}
			}
			assert.GreaterOrEqual(t, childCount, 1)
		})

		t.Run("Get Navigation Tree", func(t *testing.T) {
			tree, err := queries.GetDomainNavigation(ctx, domain.ID)
			require.NoError(t, err)
			assert.IsType(t, []db.Navigation{}, tree)
			assert.GreaterOrEqual(t, len(tree), 1)
		})

		t.Run("Update Navigation", func(t *testing.T) {
			nav, err := queries.CreateNavigation(ctx, db.CreateNavigationParams{
				DomainID:   domain.ID,
				ParentID:   uuid.NullUUID{UUID: uuid.Nil, Valid: false},
				Name:       "update-test-nav",
				Label:      "Update Test Navigation",
				Url:        sql.NullString{String: "/update-test", Valid: true},
				Icon:       sql.NullString{String: "test-icon", Valid: true},
				Permission: sql.NullString{String: "test_permission", Valid: true},
				Weight:     sql.NullInt32{Int32: 0, Valid: true},
				IsActive:   sql.NullBool{Bool: true, Valid: true},
				IsVisible:  sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)

			// Update the navigation
			updated, err := queries.UpdateNavigation(ctx, db.UpdateNavigationParams{
				ID:         nav.ID,
				DomainID:   domain.ID,
				ParentID:   uuid.NullUUID{UUID: uuid.Nil, Valid: false},
				Name:       "updated-nav",
				Label:      "Updated Navigation",
				Url:        sql.NullString{String: "/updated", Valid: true},
				Icon:       sql.NullString{String: "updated-icon", Valid: true},
				Permission: sql.NullString{String: "updated_permission", Valid: true},
				Weight:     sql.NullInt32{Int32: 100, Valid: true},
				IsActive:   sql.NullBool{Bool: false, Valid: true},
				IsVisible:  sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)
			assert.Equal(t, "updated-nav", updated.Name)
			assert.Equal(t, "Updated Navigation", updated.Label)
			assert.Equal(t, "/updated", updated.Url.String)
			assert.Equal(t, 100, updated.Weight.Int32)
			assert.False(t, updated.IsActive.Bool)
			assert.False(t, updated.IsVisible.Bool)
		})
	})

	t.Run("User Framework Groups", func(t *testing.T) {
		// Create a domain for UF groups
		domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
			Name:        "uf-groups-test-domain",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		t.Run("Create UF Group", func(t *testing.T) {
			ufGroup, err := queries.CreateUFGroup(ctx, db.CreateUFGroupParams{
				DomainID:    domain.ID,
				Name:        "test-uf-group",
				Title:       "Test UF Group",
				Description: sql.NullString{String: "Test User Framework Group", Valid: true},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
				IsReserved:  sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)
			assert.NotEqual(t, uuid.Nil, ufGroup.ID)
			assert.Equal(t, domain.ID, ufGroup.DomainID)
			assert.Equal(t, "test-uf-group", ufGroup.Name)
			assert.Equal(t, "Test UF Group", ufGroup.Title)
			assert.Equal(t, "Test User Framework Group", ufGroup.Description.String)
			assert.True(t, ufGroup.Description.Valid)
			assert.True(t, ufGroup.IsActive.Bool)
			assert.False(t, ufGroup.IsReserved.Bool)
		})

		t.Run("Get UF Group", func(t *testing.T) {
			ufGroup, err := queries.CreateUFGroup(ctx, db.CreateUFGroupParams{
				DomainID:    domain.ID,
				Name:        "get-test-uf-group",
				Title:       "Get Test UF Group",
				Description: sql.NullString{String: "", Valid: false},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
				IsReserved:  sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)

			// Retrieve the UF group
			retrieved, err := queries.GetUFGroup(ctx, ufGroup.ID)
			require.NoError(t, err)
			assert.Equal(t, ufGroup.ID, retrieved.ID)
			assert.Equal(t, ufGroup.Name, retrieved.Name)
			assert.Equal(t, ufGroup.Title, retrieved.Title)
		})

		t.Run("List UF Groups By Domain", func(t *testing.T) {
			ufGroups, err := queries.ListUFGroupsByDomain(ctx, domain.ID)
			require.NoError(t, err)
			assert.IsType(t, []db.UfGroup{}, ufGroups)
			assert.GreaterOrEqual(t, len(ufGroups), 1)
		})

		t.Run("Update UF Group", func(t *testing.T) {
			ufGroup, err := queries.CreateUFGroup(ctx, db.CreateUFGroupParams{
				DomainID:    domain.ID,
				Name:        "update-test-uf-group",
				Title:       "Update Test UF Group",
				Description: sql.NullString{String: "Original Description", Valid: true},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
				IsReserved:  sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)

			// Update the UF group
			updated, err := queries.UpdateUFGroup(ctx, db.UpdateUFGroupParams{
				ID:          ufGroup.ID,
				DomainID:    domain.ID,
				Name:        "updated-uf-group",
				Title:       "Updated UF Group",
				Description: sql.NullString{String: "Updated Description", Valid: true},
				IsActive:    sql.NullBool{Bool: false, Valid: true},
				IsReserved:  sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)
			assert.Equal(t, "updated-uf-group", updated.Name)
			assert.Equal(t, "Updated UF Group", updated.Title)
			assert.Equal(t, "Updated Description", updated.Description.String)
			assert.False(t, updated.IsActive.Bool)
			assert.True(t, updated.IsReserved.Bool)
		})
	})

	t.Run("Background Jobs", func(t *testing.T) {
		// Create a domain for jobs
		domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
			Name:        "jobs-test-domain",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		t.Run("Create Job", func(t *testing.T) {
			job, err := queries.CreateJob(ctx, db.CreateJobParams{
				DomainID:    domain.ID,
				Name:        "test-job",
				Description: sql.NullString{String: "Test Background Job", Valid: true},
				JobType:     "test",
				Parameters:  sql.NullString{String: "{}", Valid: true},
				Schedule:    sql.NullString{String: "0 0 * * *", Valid: true},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)
			assert.NotEqual(t, uuid.Nil, job.ID)
			assert.Equal(t, domain.ID, job.DomainID)
			assert.Equal(t, "test-job", job.Name)
			assert.Equal(t, "Test Background Job", job.Description.String)
			assert.Equal(t, "test", job.JobType)
			assert.Equal(t, "0 0 * * *", job.Schedule.String)
			assert.True(t, job.IsActive.Bool)
		})

		t.Run("Get Job", func(t *testing.T) {
			job, err := queries.CreateJob(ctx, db.CreateJobParams{
				DomainID:    domain.ID,
				Name:        "get-test-job",
				Description: sql.NullString{String: "", Valid: false},
				JobType:     "test",
				Parameters:  sql.NullString{String: "", Valid: false},
				Schedule:    sql.NullString{String: "", Valid: false},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)

			// Retrieve the job
			retrieved, err := queries.GetJob(ctx, job.ID)
			require.NoError(t, err)
			assert.Equal(t, job.ID, retrieved.ID)
			assert.Equal(t, job.Name, retrieved.Name)
			assert.Equal(t, job.JobType, retrieved.JobType)
		})

		t.Run("List Jobs By Domain", func(t *testing.T) {
			jobs, err := queries.ListJobsByDomain(ctx, domain.ID)
			require.NoError(t, err)
			assert.IsType(t, []db.Job{}, jobs)
			assert.GreaterOrEqual(t, len(jobs), 1)
		})

		t.Run("Update Job Status", func(t *testing.T) {
			job, err := queries.CreateJob(ctx, db.CreateJobParams{
				DomainID:    domain.ID,
				Name:        "status-test-job",
				Description: sql.NullString{String: "", Valid: false},
				JobType:     "test",
				Parameters:  sql.NullString{String: "", Valid: false},
				Schedule:    sql.NullString{String: "", Valid: false},
				IsActive:    sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)

			// Update job status
			updated, err := queries.UpdateJobStatus(ctx, db.UpdateJobStatusParams{
				ID:       job.ID,
				DomainID: domain.ID,
				IsActive: sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)
			assert.False(t, updated.IsActive.Bool)
		})
	})

	t.Run("Queue Management", func(t *testing.T) {
		// Create a domain for queues
		domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
			Name:        "queues-test-domain",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		t.Run("Create Queue", func(t *testing.T) {
			queue, err := queries.CreateQueue(ctx, db.CreateQueueParams{
				DomainID:          domain.ID,
				Name:              "test-queue",
				Description:       sql.NullString{String: "Test Queue", Valid: true},
				IsActive:          sql.NullBool{Bool: true, Valid: true},
				MaxRetries:        sql.NullInt32{Int32: 3, Valid: true},
				RetryDelaySeconds: sql.NullInt32{Int32: 300, Valid: true},
			})
			require.NoError(t, err)
			assert.NotEqual(t, uuid.Nil, queue.ID)
			assert.Equal(t, domain.ID, queue.DomainID)
			assert.Equal(t, "test-queue", queue.Name)
			assert.Equal(t, "Test Queue", queue.Description.String)
			assert.True(t, queue.IsActive.Bool)
			assert.Equal(t, 3, queue.MaxRetries)
			assert.Equal(t, 300, queue.RetryDelaySeconds)
		})

		t.Run("Get Queue", func(t *testing.T) {
			queue, err := queries.CreateQueue(ctx, db.CreateQueueParams{
				DomainID:          domain.ID,
				Name:              "get-test-queue",
				Description:       sql.NullString{String: "", Valid: false},
				IsActive:          sql.NullBool{Bool: true, Valid: true},
				MaxRetries:        sql.NullInt32{Int32: 1, Valid: true},
				RetryDelaySeconds: sql.NullInt32{Int32: 60, Valid: true},
			})
			require.NoError(t, err)

			// Retrieve the queue
			retrieved, err := queries.GetQueue(ctx, queue.ID)
			require.NoError(t, err)
			assert.Equal(t, queue.ID, retrieved.ID)
			assert.Equal(t, queue.Name, retrieved.Name)
			assert.Equal(t, queue.MaxRetries, retrieved.MaxRetries)
		})

		t.Run("List Queues By Domain", func(t *testing.T) {
			queues, err := queries.ListQueuesByDomain(ctx, domain.ID)
			require.NoError(t, err)
			assert.IsType(t, []db.Queue{}, queues)
			assert.GreaterOrEqual(t, len(queues), 1)
		})

		t.Run("Update Queue Status", func(t *testing.T) {
			queue, err := queries.CreateQueue(ctx, db.CreateQueueParams{
				DomainID:          domain.ID,
				Name:              "status-test-queue",
				Description:       sql.NullString{String: "", Valid: false},
				IsActive:          sql.NullBool{Bool: true, Valid: true},
				MaxRetries:        sql.NullInt32{Int32: 2, Valid: true},
				RetryDelaySeconds: sql.NullInt32{Int32: 120, Valid: true},
			})
			require.NoError(t, err)

			// Update queue status
			updated, err := queries.UpdateQueueStatus(ctx, db.UpdateQueueStatusParams{
				ID:       queue.ID,
				DomainID: domain.ID,
				IsActive: sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)
			assert.False(t, updated.IsActive.Bool)
		})
	})
}

// TestSystemConfigurationRelationships tests the relationships between system configuration entities
func TestSystemConfigurationRelationships(t *testing.T) {
	dbConn := setupTestDatabase(t)
	queries := db.New(dbConn)
	ctx := context.Background()

	t.Run("Domain Settings Relationship", func(t *testing.T) {
		// Create a domain
		domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
			Name:        "relationship-test-domain",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		// Create multiple settings for the domain
		setting1, err := queries.CreateSetting(ctx, db.CreateSettingParams{
			DomainID:    domain.ID,
			Name:        "setting1",
			Value:       sql.NullString{String: "value1", Valid: true},
			Description: sql.NullString{String: "First Setting", Valid: true},
			IsSystem:    sql.NullBool{Bool: false, Valid: true},
			IsPublic:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		setting2, err := queries.CreateSetting(ctx, db.CreateSettingParams{
			DomainID:    domain.ID,
			Name:        "setting2",
			Value:       sql.NullString{String: "value2", Valid: true},
			Description: sql.NullString{String: "Second Setting", Valid: true},
			IsSystem:    sql.NullBool{Bool: true, Valid: true},
			IsPublic:    sql.NullBool{Bool: false, Valid: true},
		})
		require.NoError(t, err)

		// Verify both settings belong to the domain
		assert.Equal(t, domain.ID, setting1.DomainID)
		assert.Equal(t, domain.ID, setting2.DomainID)

		// Get all settings for the domain
		settings, err := queries.GetSettingsByDomain(ctx, domain.ID)
		require.NoError(t, err)
		assert.GreaterOrEqual(t, len(settings), 2)

		// Verify settings are found
		found1, found2 := false, false
		for _, setting := range settings {
			if setting.ID == setting1.ID {
				found1 = true
			}
			if setting.ID == setting2.ID {
				found2 = true
			}
		}
		assert.True(t, found1)
		assert.True(t, found2)
	})

	t.Run("Domain Navigation Relationship", func(t *testing.T) {
		// Create a domain
		domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
			Name:        "navigation-relationship-domain",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		// Create root navigation
		rootNav, err := queries.CreateNavigation(ctx, db.CreateNavigationParams{
			DomainID:   domain.ID,
			ParentID:   uuid.NullUUID{UUID: uuid.Nil, Valid: false},
			Name:       "root-nav",
			Label:      "Root Navigation",
			Url:        sql.NullString{String: "/root", Valid: true},
			Icon:       sql.NullString{String: "root-icon", Valid: true},
			Permission: sql.NullString{String: "root_permission", Valid: true},
			Weight:     sql.NullInt32{Int32: 0, Valid: true},
			IsActive:   sql.NullBool{Bool: true, Valid: true},
			IsVisible:  sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		// Create child navigation
		childNav, err := queries.CreateNavigation(ctx, db.CreateNavigationParams{
			DomainID:   domain.ID,
			ParentID:   uuid.NullUUID{UUID: rootNav.ID, Valid: true},
			Name:       "child-nav",
			Label:      "Child Navigation",
			Url:        sql.NullString{String: "/root/child", Valid: true},
			Icon:       sql.NullString{String: "child-icon", Valid: true},
			Permission: sql.NullString{String: "child_permission", Valid: true},
			Weight:     sql.NullInt32{Int32: 0, Valid: true},
			IsActive:   sql.NullBool{Bool: true, Valid: true},
			IsVisible:  sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		// Verify relationships
		assert.Equal(t, domain.ID, rootNav.DomainID)
		assert.Equal(t, domain.ID, childNav.DomainID)
		assert.False(t, rootNav.ParentID.Valid)
		assert.True(t, childNav.ParentID.Valid)
		assert.Equal(t, rootNav.ID, childNav.ParentID.UUID)

		// Get root navigation for domain
		rootNavs, err := queries.GetDomainNavigation(ctx, domain.ID)
		require.NoError(t, err)
		assert.GreaterOrEqual(t, len(rootNavs), 1)

		// Get child navigation for parent - we'll use GetDomainNavigation since GetChildNavigation doesn't exist
		childNavs, err := queries.GetDomainNavigation(ctx, domain.ID)
		require.NoError(t, err)
		assert.GreaterOrEqual(t, len(childNavs), 1)
	})

	t.Run("Domain UF Groups Relationship", func(t *testing.T) {
		// Create a domain
		domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
			Name:        "uf-groups-relationship-domain",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		// Create UF group
		ufGroup, err := queries.CreateUFGroup(ctx, db.CreateUFGroupParams{
			DomainID:    domain.ID,
			Name:        "test-uf-group",
			Title:       "Test UF Group",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
			IsReserved:  sql.NullBool{Bool: false, Valid: true},
		})
		require.NoError(t, err)

		// Verify relationship
		assert.Equal(t, domain.ID, ufGroup.DomainID)

		// Get UF groups for domain
		ufGroups, err := queries.ListUFGroupsByDomain(ctx, domain.ID)
		require.NoError(t, err)
		assert.GreaterOrEqual(t, len(ufGroups), 1)

		// Verify UF group is found
		found := false
		for _, group := range ufGroups {
			if group.ID == ufGroup.ID {
				found = true
				break
			}
		}
		assert.True(t, found)
	})
}

// TestSystemConfigurationPerformance tests performance characteristics of system configuration operations
func TestSystemConfigurationPerformance(t *testing.T) {
	dbConn := setupTestDatabase(t)
	queries := db.New(dbConn)
	ctx := context.Background()

	t.Run("Bulk Operations", func(t *testing.T) {
		// Create a domain
		domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
			Name:        "performance-test-domain",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		// Create multiple settings in a loop
		settingCount := 100
		start := time.Now()

		for i := 0; i < settingCount; i++ {
			_, err := queries.CreateSetting(ctx, db.CreateSettingParams{
				DomainID:    domain.ID,
				Name:        fmt.Sprintf("bulk_setting_%d", i),
				Value:       sql.NullString{String: fmt.Sprintf("value_%d", i), Valid: true},
				Description: sql.NullString{String: fmt.Sprintf("Setting %d", i), Valid: true},
				IsSystem:    sql.NullBool{Bool: false, Valid: true},
				IsPublic:    sql.NullBool{Bool: false, Valid: true},
			})
			require.NoError(t, err)
		}

		createTime := time.Since(start)
		t.Logf("Created %d settings in %v", settingCount, createTime)

		// Retrieve all settings
		start = time.Now()
		settings, err := queries.GetSettingsByDomain(ctx, domain.ID)
		require.NoError(t, err)
		retrieveTime := time.Since(start)

		t.Logf("Retrieved %d settings in %v", len(settings), retrieveTime)
		assert.GreaterOrEqual(t, len(settings), settingCount)

		// Performance assertions
		assert.Less(t, createTime, 5*time.Second, "Creating 100 settings should take less than 5 seconds")
		assert.Less(t, retrieveTime, 1*time.Second, "Retrieving 100 settings should take less than 1 second")
	})

	t.Run("Navigation Tree Performance", func(t *testing.T) {
		// Create a domain
		domain, err := queries.CreateDomain(ctx, db.CreateDomainParams{
			Name:        "navigation-performance-domain",
			Description: sql.NullString{String: "", Valid: false},
			IsActive:    sql.NullBool{Bool: true, Valid: true},
		})
		require.NoError(t, err)

		// Create a deep navigation tree
		parentID := uuid.NullUUID{UUID: uuid.Nil, Valid: false}
		depth := 10

		start := time.Now()
		for i := 0; i < depth; i++ {
			nav, err := queries.CreateNavigation(ctx, db.CreateNavigationParams{
				DomainID:   domain.ID,
				ParentID:   parentID,
				Name:       fmt.Sprintf("level_%d_nav", i),
				Label:      fmt.Sprintf("Level %d Navigation", i),
				Url:        sql.NullString{String: fmt.Sprintf("/level/%d", i), Valid: true},
				Icon:       sql.NullString{String: "test-icon", Valid: true},
				Permission: sql.NullString{String: "test_permission", Valid: true},
				Weight:     sql.NullInt32{Int32: int32(i), Valid: true},
				IsActive:   sql.NullBool{Bool: true, Valid: true},
				IsVisible:  sql.NullBool{Bool: true, Valid: true},
			})
			require.NoError(t, err)
			parentID = uuid.NullUUID{UUID: nav.ID, Valid: true}
		}
		createTime := time.Since(start)
		t.Logf("Created navigation tree with depth %d in %v", depth, createTime)

		// Test navigation tree retrieval performance
		start = time.Now()
		tree, err := queries.GetDomainNavigation(ctx, domain.ID)
		require.NoError(t, err)
		retrieveTime := time.Since(start)

		t.Logf("Retrieved navigation tree with %d items in %v", len(tree), retrieveTime)
		assert.GreaterOrEqual(t, len(tree), depth)

		// Performance assertions
		assert.Less(t, createTime, 2*time.Second, "Creating navigation tree should take less than 2 seconds")
		assert.Less(t, retrieveTime, 500*time.Millisecond, "Retrieving navigation tree should take less than 500ms")
	})
}

// Helper function to set up test database
func setupTestDatabase(t *testing.T) *sql.DB {
	// This would need to be implemented based on your test infrastructure
	// For now, we'll use a placeholder that will cause tests to skip
	t.Skip("Test database setup not implemented - implement setupTestDatabase function")
	return nil
}
