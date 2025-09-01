# CiviCRM Go Makefile

.PHONY: help build run test clean deps lint format migrate

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
	@echo "  docker    - Build Docker image"
	@echo "  install   - Install the application"

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

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	go clean

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

# Run database migrations
migrate:
	@echo "Running database migrations..."
	go run cmd/migrate/main.go

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
		cp config/config.example.yaml config/config.yaml; \
		echo "Created config/config.yaml from example"; \
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
