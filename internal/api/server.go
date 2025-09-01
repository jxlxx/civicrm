package api

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/jxlxx/civicrm/internal/cache"
	"github.com/jxlxx/civicrm/internal/config"
	"github.com/jxlxx/civicrm/internal/database"
	"github.com/jxlxx/civicrm/internal/extensions"
	"github.com/jxlxx/civicrm/internal/logger"
	"github.com/jxlxx/civicrm/internal/security"
)

// Server represents the API server using standard library HTTP
type Server struct {
	config     *config.APIConfig
	logger     *logger.Logger
	db         *database.Database
	cache      *cache.Manager
	security   *security.Manager
	extensions *extensions.Manager
	server     *http.Server
	handler    http.Handler
}

// New creates a new API server
func New(config *config.APIConfig, logger *logger.Logger, db *database.Database, cache *cache.Manager, security *security.Manager, extensions *extensions.Manager) (*Server, error) {
	server := &Server{
		config:     config,
		logger:     logger,
		db:         db,
		cache:      cache,
		security:   security,
		extensions: extensions,
	}

	// Create the server implementation
	impl := &ServerImpl{
		server: server,
	}

	// Create the HTTP handler using generated code
	server.handler = Handler(impl)

	// Add middleware
	server.handler = server.addMiddleware(server.handler)

	// Create HTTP server
	server.server = &http.Server{
		Addr:         fmt.Sprintf("%s:%d", config.Host, config.Port),
		Handler:      server.handler,
		ReadTimeout:  config.ReadTimeout,
		WriteTimeout: config.WriteTimeout,
		IdleTimeout:  config.IdleTimeout,
	}

	return server, nil
}

// addMiddleware adds standard middleware to the HTTP handler
func (s *Server) addMiddleware(handler http.Handler) http.Handler {
	// Logging middleware
	handler = s.loggingMiddleware(handler)

	// CORS middleware
	handler = s.corsMiddleware(handler)

	// Security middleware
	handler = s.securityMiddleware(handler)

	return handler
}

// loggingMiddleware adds logging to all requests
func (s *Server) loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		// Create a response writer wrapper to capture status code
		wrapped := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}

		next.ServeHTTP(wrapped, r)

		duration := time.Since(start)
		s.logger.Info("HTTP request",
			"method", r.Method,
			"path", r.URL.Path,
			"status", wrapped.statusCode,
			"duration", duration,
			"user_agent", r.UserAgent(),
		)
	})
}

// corsMiddleware adds CORS headers
func (s *Server) corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.Header().Set("Access-Control-Allow-Origin", "*")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
			w.Header().Set("Access-Control-Max-Age", "86400")
			w.WriteHeader(http.StatusOK)
			return
		}

		// Add CORS headers to all responses
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		next.ServeHTTP(w, r)
	})
}

// securityMiddleware adds basic security headers
func (s *Server) securityMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Add security headers
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("X-Frame-Options", "DENY")
		w.Header().Set("X-XSS-Protection", "1; mode=block")

		next.ServeHTTP(w, r)
	})
}

// Start starts the API server
func (s *Server) Start() error {
	s.logger.Info("Starting API server", "address", s.server.Addr)

	go func() {
		if err := s.server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			s.logger.Error("API server failed", "error", err)
		}
	}()

	return nil
}

// Stop gracefully stops the API server
func (s *Server) Stop(ctx context.Context) error {
	s.logger.Info("Stopping API server")
	return s.server.Shutdown(ctx)
}

// responseWriter wraps http.ResponseWriter to capture status code
type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

// ServerImpl implements the generated ServerInterface
type ServerImpl struct {
	server *Server
}

// ApiInfo returns API information
func (s *ServerImpl) ApiInfo(w http.ResponseWriter, r *http.Request) {
	info := APIInfo{
		Version:     ptr("4.0.0"),
		Name:        ptr("CiviCRM API v4"),
		Description: ptr("CiviCRM REST API v4"),
		Entities:    &[]string{"Contact", "Contribution", "Event", "Membership"},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(info)
}

// ListExtensions returns list of loaded extensions
func (s *ServerImpl) ListExtensions(w http.ResponseWriter, r *http.Request) {
	// For now, return empty list - will be implemented when extensions are loaded
	extensions := []Extension{}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(extensions)
}

// HealthCheck returns health status
func (s *ServerImpl) HealthCheck(w http.ResponseWriter, r *http.Request) {
	status := "healthy"
	if s.server.db == nil {
		status = "unhealthy"
	}

	health := HealthResponse{
		Status:    (*HealthResponseStatus)(&status),
		Timestamp: ptr(time.Now()),
		Version:   ptr("4.0.0"),
		Uptime:    ptr("0s"), // TODO: implement uptime tracking
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(health)
}

// EntityDelete handles entity deletion
func (s *ServerImpl) EntityDelete(w http.ResponseWriter, r *http.Request, entity string, action string, params EntityDeleteParams) {
	// TODO: Implement entity deletion logic
	response := APIResponse{
		IsError: ptr(false),
		Values:  &[]map[string]interface{}{},
		Count:   ptr(0),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

// EntityGet handles entity retrieval
func (s *ServerImpl) EntityGet(w http.ResponseWriter, r *http.Request, entity string, action string, params EntityGetParams) {
	// TODO: Implement entity retrieval logic
	response := APIResponse{
		IsError: ptr(false),
		Values:  &[]map[string]interface{}{},
		Count:   ptr(0),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

// EntityCreate handles entity creation
func (s *ServerImpl) EntityCreate(w http.ResponseWriter, r *http.Request, entity string, action string) {
	// TODO: Implement entity creation logic
	response := APIResponse{
		IsError: ptr(false),
		Values:  &[]map[string]interface{}{},
		Count:   ptr(0),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

// EntityUpdate handles entity updates
func (s *ServerImpl) EntityUpdate(w http.ResponseWriter, r *http.Request, entity string, action string, params EntityUpdateParams) {
	// TODO: Implement entity update logic
	response := APIResponse{
		IsError: ptr(false),
		Values:  &[]map[string]interface{}{},
		Count:   ptr(0),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

// Helper function for creating pointers to any type
func ptr[T any](v T) *T { return &v }
