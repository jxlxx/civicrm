# CiviCRM Go Makefile

.PHONY: help build run test clean deps lint format migrate migrate-new migrate-rollback migrate-status install-tern up down logs

# Default target
help:
	@echo "Available targets:"
	@echo "  build     - Build the application"
	@echo "  run       - Run the application"
	@echo "  test      - Run tests"
	@echo "  clean     - Clean build artifacts"
	@echo "  deps      - Download dependencies"
	@echo "  lint      - Run linter"
	@echo "  format    - Format code"
	@echo "  migrate   - Run database migrations"
	@echo "  migrate-new - Create new migration file"
	@echo "  migrate-rollback - Rollback to specific version"
	@echo "  migrate-status - Show migration status"
	@echo "  migrate-test - Run test database migrations"
	@echo "  migrate-test-status - Show test migration status"
	@echo "  install-tern - Install Tern migration tool"
	@echo "  up        - Start development services (PostgreSQL, Redis)"
	@echo "  down      - Stop development services"
	@echo "  logs      - Show development service logs"
	@echo "  docker    - Build Docker image"
	@echo "  install   - Install the application"

# Install Tern migration tool
install-tern:
	@echo "Installing Tern migration tool..."
	go install github.com/jackc/tern/v2/cmd/tern@latest
	@echo "Tern installation complete"

# Start development services
up:
	@echo "Starting development services..."
	docker compose --profile tools up -d
	@echo "Services started. PostgreSQL on port 5432, Redis on port 6379"
	@echo "pgAdmin available at http://localhost:8081 (admin@civicrm.dev / admin_password)"

# Stop development services
down:
	@echo "Stopping development services..."
	docker compose --profile tools down
	@echo "Services stopped"

# Show development service logs
logs:
	@echo "Development service logs:"
	docker compose logs -f

# Run database migrations
migrate:
	@echo "Running database migrations..."
	export PGHOST=localhost; 
	export PGPORT=5432; 
	export PGDATABASE=civicrm; 
	export PGUSER=civicrm; 
	export PGPASSWORD=civicrm_dev_password; 
	export PGSSLMODE=disable; 
	tern migrate -c tern.conf --migrations migrations; 


# Create new migration file
migrate-new:
	@read -p "Enter migration name: " name; \
	export PGHOST=localhost; \
	export PGPORT=5432; \
	export PGDATABASE=civicrm; \
	export PGUSER=civicrm; \
	export PGPASSWORD=civicrm_dev_password; \
	export PGSSLMODE=disable; \
	tern new $$name

# Rollback to specific version
migrate-rollback:
	@read -p "Enter target version: " version; \
	export PGHOST=localhost; \
	export PGPORT=5432; \
	export PGDATABASE=civicrm; \
	export PGUSER=civicrm; \
	export PGPASSWORD=civicrm_dev_password; \
	export PGSSLMODE=disable; \
	tern migrate -c tern.conf --migrations migrations --target $$version

# Show migration status
migrate-status:
	@echo "Migration status:"
	@export PGHOST=localhost; \
	export PGPORT=5432; \
	export PGDATABASE=civicrm; \
	export PGUSER=civicrm; \
	export PGPASSWORD=civicrm_dev_password; \
	export PGSSLMODE=disable; \
	tern migrate -c tern.conf --migrations migrations --destination 0 || true

# Run test database migrations
migrate-test:
	@echo "Running test database migrations..."
	PGHOST=localhost PGPORT=5433 PGDATABASE=civicrm_test PGUSER=civicrm PGPASSWORD=testpass PGSSLMODE=disable tern migrate -c tern.conf --migrations migrations

# Show test migration status
migrate-test-status:
	@echo "Test migration status:"
	@PGHOST=localhost PGPORT=5433 PGDATABASE=civicrm_test PGUSER=civicrm PGPASSWORD=testpass PGSSLMODE=disable tern migrate -c tern.conf --migrations migrations --destination 0 || true

# Build the application
build:
	@echo "Building CiviCRM..."
	@mkdir -p bin
	go build -o bin/civicrm cmd/server/main.go
	@echo "Build complete: bin/civicrm"

# Run the application
run:
	@echo "Running CiviCRM..."
	go run cmd/server/main.go

# Run tests
test:
	@echo "Running tests..."
	go test -v ./...

# Clean build artifacts and Docker resources
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	go clean
	@echo "Cleaning Docker resources..."
	@if docker compose ps -q > /dev/null 2>&1; then \
		docker compose --profile tools down -v --remove-orphans; \
		echo "Docker containers, volumes, and networks removed"; \
	else \
		echo "No Docker containers running"; \
	fi
	@docker network prune -f > /dev/null 2>&1 || true

# Download dependencies
deps:
	@echo "Downloading dependencies..."
	go mod download
	go mod tidy

# Run linter
lint:
	@echo "Running linter..."
	golangci-lint run

# Format code
format:
	@echo "Formatting code..."
	go fmt ./...
	goimports -w .

# Build Docker image
docker:
	@echo "Building Docker image..."
	docker build -t jxlxx/civicrm:latest .

# Install the application
install: build
	@echo "Installing CiviCRM..."
	cp bin/civicrm /usr/local/bin/
	@echo "Installation complete"

# Development setup
dev-setup: deps
	@echo "Setting up development environment..."
	@if [ ! -f config/config.yaml ]; then \
		cp config/config.development.yaml config/config.yaml; \
		echo "Created config/config.yaml from development config"; \
	fi
	@if [ ! -f tern.conf ]; then \
		cp migrations/tern.conf.example tern.conf; \
		echo "Created tern.conf from example"; \
	fi
	@echo "Development setup complete"

# Quick start for development
dev: dev-setup run

# Build for specific platform
build-linux:
	@echo "Building for Linux..."
	@mkdir -p bin
	GOOS=linux GOARCH=amd64 go build -o bin/civicrm-linux cmd/server/main.go

build-darwin:
	@echo "Building for macOS..."
	@mkdir -p bin
	GOOS=darwin GOARCH=amd64 go build -o bin/civicrm-darwin cmd/server/main.go

build-windows:
	@echo "Building for Windows..."
	@mkdir -p bin
	GOOS=windows GOARCH=amd64 go build -o bin/civicrm.exe cmd/server/main.go

# Build all platforms
build-all: build-linux build-darwin build-windows

# Show application info
info:
	@echo "CiviCRM Go Implementation"
	@echo "Version: 1.0.0"
	@echo "Go version: $(shell go version)"
	@echo "Module: $(shell go list -m)"
