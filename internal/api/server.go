package api

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jxlxx/civicrm/internal/cache"
	"github.com/jxlxx/civicrm/internal/config"
	"github.com/jxlxx/civicrm/internal/database"
	"github.com/jxlxx/civicrm/internal/extensions"
	"github.com/jxlxx/civicrm/internal/logger"
	"github.com/jxlxx/civicrm/internal/security"
)

// Server represents the API server
type Server struct {
	config     *config.APIConfig
	logger     *logger.Logger
	db         *database.Database
	cache      *cache.Manager
	security   *security.Manager
	extensions *extensions.Manager
	router     *gin.Engine
	server     *http.Server
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

	if err := server.setupRouter(); err != nil {
		return nil, fmt.Errorf("failed to setup router: %w", err)
	}

	return server, nil
}

// setupRouter configures the HTTP router
func (s *Server) setupRouter() error {
	gin.SetMode(gin.ReleaseMode)
	s.router = gin.New()

	// Middleware
	s.router.Use(gin.Recovery())
	s.router.Use(s.loggingMiddleware())
	s.router.Use(s.corsMiddleware())
	s.router.Use(s.securityMiddleware())

	// Health check
	s.router.GET("/health", s.healthHandler)

	// API v4 routes
	apiV4 := s.router.Group("/api/v4")
	{
		apiV4.GET("/", s.apiInfoHandler)
		apiV4.POST("/:entity/:action", s.apiHandler)
		apiV4.GET("/:entity/:action", s.apiHandler)
		apiV4.PUT("/:entity/:action", s.apiHandler)
		apiV4.DELETE("/:entity/:action", s.apiHandler)
	}

	// GraphQL endpoint
	s.router.POST("/graphql", s.graphqlHandler)
	s.router.GET("/graphql", s.graphqlPlaygroundHandler)

	// Extension routes
	s.router.GET("/extensions", s.extensionsHandler)

	// Create HTTP server
	s.server = &http.Server{
		Addr:         fmt.Sprintf("%s:%d", s.config.Host, s.config.Port),
		Handler:      s.router,
		ReadTimeout:  s.config.ReadTimeout,
		WriteTimeout: s.config.WriteTimeout,
		IdleTimeout:  s.config.IdleTimeout,
	}

	return nil
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

// Stop stops the API server
func (s *Server) Stop() error {
	s.logger.Info("Stopping API server")

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	return s.server.Shutdown(ctx)
}

// loggingMiddleware adds logging to requests
func (s *Server) loggingMiddleware() gin.HandlerFunc {
	return gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		s.logger.Info("HTTP Request",
			"method", param.Method,
			"path", param.Path,
			"status", param.StatusCode,
			"latency", param.Latency,
			"client_ip", param.ClientIP,
		)
		return ""
	})
}

// corsMiddleware handles CORS
func (s *Server) corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "*")
		c.Header("Access-Control-Allow-Credentials", "true")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

// securityMiddleware handles authentication and authorization
func (s *Server) securityMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Skip security for health check and public endpoints
		if c.Request.URL.Path == "/health" || c.Request.URL.Path == "/graphql" {
			c.Next()
			return
		}

		// Extract token from Authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}

		// Validate token
		token := authHeader[7:] // Remove "Bearer " prefix
		user, err := s.security.ValidateToken(token)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
			return
		}

		// Add user to context
		c.Set("user", user)
		c.Next()
	}
}

// healthHandler handles health check requests
func (s *Server) healthHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":    "healthy",
		"timestamp": time.Now().UTC(),
		"version":   "1.0.0",
	})
}

// apiInfoHandler provides API information
func (s *Server) apiInfoHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"name":        "CiviCRM API v4",
		"version":     "1.0.0",
		"description": "CiviCRM API v4 implementation in Go",
		"endpoints": gin.H{
			"entities": []string{"Contact", "Event", "Contribution", "Activity"},
			"actions":  []string{"get", "create", "update", "delete"},
		},
	})
}

// apiHandler handles API v4 requests
func (s *Server) apiHandler(c *gin.Context) {
	entity := c.Param("entity")
	action := c.Param("action")

	// Get user from context
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "User not found in context"})
		return
	}

	// Check permissions
	if !s.security.CheckPermission(c.Request.Context(), user.(*security.User), entity, action) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Insufficient permissions"})
		return
	}

	// Parse request body
	var params map[string]interface{}
	if err := c.ShouldBindJSON(&params); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	// Execute API call
	result, err := s.executeAPI(c.Request.Context(), entity, action, params)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}

// executeAPI executes an API call
func (s *Server) executeAPI(ctx context.Context, entity, action string, params map[string]interface{}) (interface{}, error) {
	// Check if this is handled by an extension
	if apiService, exists := s.extensions.GetAPIService(entity); exists {
		return apiService.Execute(ctx, action, params)
	}

	// Default API handling would go here
	// For now, return a placeholder response
	return gin.H{
		"entity":  entity,
		"action":  action,
		"params":  params,
		"message": "API call executed successfully",
	}, nil
}

// graphqlHandler handles GraphQL requests
func (s *Server) graphqlHandler(c *gin.Context) {
	// GraphQL implementation would go here
	c.JSON(http.StatusOK, gin.H{
		"message": "GraphQL endpoint - implementation pending",
	})
}

// graphqlPlaygroundHandler serves GraphQL playground
func (s *Server) graphqlPlaygroundHandler(c *gin.Context) {
	// GraphQL playground implementation would go here
	c.JSON(http.StatusOK, gin.H{
		"message": "GraphQL playground - implementation pending",
	})
}

// extensionsHandler lists available extensions
func (s *Server) extensionsHandler(c *gin.Context) {
	extensions := s.extensions.ListExtensions()
	apis := s.extensions.ListAPIServices()

	c.JSON(http.StatusOK, gin.H{
		"extensions": extensions,
		"apis":       apis,
	})
}
