# CiviCRM Go Implementation

A modern, high-performance implementation of CiviCRM built in Go.

## Architecture

This implementation follows a clean, modular architecture with the following key components:

### Core Infrastructure (`pkg/core/`)
- **Application Framework** - Main application structure and lifecycle
- **Configuration Management** - Environment-based configuration
- **Dependency Injection** - Service container and dependency management
- **Logging & Monitoring** - Structured logging and observability

### API Layer (`pkg/api/`)
- **REST API** - HTTP/2 RESTful endpoints
- **GraphQL** - GraphQL API for complex queries
- **gRPC** - High-performance internal service communication
- **API v4 Compatibility** - Maintains compatibility with existing CiviCRM API v4

### Extension System (`pkg/extensions/`)
- **Plugin Architecture** - Runtime extension loading
- **Hook System** - Event-driven extension points
- **API Registration** - Extensions can add new API endpoints
- **Dependency Management** - Extension dependency resolution

### Database Layer (`pkg/database/`)
- **Multi-Database Support** - PostgreSQL, MySQL, SQLite
- **Connection Pooling** - Efficient connection management
- **Migration System** - Versioned schema changes
- **ORM Layer** - Type-safe data mapping

### Security (`pkg/security/`)
- **Authentication** - JWT-based authentication
- **Authorization** - Role-based access control (RBAC)
- **Encryption** - Field-level encryption for sensitive data
- **Input Validation** - XSS and injection attack prevention

## Getting Started

### Prerequisites
- Go 1.21 or later
- PostgreSQL 13+ or MySQL 8.0+
- Redis 6.0+ (optional, for caching)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/jxlxx/civicrm.git
cd civicrm
```

2. Install dependencies:
```bash
go mod download
```

3. Configure environment:
```bash
cp config/config.example.yaml config/config.yaml
# Edit config.yaml with your database and other settings
```

4. Run database migrations:
```bash
go run cmd/migrate/main.go
```

5. Start the server:
```bash
go run cmd/server/main.go
```

## Configuration

The application uses environment-based configuration. Key configuration options:

- `DATABASE_URL` - Database connection string
- `REDIS_URL` - Redis connection string (optional)
- `JWT_SECRET` - Secret for JWT token signing
- `LOG_LEVEL` - Logging level (debug, info, warn, error)
- `API_PORT` - HTTP API port (default: 8080)

## API Documentation

### REST API
- Base URL: `http://localhost:8080/api/v4`
- Authentication: Bearer token in Authorization header
- Documentation: Available at `/api/docs` when running

### GraphQL
- Endpoint: `http://localhost:8080/graphql`
- Playground: Available at `/graphql` when running

## Development

### Project Structure
```
civicrm/
├── cmd/                    # Application entry points
├── pkg/                    # Core packages
│   ├── api/               # API layer
│   ├── core/              # Core framework
│   ├── database/          # Database layer
│   ├── extensions/        # Extension system
│   ├── security/          # Security components
│   └── cache/             # Caching layer
├── internal/               # Internal packages
├── config/                 # Configuration files
├── migrations/             # Database migrations
├── tests/                  # Test files
└── docs/                   # Documentation
```

### Running Tests
```bash
go test ./...
```

### Building
```bash
go build -o bin/civicrm cmd/server/main.go
```

## Migration from PHP

This implementation is designed to work alongside the existing PHP CiviCRM:

1. **Parallel Deployment** - Run both systems simultaneously
2. **Shared Database** - Both systems can access the same data
3. **Gradual Migration** - Move functionality piece by piece
4. **API Compatibility** - Maintain existing API contracts

## Performance

Key performance improvements over PHP implementation:

- **Concurrent Request Handling** - Go's goroutines handle multiple requests efficiently
- **Memory Efficiency** - Lower memory footprint per request
- **Faster Startup** - No PHP interpreter startup overhead
- **Better Caching** - Multi-tier caching system
- **Connection Pooling** - Efficient database connection management

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the AGPL-3.0 License - see the LICENSE file for details.

