package core

import (
	"fmt"

	"github.com/jxlxx/civicrm/internal/cache"
	"github.com/jxlxx/civicrm/internal/database"
	"github.com/jxlxx/civicrm/internal/logger"
)

// ExampleService demonstrates dependency injection
type ExampleService struct {
	Logger *logger.Logger     `inject:""`
	DB     *database.Database `inject:""`
}

// ExampleServiceInterface defines the contract
type ExampleServiceInterface interface {
	DoSomething() error
}

// DoSomething implements the interface
func (s *ExampleService) DoSomething() error {
	s.Logger.Info("Example service doing something")
	return nil
}

// ExampleFactory demonstrates factory-based registration
func NewExampleService(logger *logger.Logger, db *database.Database) ExampleServiceInterface {
	return &ExampleService{
		Logger: logger,
		DB:     db,
	}
}

// ExampleUsage demonstrates how to use the container
func ExampleUsage() {
	// Create container
	container := NewContainer()

	// Register services
	container.Register((*ExampleServiceInterface)(nil), (*ExampleService)(nil), Singleton)

	// Or register using factory function
	container.RegisterFactory((*ExampleServiceInterface)(nil), NewExampleService, Singleton)

	// Get service
	service, err := container.Get((*ExampleServiceInterface)(nil))
	if err != nil {
		fmt.Printf("Error getting service: %v\n", err)
		return
	}

	// Use service
	if err := service.(ExampleServiceInterface).DoSomething(); err != nil {
		fmt.Printf("Error using service: %v\n", err)
	}
}

// ExampleWithTags demonstrates struct tag injection
type ServiceWithTags struct {
	Logger *logger.Logger `inject:""`
	Cache  *cache.Manager `inject:""`
}

// ExampleRegistration demonstrates different registration methods
func ExampleRegistration() {
	container := NewContainer()

	// Method 1: Register type
	container.Register((*ExampleServiceInterface)(nil), (*ExampleService)(nil), Singleton)

	// Method 2: Register factory
	container.RegisterFactory((*ExampleServiceInterface)(nil), NewExampleService, Singleton)

	// Method 3: Register instance
	instance := &ExampleService{}
	container.RegisterInstance((*ExampleServiceInterface)(nil), instance)

	// Check if service exists
	if container.Has((*ExampleServiceInterface)(nil)) {
		fmt.Println("Service is registered")
	}

	// Get all registered services
	services := container.GetServices()
	fmt.Printf("Registered services: %v\n", services)
}
