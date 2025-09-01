package core

import (
	"fmt"
	"reflect"
	"sync"
)

// ServiceLifetime defines how long a service instance lives
type ServiceLifetime int

const (
	// Transient - New instance created every time
	Transient ServiceLifetime = iota
	// Singleton - Single instance shared across the application
	Singleton
	// Scoped - Instance per request/scope
	Scoped
)

// ServiceDescriptor describes how to create a service
type ServiceDescriptor struct {
	ServiceType    reflect.Type
	Implementation reflect.Type
	Factory        interface{}
	Lifetime       ServiceLifetime
	Instance       interface{}
	mu             sync.RWMutex
}

// Container manages service registration and resolution
type Container struct {
	services map[string]*ServiceDescriptor
	mu       sync.RWMutex
}

// NewContainer creates a new dependency injection container
func NewContainer() *Container {
	return &Container{
		services: make(map[string]*ServiceDescriptor),
	}
}

// Register registers a service with the container
func (c *Container) Register(serviceType interface{}, implementation interface{}, lifetime ServiceLifetime) {
	c.mu.Lock()
	defer c.mu.Unlock()

	serviceName := reflect.TypeOf(serviceType).String()

	c.services[serviceName] = &ServiceDescriptor{
		ServiceType:    reflect.TypeOf(serviceType),
		Implementation: reflect.TypeOf(implementation),
		Lifetime:       lifetime,
	}
}

// RegisterFactory registers a service using a factory function
func (c *Container) RegisterFactory(serviceType interface{}, factory interface{}, lifetime ServiceLifetime) {
	c.mu.Lock()
	defer c.mu.Unlock()

	serviceName := reflect.TypeOf(serviceType).String()

	c.services[serviceName] = &ServiceDescriptor{
		ServiceType: reflect.TypeOf(serviceType),
		Factory:     factory,
		Lifetime:    lifetime,
	}
}

// RegisterInstance registers an existing instance as a singleton
func (c *Container) RegisterInstance(serviceType interface{}, instance interface{}) {
	c.mu.Lock()
	defer c.mu.Unlock()

	serviceName := reflect.TypeOf(serviceType).String()

	c.services[serviceName] = &ServiceDescriptor{
		ServiceType: reflect.TypeOf(serviceType),
		Instance:    instance,
		Lifetime:    Singleton,
	}
}

// Get retrieves a service from the container
func (c *Container) Get(serviceType interface{}) (interface{}, error) {
	serviceName := reflect.TypeOf(serviceType).String()

	c.mu.RLock()
	descriptor, exists := c.services[serviceName]
	c.mu.RUnlock()

	if !exists {
		return nil, fmt.Errorf("service %s not registered", serviceName)
	}

	descriptor.mu.Lock()
	defer descriptor.mu.Unlock()

	// Return existing instance for singletons
	if descriptor.Lifetime == Singleton && descriptor.Instance != nil {
		return descriptor.Instance, nil
	}

	// Create new instance
	instance, err := c.createInstance(descriptor)
	if err != nil {
		return nil, err
	}

	// Store instance for singletons
	if descriptor.Lifetime == Singleton {
		descriptor.Instance = instance
	}

	return instance, nil
}

// GetRequired retrieves a service and panics if not found (for convenience)
func (c *Container) GetRequired(serviceType interface{}) interface{} {
	instance, err := c.Get(serviceType)
	if err != nil {
		panic(fmt.Sprintf("required service not found: %v", err))
	}
	return instance
}

// createInstance creates a new instance of a service
func (c *Container) createInstance(descriptor *ServiceDescriptor) (interface{}, error) {
	// If we have a factory function, use it
	if descriptor.Factory != nil {
		return c.invokeFactory(descriptor.Factory)
	}

	// If we have an implementation type, create it
	if descriptor.Implementation != nil {
		return c.createFromType(descriptor.Implementation)
	}

	return nil, fmt.Errorf("cannot create instance for service %s", descriptor.ServiceType.String())
}

