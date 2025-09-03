package api

import (
	"context"
	"embed"
	"encoding/json"
	"fmt"
	"io/fs"
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"github.com/jxlxx/civicrm/internal/cache"
	"github.com/jxlxx/civicrm/internal/config"
	"github.com/jxlxx/civicrm/internal/database"
	"github.com/jxlxx/civicrm/internal/extensions"
	"github.com/jxlxx/civicrm/internal/logger"
	"github.com/jxlxx/civicrm/internal/security"
)

//go:embed static/*
var staticFiles embed.FS

// getStaticFS returns the embedded file system for static assets
func getStaticFS() http.FileSystem {
	// Create a sub-filesystem for the static directory
	staticFS, err := fs.Sub(staticFiles, "static")
	if err != nil {
		// If there's an error, return an empty filesystem
		return http.FS(staticFiles)
	}
	return http.FS(staticFS)
}

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

	// Create the HTTP handler using generated code with correct base URL
	server.handler = HandlerWithOptions(server, StdHTTPServerOptions{
		BaseURL: "/api/v4",
	})

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

// ApiInfo returns API information
func (s *Server) ApiInfo(w http.ResponseWriter, r *http.Request) {
	info := APIInfo{
		Version:     ptr("4.0.0"),
		Name:        ptr("CiviCRM API v4"),
		Description: ptr("CiviCRM REST API v4"),
		Entities:    &[]string{"Contact", "Contribution", "Event", "Membership"},
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(info); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// OpenAPISpec returns the OpenAPI specification as JSON
func (s *Server) OpenAPISpec(w http.ResponseWriter, r *http.Request) {
	// Get the embedded OpenAPI specification
	spec, err := GetSwagger()
	if err != nil {
		s.logger.Error("Failed to get OpenAPI spec", "error", err)
		http.Error(w, "Failed to load OpenAPI specification", http.StatusInternalServerError)
		return
	}

	// Set appropriate headers
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Header().Set("Cache-Control", "public, max-age=3600")

	// Encode and send the specification as JSON
	if err := json.NewEncoder(w).Encode(spec); err != nil {
		s.logger.Error("Failed to encode OpenAPI spec", "error", err)
		http.Error(w, "Failed to encode OpenAPI specification", http.StatusInternalServerError)
		return
	}
}

// ListExtensions returns list of loaded extensions
func (s *Server) ListExtensions(w http.ResponseWriter, r *http.Request) {
	// For now, return empty list - will be implemented when extensions are loaded
	extensions := []Extension{}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(extensions); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// HealthCheck returns health status
func (s *Server) HealthCheck(w http.ResponseWriter, r *http.Request) {
	status := "healthy"
	if s.db == nil {
		status = "unhealthy"
	}

	health := HealthResponse{
		Status:    (*HealthResponseStatus)(&status),
		Timestamp: ptr(time.Now()),
		Version:   ptr("4.0.0"),
		Uptime:    ptr("0s"), // TODO: implement uptime tracking
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(health); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// EntityDelete handles entity deletion
func (s *Server) EntityDelete(w http.ResponseWriter, r *http.Request, entity string, action string, params EntityDeleteParams) {
	// TODO: Implement entity deletion logic
	response := APIResponse{
		IsError: ptr(false),
		Values:  &[]map[string]interface{}{},
		Count:   ptr(0),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// EntityGet handles entity retrieval
func (s *Server) EntityGet(w http.ResponseWriter, r *http.Request, entity string, action string, params EntityGetParams) {
	// TODO: Implement entity retrieval logic
	response := APIResponse{
		IsError: ptr(false),
		Values:  &[]map[string]interface{}{},
		Count:   ptr(0),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// EntityCreate handles entity creation
func (s *Server) EntityCreate(w http.ResponseWriter, r *http.Request, entity string, action string) {
	// TODO: Implement entity creation logic
	response := APIResponse{
		IsError: ptr(false),
		Values:  &[]map[string]interface{}{},
		Count:   ptr(0),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// EntityUpdate handles entity updates
func (s *Server) EntityUpdate(w http.ResponseWriter, r *http.Request, entity string, action string, params EntityUpdateParams) {
	// TODO: Implement entity update logic
	response := APIResponse{
		IsError: ptr(false),
		Values:  &[]map[string]interface{}{},
		Count:   ptr(0),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

// ServeStatic handles serving static files from the embedded file system
func (s *Server) ServeStatic(w http.ResponseWriter, r *http.Request, path string) {
	// Clean the path to prevent directory traversal
	path = filepath.Clean(path)
	if strings.Contains(path, "..") {
		http.Error(w, "Invalid path", http.StatusBadRequest)
		return
	}

	// Get the embedded file system
	staticFS := getStaticFS()

	// Try to open the file
	file, err := staticFS.Open(path)
	if err != nil {
		http.NotFound(w, r)
		return
	}
	defer file.Close()

	// Get file info to determine content type
	info, err := file.Stat()
	if err != nil {
		http.NotFound(w, r)
		return
	}

	// Set appropriate content type based on file extension
	ext := strings.ToLower(filepath.Ext(path))
	switch ext {
	case ".html":
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
	case ".css":
		w.Header().Set("Content-Type", "text/css; charset=utf-8")
	case ".js":
		w.Header().Set("Content-Type", "application/javascript; charset=utf-8")
	case ".png":
		w.Header().Set("Content-Type", "image/png")
	case ".jpg", ".jpeg":
		w.Header().Set("Content-Type", "image/jpeg")
	case ".gif":
		w.Header().Set("Content-Type", "image/gif")
	case ".svg":
		w.Header().Set("Content-Type", "image/svg+xml")
	case ".ico":
		w.Header().Set("Content-Type", "image/x-icon")
	case ".json":
		w.Header().Set("Content-Type", "application/json")
	case ".xml":
		w.Header().Set("Content-Type", "application/xml")
	case ".yaml", ".yml":
		w.Header().Set("Content-Type", "application/x-yaml")
	default:
		w.Header().Set("Content-Type", "application/octet-stream")
	}

	// Set cache headers for static assets
	w.Header().Set("Cache-Control", "public, max-age=3600")

	// Serve the file
	http.ServeContent(w, r, info.Name(), info.ModTime(), file)
}

// Helper function for creating pointers to any type
func ptr[T any](v T) *T { return &v }
