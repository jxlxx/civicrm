# CiviCRM Go Makefile

.PHONY: help build run test clean deps lint format migrate migrate-new migrate-rollback migrate-status install-tern up down logs generate-api build-docs docs install-redocly

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
	@echo "  up        - Start development services (PostgreSQL, Redis, pgAdmin, Redocly)"
	@echo "  down      - Stop development services"
	@echo "  logs      - Show development service logs"
	@echo "  docker    - Build Docker image"
	@echo "  install   - Install the application"
	@echo "  generate-api - Generate Go code from OpenAPI spec"
	@echo "  install-oapi - Install oapi-codegen tool"
	@echo "  watch-api   - Watch OpenAPI spec and regenerate code"
	@echo "  build-docs  - Build API documentation to internal/api/static/"
	@echo "  docs        - Serve API documentation with Redocly"
	@echo "  docs-python - Serve API documentation with Python (fallback)"
	@echo "  install-redocly - Install Redocly CLI tool"

# Install Tern migration tool
install-tern:
	@echo "Installing Tern migration tool..."
	go install github.com/jackc/tern/v2/cmd/tern@latest
	@echo "Tern installation complete"

# Install oapi-codegen tool
install-oapi:
	@echo "Installing oapi-codegen tool..."
	go install github.com/deepmap/oapi-codegen/cmd/oapi-codegen@latest
	@echo "oapi-codegen installation complete"

# Generate Go code from OpenAPI specification
generate-api:
	@echo "Generating Go code from OpenAPI specification..."
	@if [ ! -f api/openapi.yaml ]; then \
		echo "Error: api/openapi.yaml not found"; \
		exit 1; \
	fi
	oapi-codegen --config api/oapi-codegen-config.yaml api/openapi.yaml
	@echo "Copying OpenAPI spec to static directory..."
	@mkdir -p internal/api/static
	@cp api/openapi.yaml internal/api/static/openapi.yaml
	@echo "API code generation complete: internal/api/generated.go"
	@echo "OpenAPI spec copied to: internal/api/static/openapi.yaml"

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

# Migrate to specific version
migrate-to:
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make migrate-to VERSION=<number>"; \
		echo "Example: make migrate-to VERSION=10"; \
		exit 1; \
	fi; \
	export PGHOST=localhost; \
	export PGPORT=5432; \
	export PGDATABASE=civicrm; \
	export PGUSER=civicrm; \
	export PGPASSWORD=civicrm_dev_password; \
	export PGSSLMODE=disable; \
	tern migrate -c tern.conf --migrations migrations --target $(VERSION)

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
	@echo "Generating API code..."
	@$(MAKE) generate-api
	@echo "Building documentation..."
	@$(MAKE) build-docs

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

# Watch OpenAPI spec and regenerate code (requires fswatch)
watch-api:
	@echo "Watching OpenAPI specification for changes..."
	@if command -v fswatch > /dev/null 2>&1; then \
		fswatch -o api/openapi.yaml | xargs -n1 -I{} make generate-api; \
	else \
		echo "fswatch not found. Install with: brew install fswatch (macOS) or apt-get install fswatch (Ubuntu)"; \
		echo "Alternatively, run 'make generate-api' manually when you change the OpenAPI spec"; \
	fi

# Install Redocly CLI tool
install-redocly:
	@echo "Installing Redocly CLI tool..."
	npm install -g @redocly/cli
	@echo "Redocly CLI installation complete"

# Build API documentation
build-docs:
	@echo "Building API documentation..."
	@mkdir -p internal/api/static
	@cp api/docs.html internal/api/static/docs.html
	@cp api/openapi.yaml internal/api/static/openapi.yaml
	@echo "Documentation built to internal/api/static/"

# Serve API documentation with Redocly
docs:
	@echo "Starting Redocly documentation server..."
	@if command -v redocly > /dev/null 2>&1; then \
		redocly serve api/openapi.yaml --port 8082; \
	else \
		echo "Redocly CLI not found. Install with: make install-redocly"; \
		echo "Alternatively, use Docker: make up (includes Redocly container)"; \
		exit 1; \
	fi

# Serve API documentation with Python (fallback)
docs-python:
	@echo "Starting Python HTTP server for API documentation..."
	@echo "Open http://localhost:8082/docs.html in your browser"
	cd api && python3 -m http.server 8082

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
