package services

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	db "github.com/jxlxx/civicrm/internal/database/generated"
	"github.com/jxlxx/civicrm/internal/logger"
	"github.com/jxlxx/civicrm/internal/security"
)

// EntityService handles CRUD operations for CiviCRM entities
type EntityService struct {
	querier  db.Querier
	logger   *logger.Logger
	security *security.Manager
}

// NewEntityService creates a new entity service
func NewEntityService(querier db.Querier, logger *logger.Logger, security *security.Manager) *EntityService {
	return &EntityService{
		querier:  querier,
		logger:   logger,
		security: security,
	}
}

// EntityGetParams represents parameters for entity retrieval
type EntityGetParams struct {
	ID      *string `json:"id,omitempty"`
	Select  *string `json:"select,omitempty"`
	Where   *string `json:"where,omitempty"`
	OrderBy *string `json:"orderBy,omitempty"`
	Limit   *int    `json:"limit,omitempty"`
	Offset  *int    `json:"offset,omitempty"`
	Join    *string `json:"join,omitempty"`
	GroupBy *string `json:"groupBy,omitempty"`
	Having  *string `json:"having,omitempty"`
}

// EntityCreateParams represents parameters for entity creation
type EntityCreateParams struct {
	Values map[string]interface{} `json:"values"`
}

// EntityUpdateParams represents parameters for entity updates
type EntityUpdateParams struct {
	ID     string                 `json:"id"`
	Values map[string]interface{} `json:"values"`
}

// EntityDeleteParams represents parameters for entity deletion
type EntityDeleteParams struct {
	ID string `json:"id"`
}

// APIResponse represents the standard CiviCRM API response
type APIResponse struct {
	Values       []map[string]interface{} `json:"values"`
	Count        int                      `json:"count"`
	IsError      bool                     `json:"is_error"`
	ErrorMessage *string                  `json:"error_message,omitempty"`
	ErrorCode    *string                  `json:"error_code,omitempty"`
	ErrorData    map[string]interface{}   `json:"error_data,omitempty"`
}

// Get handles entity retrieval operations
func (s *EntityService) Get(ctx context.Context, entity string, params EntityGetParams) (*APIResponse, error) {
	// Validate entity type
	if !s.isValidEntity(entity) {
		return s.errorResponse("Invalid entity type: "+entity, "INVALID_ENTITY"), nil
	}

	// Check permissions
	if err := s.checkPermissions(ctx, entity, "View"); err != nil {
		return s.errorResponse("Permission denied", "PERMISSION_DENIED"), nil
	}

	// Handle single entity retrieval by ID
	if params.ID != nil && *params.ID != "" {
		return s.getSingleEntity(ctx, entity, *params.ID, params)
	}

	// Handle multiple entity retrieval
	return s.getMultipleEntities(ctx, entity, params)
}

// Create handles entity creation operations
func (s *EntityService) Create(ctx context.Context, entity string, params EntityCreateParams) (*APIResponse, error) {
	// Validate entity type
	if !s.isValidEntity(entity) {
		return s.errorResponse("Invalid entity type: "+entity, "INVALID_ENTITY"), nil
	}

	// Check permissions
	if err := s.checkPermissions(ctx, entity, "Create"); err != nil {
		return s.errorResponse("Permission denied", "PERMISSION_DENIED"), nil
	}

	// Validate required fields
	if err := s.validateRequiredFields(entity, params.Values); err != nil {
		return s.errorResponse("Missing required fields: "+err.Error(), "MISSING_REQUIRED_FIELDS"), nil
	}

	// Create the entity
	createdEntity, err := s.createEntity(ctx, entity, params.Values)
	if err != nil {
		s.logger.Error("Failed to create entity", "entity", entity, "error", err)
		return s.errorResponse("Failed to create entity: "+err.Error(), "CREATE_FAILED"), nil
	}

	return &APIResponse{
		Values:  []map[string]interface{}{createdEntity},
		Count:   1,
		IsError: false,
	}, nil
}