// invokeFactory calls a factory function to create a service
func (c *Container) invokeFactory(factory interface{}) (interface{}, error) {
	factoryType := reflect.TypeOf(factory)
	factoryValue := reflect.ValueOf(factory)

	// Validate factory is a function
	if factoryType.Kind() != reflect.Func {
		return nil, fmt.Errorf("factory must be a function, got %s", factoryType.Kind())
	}

	// Get factory parameters
	numIn := factoryType.NumIn()
	args := make([]reflect.Value, numIn)

	// Resolve factory parameters
	for i := 0; i < numIn; i++ {
		paramType := factoryType.In(i)
		param, err := c.resolveParameter(paramType)
		if err != nil {
			return nil, fmt.Errorf("failed to resolve factory parameter %d: %w", i, err)
		}
		args[i] = reflect.ValueOf(param)
	}

	// Call factory function
	results := factoryValue.Call(args)

	// Handle return values
	if len(results) == 0 {
		return nil, fmt.Errorf("factory function must return a value")
	}

	if len(results) == 2 && results[1].Interface() != nil {
		// Second return value is error
		if err, ok := results[1].Interface().(error); ok && err != nil {
			return nil, err
		}
	}

	return results[0].Interface(), nil
}

// createFromType creates an instance from a type using reflection
func (c *Container) createFromType(implType reflect.Type) (interface{}, error) {
	// Handle pointer types
	if implType.Kind() == reflect.Ptr {
		implType = implType.Elem()
	}

	// Create new instance
	instance := reflect.New(implType).Interface()

	// Try to inject dependencies if it's a struct
	if err := c.injectDependencies(instance); err != nil {
		return nil, err
	}

	return instance, nil
}

// injectDependencies injects dependencies into a struct
func (c *Container) injectDependencies(instance interface{}) error {
	instanceValue := reflect.ValueOf(instance)
	if instanceValue.Kind() == reflect.Ptr {
		instanceValue = instanceValue.Elem()
	}

	instanceType := instanceValue.Type()

	// Only handle structs
	if instanceType.Kind() != reflect.Struct {
		return nil
	}

	// Look for fields with dependency injection tags
	for i := 0; i < instanceValue.NumField(); i++ {
		field := instanceValue.Field(i)
		fieldType := instanceType.Field(i)

		// Check for inject tag
		if tag := fieldType.Tag.Get("inject"); tag != "" {
			// Try to resolve the dependency
			dependency, err := c.resolveParameter(field.Type())
			if err != nil {
				return fmt.Errorf("failed to inject field %s: %w", fieldType.Name, err)
			}

			// Set the field value
			if field.CanSet() {
				field.Set(reflect.ValueOf(dependency))
			}
		}
	}

	return nil
}

// resolveParameter resolves a parameter type from the container
func (c *Container) resolveParameter(paramType reflect.Type) (interface{}, error) {
	// Handle interface types
	if paramType.Kind() == reflect.Interface {
		// Look for registered services that implement this interface
		for _, descriptor := range c.services {
			if descriptor.Implementation != nil && descriptor.Implementation.Implements(paramType) {
				// Create a zero value of the service type to get the interface
				serviceInterface := reflect.Zero(descriptor.ServiceType).Interface()
				return c.Get(serviceInterface)
			}
		}
		return nil, fmt.Errorf("no service found implementing interface %s", paramType.String())
	}

	// Handle concrete types
	for _, descriptor := range c.services {
		if descriptor.Implementation != nil && descriptor.Implementation == paramType {
			// Create a zero value of the service type to get the interface
			serviceInterface := reflect.Zero(descriptor.ServiceType).Interface()
			return c.Get(serviceInterface)
		}
	}

	return nil, fmt.Errorf("no service found for type %s", paramType.String())
}

// Has checks if a service is registered
func (c *Container) Has(serviceType interface{}) bool {
	serviceName := reflect.TypeOf(serviceType).String()

	c.mu.RLock()
	defer c.mu.RUnlock()

	_, exists := c.services[serviceName]
	return exists
}

// Clear removes all registered services
func (c *Container) Clear() {
	c.mu.Lock()
	defer c.mu.Unlock()

	c.services = make(map[string]*ServiceDescriptor)
}

// GetServices returns all registered service names
func (c *Container) GetServices() []string {
	c.mu.RLock()
	defer c.mu.RUnlock()

	services := make([]string, 0, len(c.services))
	for serviceName := range c.services {
		services = append(services, serviceName)
	}
	return services
}
