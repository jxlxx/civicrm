package core

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/jxlxx/civicrm/pkg/api"
	"github.com/jxlxx/civicrm/pkg/cache"
	"github.com/jxlxx/civicrm/pkg/config"
	"github.com/jxlxx/civicrm/pkg/database"
	"github.com/jxlxx/civicrm/pkg/extensions"
	"github.com/jxlxx/civicrm/pkg/logger"
	"github.com/jxlxx/civicrm/pkg/security"
	"go.uber.org/zap"
)

// App represents the main CiviCRM application
type App struct {
	Config     *config.Config
	Logger     *logger.Logger
	DB         *database.Database
	Cache      *cache.Manager
	Security   *security.Manager
	Extensions *extensions.Manager
	API        *api.Server
	ctx        context.Context
	cancel     context.CancelFunc
}

// NewApp creates a new CiviCRM application instance
func NewApp() (*App, error) {
	ctx, cancel := context.WithCancel(context.Background())

	app := &App{
		ctx:    ctx,
		cancel: cancel,
	}

	if err := app.initialize(); err != nil {
		return nil, fmt.Errorf("failed to initialize app: %w", err)
	}

	return app, nil
}

// initialize sets up all application components
func (app *App) initialize() error {
	var err error

	// Load configuration
	if app.Config, err = config.Load(); err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	// Initialize logger
	if app.Logger, err = logger.New(app.Config.Logging); err != nil {
		return fmt.Errorf("failed to initialize logger: %w", err)
	}

	// Initialize database
	if app.DB, err = database.New(app.Config.Database); err != nil {
		return fmt.Errorf("failed to initialize database: %w", err)
	}

	// Initialize cache
	if app.Cache, err = cache.New(app.Config.Cache); err != nil {
		return fmt.Errorf("failed to initialize cache: %w", err)
	}

	// Initialize security manager
	if app.Security, err = security.New(app.Config.Security); err != nil {
		return fmt.Errorf("failed to initialize security: %w", err)
	}

	// Initialize extension manager
	if app.Extensions, err = extensions.New(app.Config.Extensions, app.Logger); err != nil {
		return fmt.Errorf("failed to initialize extensions: %w", err)
	}

	// Initialize API server
	if app.API, err = api.New(app.Config.API, app.Logger, app.DB, app.Cache, app.Security, app.Extensions); err != nil {
		return fmt.Errorf("failed to initialize API: %w", err)
	}

	app.Logger.Info("Application initialized successfully")
	return nil
}

// Start begins the application lifecycle
func (app *App) Start() error {
	app.Logger.Info("Starting CiviCRM application")

	// Start extension manager
	if err := app.Extensions.Start(); err != nil {
		return fmt.Errorf("failed to start extensions: %w", err)
	}

	// Start API server
	if err := app.API.Start(); err != nil {
		return fmt.Errorf("failed to start API: %w", err)
	}

	app.Logger.Info("CiviCRM application started successfully")
	return nil
}

// Stop gracefully shuts down the application
func (app *App) Stop() error {
	app.Logger.Info("Stopping CiviCRM application")

	// Stop API server
	if err := app.API.Stop(); err != nil {
		app.Logger.Error("Failed to stop API server", zap.Error(err))
	}

	// Stop extension manager
	if err := app.Extensions.Stop(); err != nil {
		app.Logger.Error("Failed to stop extensions", zap.Error(err))
	}

	// Close database connections
	if err := app.DB.Close(); err != nil {
		app.Logger.Error("Failed to close database", zap.Error(err))
	}

	// Close cache connections
	if err := app.Cache.Close(); err != nil {
		app.Logger.Error("Failed to close cache", zap.Error(err))
	}

	app.cancel()
	app.Logger.Info("CiviCRM application stopped")
	return nil
}

// Run starts the application and waits for shutdown signals
func (app *App) Run() error {
	if err := app.Start(); err != nil {
		return err
	}

	// Wait for shutdown signal
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	<-sigChan

	return app.Stop()
}

// Context returns the application context
func (app *App) Context() context.Context {
	return app.ctx
}

// GetService retrieves a service from the application
func (app *App) GetService(name string) (interface{}, bool) {
	// This would be implemented with a proper service container
	// For now, return nil
	return nil, false
}