// Update handles entity update operations
func (s *EntityService) Update(ctx context.Context, entity string, params EntityUpdateParams) (*APIResponse, error) {
	// Validate entity type
	if !s.isValidEntity(entity) {
		return s.errorResponse("Invalid entity type: "+entity, "INVALID_ENTITY"), nil
	}

	// Check permissions
	if err := s.checkPermissions(ctx, entity, "Edit"); err != nil {
		return s.errorResponse("Permission denied", "PERMISSION_DENIED"), nil
	}

	// Update the entity
	updatedEntity, err := s.updateEntity(ctx, entity, params.ID, params.Values)
	if err != nil {
		s.logger.Error("Failed to update entity", "entity", entity, "id", params.ID, "error", err)
		return s.errorResponse("Failed to update entity: "+err.Error(), "UPDATE_FAILED"), nil
	}

	return &APIResponse{
		Values:  []map[string]interface{}{updatedEntity},
		Count:   1,
		IsError: false,
	}, nil
}

// Delete handles entity deletion operations
func (s *EntityService) Delete(ctx context.Context, entity string, params EntityDeleteParams) (*APIResponse, error) {
	// Validate entity type
	if !s.isValidEntity(entity) {
		return s.errorResponse("Invalid entity type: "+entity, "INVALID_ENTITY"), nil
	}

	// Check permissions
	if err := s.checkPermissions(ctx, entity, "Delete"); err != nil {
		return s.errorResponse("Permission denied", "PERMISSION_DENIED"), nil
	}

	// Delete the entity
	if err := s.deleteEntity(ctx, entity, params.ID); err != nil {
		s.logger.Error("Failed to delete entity", "entity", entity, "id", params.ID, "error", err)
		return s.errorResponse("Failed to delete entity: "+err.Error(), "DELETE_FAILED"), nil
	}

	return &APIResponse{
		Values:  []map[string]interface{}{},
		Count:   0,
		IsError: false,
	}, nil
}

// getSingleEntity retrieves a single entity by ID
func (s *EntityService) getSingleEntity(ctx context.Context, entity, id string, params EntityGetParams) (*APIResponse, error) {
	// Get the entity from the database using sqlc
	entityData, err := s.getEntityByID(ctx, entity, id)
	if err != nil {
		return s.errorResponse("Entity not found", "NOT_FOUND"), nil
	}

	// Apply field selection if specified
	if params.Select != nil && *params.Select != "" {
		entityData = s.selectFields(entityData, *params.Select)
	}

	return &APIResponse{
		Values:  []map[string]interface{}{entityData},
		Count:   1,
		IsError: false,
	}, nil
}

// getMultipleEntities retrieves multiple entities based on criteria
func (s *EntityService) getMultipleEntities(ctx context.Context, entity string, params EntityGetParams) (*APIResponse, error) {
	// Build query parameters
	queryParams := s.buildQueryParams(params)

	// Get entities from the database using sqlc
	entities, err := s.getEntities(ctx, entity, queryParams)
	if err != nil {
		s.logger.Error("Failed to get entities", "entity", entity, "error", err)
		return s.errorResponse("Failed to retrieve entities: "+err.Error(), "QUERY_FAILED"), nil
	}

	// Apply field selection if specified
	if params.Select != nil && *params.Select != "" {
		for i, entity := range entities {
			entities[i] = s.selectFields(entity, *params.Select)
		}
	}

	return &APIResponse{
		Values:  entities,
		Count:   len(entities),
		IsError: false,
	}, nil
}

// createEntity creates a new entity
func (s *EntityService) createEntity(ctx context.Context, entity string, values map[string]interface{}) (map[string]interface{}, error) {
	// Add audit fields
	values["created_at"] = "NOW()"
	values["updated_at"] = "NOW()"

	// Create the entity in the database using sqlc
	createdID, err := s.createEntityInDB(ctx, entity, values)
	if err != nil {
		return nil, err
	}

	// Retrieve the created entity
	createdEntity, err := s.getEntityByID(ctx, entity, createdID)
	if err != nil {
		return nil, err
	}

	return createdEntity, nil
}

