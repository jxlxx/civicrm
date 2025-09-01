package core

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/jxlxx/civicrm/internal/api"
	"github.com/jxlxx/civicrm/internal/cache"
	"github.com/jxlxx/civicrm/internal/config"
	"github.com/jxlxx/civicrm/internal/database"
	"github.com/jxlxx/civicrm/internal/extensions"
	"github.com/jxlxx/civicrm/internal/logger"
	"github.com/jxlxx/civicrm/internal/security"
)

// App represents the main CiviCRM application
type App struct {
	Config     *config.Config
	Container  *Container
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
		ctx:       ctx,
		cancel:    cancel,
		Container: NewContainer(),
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
	if app.Logger, err = logger.New(&app.Config.Logging); err != nil {
		return fmt.Errorf("failed to initialize logger: %w", err)
	}

	// Initialize database
	if app.DB, err = database.New(&app.Config.Database); err != nil {
		return fmt.Errorf("failed to initialize database: %w", err)
	}

	// Initialize cache
	if app.Cache, err = cache.New(&app.Config.Cache); err != nil {
		return fmt.Errorf("failed to initialize cache: %w", err)
	}

	// Initialize security manager
	if app.Security, err = security.New(&app.Config.Security); err != nil {
		return fmt.Errorf("failed to initialize security: %w", err)
	}

	// Initialize extension manager
	if app.Extensions, err = extensions.New(&app.Config.Extensions, app.Logger); err != nil {
		return fmt.Errorf("failed to initialize extensions: %w", err)
	}

	// Initialize API server
	if app.API, err = api.New(&app.Config.API, app.Logger, app.DB, app.Cache, app.Security, app.Extensions); err != nil {
		return fmt.Errorf("failed to initialize API: %w", err)
	}

	// Register services in the container
	app.registerServices()

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
func (app *App) Stop(ctx context.Context) error {
	app.Logger.Info("Stopping CiviCRM application")

	// Stop API server
	if err := app.API.Stop(ctx); err != nil {
		app.Logger.Error("Failed to stop API server", "error", err)
	}

	// Stop extension manager
	if err := app.Extensions.Stop(); err != nil {
		app.Logger.Error("Failed to stop extensions", "error", err)
	}

	// Close database connections
	if err := app.DB.Close(); err != nil {
		app.Logger.Error("Failed to close database", "error", err)
	}

	// Close cache connections
	if err := app.Cache.Close(); err != nil {
		app.Logger.Error("Failed to close cache", "error", err)
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

	return app.Stop(app.ctx)
}

// Context returns the application context
func (app *App) Context() context.Context {
	return app.ctx
}

// registerServices registers all services in the dependency injection container
func (app *App) registerServices() {
	// Register core services as singletons
	app.Container.RegisterInstance((*config.Config)(nil), app.Config)
	app.Container.RegisterInstance((*logger.Logger)(nil), app.Logger)
	app.Container.RegisterInstance((*database.Database)(nil), app.DB)
	app.Container.RegisterInstance((*cache.Manager)(nil), app.Cache)
	app.Container.RegisterInstance((*security.Manager)(nil), app.Security)
	app.Container.RegisterInstance((*extensions.Manager)(nil), app.Extensions)
	app.Container.RegisterInstance((*api.Server)(nil), app.API)
}

// GetService retrieves a service from the application
func (app *App) GetService(serviceType interface{}) (interface{}, error) {
	return app.Container.Get(serviceType)
}
