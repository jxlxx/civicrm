#!/bin/bash

# CiviCRM Development Startup Script

set -e

echo "🚀 Starting CiviCRM development environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Start development services
echo "📦 Starting PostgreSQL and Redis..."
make up

# Set PostgreSQL environment variables for Tern
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=civicrm
export PGUSER=civicrm
export PGPASSWORD=civicrm_dev_password
export PGSSLMODE=disable

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
sleep 10

# Setup development environment
echo "⚙️  Setting up development environment..."
make dev-setup

# Run database migrations
echo "🗄️  Running database migrations..."
make migrate

# Build the application
echo "🔨 Building application..."
make build

echo "✅ Development environment ready!"
echo ""
echo "📊 Services:"
echo "   PostgreSQL: localhost:5432"
echo "   Redis: localhost:6379"
echo "   pgAdmin: http://localhost:8081"
echo ""
echo "🚀 To start the application:"
echo "   make run"
echo ""
echo "📝 To view logs:"
echo "   make docker-compose-logs"
echo ""
echo "🛑 To stop services:"
echo "   make down"