// updateEntity updates an existing entity
func (s *EntityService) updateEntity(ctx context.Context, entity, id string, values map[string]interface{}) (map[string]interface{}, error) {
	// Add audit fields
	values["updated_at"] = "NOW()"

	// Update the entity in the database
	if err := s.db.UpdateEntity(ctx, entity, id, values); err != nil {
		return nil, err
	}

	// Retrieve the updated entity
	updatedEntity, err := s.db.GetEntityByID(ctx, entity, id)
	if err != nil {
		return nil, err
	}

	return updatedEntity, nil
}

// deleteEntity deletes an entity
func (s *EntityService) deleteEntity(ctx context.Context, entity, id string) error {
	return s.db.DeleteEntity(ctx, entity, id)
}

// buildQueryParams builds database query parameters from API parameters
func (s *EntityService) buildQueryParams(params EntityGetParams) map[string]interface{} {
	queryParams := make(map[string]interface{})

	if params.Where != nil && *params.Where != "" {
		var whereClause map[string]interface{}
		if err := json.Unmarshal([]byte(*params.Where), &whereClause); err == nil {
			queryParams["where"] = whereClause
		}
	}

	if params.OrderBy != nil && *params.OrderBy != "" {
		var orderBy []map[string]interface{}
		if err := json.Unmarshal([]byte(*params.OrderBy), &orderBy); err == nil {
			queryParams["orderBy"] = orderBy
		}
	}

	if params.Limit != nil {
		queryParams["limit"] = *params.Limit
	}

	if params.Offset != nil {
		queryParams["offset"] = *params.Offset
	}

	if params.Join != nil && *params.Join != "" {
		var joins []map[string]interface{}
		if err := json.Unmarshal([]byte(*params.Join), &joins); err == nil {
			queryParams["join"] = joins
		}
	}

	if params.GroupBy != nil && *params.GroupBy != "" {
		queryParams["groupBy"] = strings.Split(*params.GroupBy, ",")
	}

	if params.Having != nil && *params.Having != "" {
		var havingClause map[string]interface{}
		if err := json.Unmarshal([]byte(*params.Having), &havingClause); err == nil {
			queryParams["having"] = havingClause
		}
	}

	return queryParams
}

// selectFields applies field selection to entity data
func (s *EntityService) selectFields(entity map[string]interface{}, selectFields string) map[string]interface{} {
	fields := strings.Split(selectFields, ",")
	selected := make(map[string]interface{})

	for _, field := range fields {
		field = strings.TrimSpace(field)
		if value, exists := entity[field]; exists {
			selected[field] = value
		}
	}

	return selected
}

// isValidEntity checks if the entity type is valid
func (s *EntityService) isValidEntity(entity string) bool {
	validEntities := map[string]bool{
		"Contact":      true,
		"Contribution": true,
		"Event":        true,
		"Participant":  true,
		"Membership":   true,
		"Activity":     true,
		"Case":         true,
		"Campaign":     true,
		"Survey":       true,
		"Report":       true,
		"CustomField":  true,
		"CustomGroup":  true,
		"Mailing":      true,
		"Pledge":       true,
		"User":         true,
		"Setting":      true,
		"Domain":       true,
	}

	return validEntities[entity]
}

// checkPermissions checks if the current user has permission for the operation
func (s *EntityService) checkPermissions(ctx context.Context, entity, operation string) error {
	// TODO: Implement permission checking using the ACL system
	// For now, allow all operations
	return nil
}

// validateRequiredFields validates that required fields are present
func (s *EntityService) validateRequiredFields(entity string, values map[string]interface{}) error {
	// TODO: Implement field validation based on entity schema
	// For now, just check if values are provided
	if len(values) == 0 {
		return fmt.Errorf("no values provided")
	}
	return nil
}

// errorResponse creates a standardized error response
func (s *EntityService) errorResponse(message, code string) *APIResponse {
	return &APIResponse{
		Values:       []map[string]interface{}{},
		Count:        0,
		IsError:      true,
		ErrorMessage: &message,
		ErrorCode:    &code,
	}
}
