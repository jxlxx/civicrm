#!/bin/bash

# Test Database Migrations Script
# This script tests that our migrations work correctly

set -e

echo "🧪 Testing CiviCRM Database Migrations..."

# Check if we're in the right directory
if [ ! -f "sqlc.yaml" ]; then
    echo "❌ Error: Must run from project root directory"
    exit 1
fi

# Check if sqlc is installed
if ! command -v sqlc &> /dev/null; then
    echo "❌ Error: sqlc not found. Install with: go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest"
    exit 1
fi

echo "✅ sqlc found"

# Validate SQL syntax
echo "🔍 Validating SQL syntax..."
if sqlc vet; then
    echo "✅ SQL syntax is valid"
else
    echo "❌ SQL syntax validation failed"
    exit 1
fi

# Generate Go code
echo "🔧 Generating Go code..."
if sqlc generate; then
    echo "✅ Go code generated successfully"
else
    echo "❌ Go code generation failed"
    exit 1
fi

# Test that generated code compiles
echo "🧪 Testing generated code compilation..."
if go build ./internal/database/generated/; then
    echo "✅ Generated code compiles successfully"
else
    echo "❌ Generated code compilation failed"
    exit 1
fi

# Run unit tests
echo "🧪 Running unit tests..."
if go test ./internal/database/ -v; then
    echo "✅ Unit tests passed"
else
    echo "❌ Unit tests failed"
    exit 1
fi

echo ""
echo "🎉 All tests passed! Your data layer is working correctly."
echo ""
echo "Next steps:"
echo "1. Set up a test database with TEST_DATABASE_URL"
echo "2. Run integration tests: go test ./internal/database/ -tags=integration"
echo "3. Apply migrations to your development database"
echo ""
echo "To set up a test database:"
echo "export TEST_DATABASE_URL='postgres://user:pass@localhost:5432/civicrm_test?sslmode=disable'"
