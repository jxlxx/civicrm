package extensions

import (
	"context"
	"fmt"
	"sync"

	"github.com/jxlxx/civicrm/internal/config"
	"github.com/jxlxx/civicrm/internal/logger"
)

// Extension represents a CiviCRM extension
type Extension interface {
	Name() string
	Version() string
	Initialize(ctx context.Context) error
	RegisterHooks() []Hook
	RegisterAPIs() []APIService
	Start(ctx context.Context) error
	Stop(ctx context.Context) error
}

// Hook represents an extension hook point
type Hook struct {
	Name     string
	Priority int
	Handler  func(ctx context.Context, data interface{}) (interface{}, error)
}

// APIService represents an API service provided by an extension
type APIService interface {
	Name() string
	Version() string
	Methods() []string
	Execute(ctx context.Context, method string, params map[string]interface{}) (interface{}, error)
}

// Manager manages all extensions
type Manager struct {
	config     *config.ExtensionsConfig
	logger     *logger.Logger
	extensions map[string]Extension
	hooks      map[string][]Hook
	apis       map[string]APIService
	mutex      sync.RWMutex
	ctx        context.Context
	cancel     context.CancelFunc
}

// New creates a new extension manager
func New(config *config.ExtensionsConfig, logger *logger.Logger) (*Manager, error) {
	ctx, cancel := context.WithCancel(context.Background())

	manager := &Manager{
		config:     config,
		logger:     logger,
		extensions: make(map[string]Extension),
		hooks:      make(map[string][]Hook),
		apis:       make(map[string]APIService),
		ctx:        ctx,
		cancel:     cancel,
	}

	if config.AutoLoad {
		if err := manager.loadExtensions(); err != nil {
			return nil, fmt.Errorf("failed to load extensions: %w", err)
		}
	}

	return manager, nil
}

// Start starts all extensions
func (m *Manager) Start() error {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	for name, extension := range m.extensions {
		if err := extension.Start(m.ctx); err != nil {
			m.logger.Error("Failed to start extension", "extension", name, "error", err)
			continue
		}
		m.logger.Info("Extension started", "extension", name)
	}

	return nil
}

// Stop stops all extensions
func (m *Manager) Stop() error {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	for name, extension := range m.extensions {
		if err := extension.Stop(m.ctx); err != nil {
			m.logger.Error("Failed to stop extension", "extension", name, "error", err)
			continue
		}
		m.logger.Info("Extension stopped", "extension", name)
	}

	m.cancel()
	return nil
}

// RegisterExtension registers a new extension
func (m *Manager) RegisterExtension(extension Extension) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	name := extension.Name()

	// Check if extension is disabled
	for _, disabled := range m.config.Disabled {
		if disabled == name {
			return fmt.Errorf("extension %s is disabled", name)
		}
	}

	// Initialize extension
	if err := extension.Initialize(m.ctx); err != nil {
		return fmt.Errorf("failed to initialize extension %s: %w", name, err)
	}

	// Register hooks
	for _, hook := range extension.RegisterHooks() {
		m.hooks[hook.Name] = append(m.hooks[hook.Name], hook)
	}

	// Register APIs
	for _, api := range extension.RegisterAPIs() {
		m.apis[api.Name()] = api
	}

	m.extensions[name] = extension
	m.logger.Info("Extension registered", "extension", name)

	return nil
}

// UnregisterExtension unregisters an extension
func (m *Manager) UnregisterExtension(name string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	extension, exists := m.extensions[name]
	if !exists {
		return fmt.Errorf("extension %s not found", name)
	}

	// Stop extension
	if err := extension.Stop(m.ctx); err != nil {
		m.logger.Error("Failed to stop extension during unregistration", "extension", name, "error", err)
	}

	// Remove hooks
	for _, hook := range extension.RegisterHooks() {
		if hooks, exists := m.hooks[hook.Name]; exists {
			for i, h := range hooks {
				// Compare hook names instead of function pointers
				if h.Name == hook.Name {
					m.hooks[hook.Name] = append(hooks[:i], hooks[i+1:]...)
					break
				}
			}
		}
	}

	// Remove APIs
	for _, api := range extension.RegisterAPIs() {
		delete(m.apis, api.Name())
	}

	delete(m.extensions, name)
	m.logger.Info("Extension unregistered", "extension", name)

	return nil
}

// GetExtension returns an extension by name
func (m *Manager) GetExtension(name string) (Extension, bool) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	extension, exists := m.extensions[name]
	return extension, exists
}

// ListExtensions returns all registered extensions
func (m *Manager) ListExtensions() []string {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	names := make([]string, 0, len(m.extensions))
	for name := range m.extensions {
		names = append(names, name)
	}
	return names
}

// ExecuteHook executes a hook with the given data
func (m *Manager) ExecuteHook(ctx context.Context, hookName string, data interface{}) (interface{}, error) {
	m.mutex.RLock()
	hooks, exists := m.hooks[hookName]
	m.mutex.RUnlock()

	if !exists {
		return data, nil
	}

	// Execute hooks in priority order
	result := data
	for _, hook := range hooks {
		if hookResult, err := hook.Handler(ctx, result); err != nil {
			m.logger.Error("Hook execution failed", "hook", hookName, "extension", hook.Name, "error", err)
			continue
		} else {
			result = hookResult
		}
	}

	return result, nil
}

// GetAPIService returns an API service by name
func (m *Manager) GetAPIService(name string) (APIService, bool) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	api, exists := m.apis[name]
	return api, exists
}

// ListAPIServices returns all registered API services
func (m *Manager) ListAPIServices() []string {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	names := make([]string, 0, len(m.apis))
	for name := range m.apis {
		names = append(names, name)
	}
	return names
}

// loadExtensions loads extensions from the configured path
func (m *Manager) loadExtensions() error {
	// In a real implementation, this would scan the extensions directory
	// and dynamically load extension modules
	// For now, this is a placeholder
	return nil
}
