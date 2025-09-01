package security

import (
	"context"
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/jxlxx/civicrm/internal/config"
	"github.com/jxlxx/civicrm/internal/logger"
	"golang.org/x/crypto/bcrypt"
)

// Manager handles security operations
type Manager struct {
	config *config.SecurityConfig
	logger *logger.Logger
	// In a real implementation, you'd have user storage and session management
}

// New creates a new security manager
func New(config *config.SecurityConfig) (*Manager, error) {
	if config.JWTSecret == "" {
		// Generate a random secret if none provided
		secret, err := generateRandomSecret()
		if err != nil {
			return nil, fmt.Errorf("failed to generate JWT secret: %w", err)
		}
		config.JWTSecret = secret
	}

	return &Manager{
		config: config,
	}, nil
}

// User represents an authenticated user
type User struct {
	ID       string            `json:"id"`
	Username string            `json:"username"`
	Email    string            `json:"email"`
	Roles    []string          `json:"roles"`
	Metadata map[string]string `json:"metadata"`
	Created  time.Time         `json:"created"`
	Updated  time.Time         `json:"updated"`
}

// Claims represents JWT claims
type Claims struct {
	UserID   string   `json:"user_id"`
	Username string   `json:"username"`
	Email    string   `json:"email"`
	Roles    []string `json:"roles"`
	jwt.RegisteredClaims
}

// AuthProvider interface for authentication
type AuthProvider interface {
	Authenticate(ctx context.Context, credentials interface{}) (*User, error)
	ValidateToken(ctx context.Context, token string) (*User, error)
}

// PermissionChecker interface for authorization
type PermissionChecker interface {
	CheckPermission(ctx context.Context, user *User, resource string, action string) bool
	GetUserPermissions(ctx context.Context, user *User) ([]string, error)
}

// NewManager creates a new security manager
func (m *Manager) NewManager() *Manager {
	return &Manager{
		config: m.config,
		logger: m.logger,
	}
}

// SetLogger sets the logger for the security manager
func (m *Manager) SetLogger(logger *logger.Logger) {
	m.logger = logger
}

// GenerateToken creates a JWT token for a user
func (m *Manager) GenerateToken(user *User) (string, error) {
	claims := &Claims{
		UserID:   user.ID,
		Username: user.Username,
		Email:    user.Email,
		Roles:    user.Roles,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(m.config.JWTExpiration)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
			Issuer:    "civicrm",
			Subject:   user.ID,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(m.config.JWTSecret))
}

// ValidateToken validates a JWT token and returns user information
func (m *Manager) ValidateToken(tokenString string) (*User, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(m.config.JWTSecret), nil
	})

	if err != nil {
		return nil, fmt.Errorf("failed to parse token: %w", err)
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		user := &User{
			ID:       claims.UserID,
			Username: claims.Username,
			Email:    claims.Email,
			Roles:    claims.Roles,
		}
		return user, nil
	}

	return nil, fmt.Errorf("invalid token")
}

// HashPassword hashes a password using bcrypt
func (m *Manager) HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), m.config.BCryptCost)
	if err != nil {
		return "", fmt.Errorf("failed to hash password: %w", err)
	}
	return string(bytes), nil
}

// CheckPassword checks if a password matches a hash
func (m *Manager) CheckPassword(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// CheckPermission checks if a user has permission to perform an action on a resource
func (m *Manager) CheckPermission(ctx context.Context, user *User, resource string, action string) bool {
	// Simple role-based permission check
	// In a real implementation, you'd have a more sophisticated permission system

	// Admin role has all permissions
	for _, role := range user.Roles {
		if role == "admin" {
			return true
		}
	}

	// Check specific resource permissions
	permission := fmt.Sprintf("%s:%s", resource, action)

	// This is a simplified example - you'd typically have a permission matrix
	allowedPermissions := map[string][]string{
		"contact": {"read", "create", "update", "delete"},
		"event":   {"read", "create", "update"},
		"report":  {"read", "create"},
	}

	if perms, exists := allowedPermissions[resource]; exists {
		for _, perm := range perms {
			if perm == action {
				return true
			}
		}
	}

	return false
}

// GetUserPermissions returns all permissions for a user
func (m *Manager) GetUserPermissions(ctx context.Context, user *User) ([]string, error) {
	permissions := []string{}

	// Admin role has all permissions
	for _, role := range user.Roles {
		if role == "admin" {
			// Return all possible permissions
			allPermissions := []string{
				"contact:read", "contact:create", "contact:update", "contact:delete",
				"event:read", "event:create", "event:update", "event:delete",
				"report:read", "report:create", "report:update", "report:delete",
				"user:read", "user:create", "user:update", "user:delete",
			}
			return allPermissions, nil
		}
	}

	// Return role-specific permissions
	for _, role := range user.Roles {
		switch role {
		case "manager":
			permissions = append(permissions,
				"contact:read", "contact:create", "contact:update",
				"event:read", "event:create", "event:update",
				"report:read", "report:create",
			)
		case "user":
			permissions = append(permissions,
				"contact:read", "contact:create",
				"event:read",
				"report:read",
			)
		}
	}

	return permissions, nil
}

// generateRandomSecret generates a random secret for JWT signing
func generateRandomSecret() (string, error) {
	// Generate RSA key pair
	privateKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		return "", fmt.Errorf("failed to generate RSA key: %w", err)
	}

	// Encode private key to PEM
	privateKeyPEM := &pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: x509.MarshalPKCS1PrivateKey(privateKey),
	}

	return string(pem.EncodeToMemory(privateKeyPEM)), nil
}

// EncryptField encrypts a field value
func (m *Manager) EncryptField(value string) (string, error) {
	// In a real implementation, you'd use proper encryption
	// This is a placeholder for demonstration
	return value, nil
}

// DecryptField decrypts a field value
func (m *Manager) DecryptField(encryptedValue string) (string, error) {
	// In a real implementation, you'd use proper decryption
	// This is a placeholder for demonstration
	return encryptedValue, nil
}

// ValidateInput validates and sanitizes input
func (m *Manager) ValidateInput(input string) (string, error) {
	// In a real implementation, you'd have proper input validation
	// This is a placeholder for demonstration
	return input, nil
}
