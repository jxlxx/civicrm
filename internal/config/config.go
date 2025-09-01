package config

import (
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/spf13/viper"
)

// Config represents the application configuration
type Config struct {
	Database   DatabaseConfig `mapstructure:"database"`
	Cache      CacheConfig    `mapstructure:"cache"`
	Security   SecurityConfig `mapstructure:"security"`
	API        APIConfig      `mapstructure:"api"`
	Logging    LoggingConfig  `mapstructure:"logging"`
	Extensions ExtensionsConfig `mapstructure:"extensions"`
}

// DatabaseConfig holds database connection settings
type DatabaseConfig struct {
	Driver   string `mapstructure:"driver"`
	Host     string `mapstructure:"host"`
	Port     int    `mapstructure:"port"`
	Username string `mapstructure:"username"`
	Password string `mapstructure:"password"`
	Database string `mapstructure:"database"`
	SSLMode  string `mapstructure:"ssl_mode"`
	MaxConns int    `mapstructure:"max_connections"`
	Timeout  time.Duration `mapstructure:"timeout"`
}

// CacheConfig holds cache configuration
type CacheConfig struct {
	Driver     string        `mapstructure:"driver"`
	Host       string        `mapstructure:"host"`
	Port       int           `mapstructure:"port"`
	Password   string        `mapstructure:"password"`
	Database   int           `mapstructure:"database"`
	TTL        time.Duration `mapstructure:"ttl"`
	MaxMemory  int64         `mapstructure:"max_memory"`
	MaxEntries int           `mapstructure:"max_entries"`
}

// SecurityConfig holds security settings
type SecurityConfig struct {
	JWTSecret        string        `mapstructure:"jwt_secret"`
	JWTExpiration    time.Duration `mapstructure:"jwt_expiration"`
	BCryptCost       int           `mapstructure:"bcrypt_cost"`
	SessionTimeout   time.Duration `mapstructure:"session_timeout"`
	MaxLoginAttempts int           `mapstructure:"max_login_attempts"`
	LockoutDuration time.Duration `mapstructure:"lockout_duration"`
}

// APIConfig holds API server settings
type APIConfig struct {
	Port         int           `mapstructure:"port"`
	Host         string        `mapstructure:"host"`
	ReadTimeout  time.Duration `mapstructure:"read_timeout"`
	WriteTimeout time.Duration `mapstructure:"write_timeout"`
	IdleTimeout  time.Duration `mapstructure:"idle_timeout"`
	CORS         CORSConfig    `mapstructure:"cors"`
}

// CORSConfig holds CORS settings
type CORSConfig struct {
	AllowedOrigins   []string `mapstructure:"allowed_origins"`
	AllowedMethods   []string `mapstructure:"allowed_methods"`
	AllowedHeaders   []string `mapstructure:"allowed_headers"`
	AllowCredentials bool     `mapstructure:"allow_credentials"`
	MaxAge           int      `mapstructure:"max_age"`
}

// LoggingConfig holds logging settings
type LoggingConfig struct {
	Level      string `mapstructure:"level"`
	Format     string `mapstructure:"format"`
	Output     string `mapstructure:"output"`
	MaxSize    int    `mapstructure:"max_size"`
	MaxBackups int    `mapstructure:"max_backups"`
	MaxAge     int    `mapstructure:"max_age"`
	Compress   bool   `mapstructure:"compress"`
}

// ExtensionsConfig holds extension settings
type ExtensionsConfig struct {
	Path        string   `mapstructure:"path"`
	AutoLoad    bool     `mapstructure:"auto_load"`
	Disabled    []string `mapstructure:"disabled"`
	Development bool     `mapstructure:"development"`
}

// Load reads configuration from environment variables and config files
func Load() (*Config, error) {
	config := &Config{}

	// Set defaults
	setDefaults(config)

	// Load from environment variables
	loadFromEnv(config)

	// Load from config file if it exists
	if err := loadFromFile(config); err != nil {
		// Log warning but continue with environment-based config
		fmt.Printf("Warning: Could not load config file: %v\n", err)
	}

	// Validate configuration
	if err := validate(config); err != nil {
		return nil, fmt.Errorf("invalid configuration: %w", err)
	}

	return config, nil
}

// setDefaults sets default configuration values
func setDefaults(config *Config) {
	config.Database = DatabaseConfig{
		Driver:      "postgres",
		Host:        "localhost",
		Port:        5432,
		MaxConns:    10,
		Timeout:     30 * time.Second,
		SSLMode:     "disable",
	}

	config.Cache = CacheConfig{
		Driver:     "memory",
		TTL:        1 * time.Hour,
		MaxMemory:  100 * 1024 * 1024, // 100MB
		MaxEntries: 10000,
	}

	config.Security = SecurityConfig{
		JWTExpiration:    24 * time.Hour,
		BCryptCost:       12,
		SessionTimeout:   30 * time.Minute,
		MaxLoginAttempts: 5,
		LockoutDuration:  15 * time.Minute,
	}

	config.API = APIConfig{
		Port:         8080,
		Host:         "0.0.0.0",
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  60 * time.Second,
		CORS: CORSConfig{
			AllowedOrigins:   []string{"*"},
			AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
			AllowedHeaders:   []string{"*"},
			AllowCredentials: true,
			MaxAge:           86400,
		},
	}

	config.Logging = LoggingConfig{
		Level:      "info",
		Format:     "json",
		Output:     "stdout",
		MaxSize:    100,
		MaxBackups: 3,
		MaxAge:     28,
		Compress:   true,
	}

	config.Extensions = ExtensionsConfig{
		Path:        "./extensions",
		AutoLoad:    true,
		Development: false,
	}
}

// loadFromEnv loads configuration from environment variables
func loadFromEnv(config *Config) {
	// Database
	if val := os.Getenv("DATABASE_URL"); val != "" {
		// Parse DATABASE_URL format: driver://username:password@host:port/database
		if dbConfig, err := parseDatabaseURL(val); err == nil {
			config.Database = dbConfig
		}
	}
	if val := os.Getenv("DB_HOST"); val != "" {
		config.Database.Host = val
	}
	if val := os.Getenv("DB_PORT"); val != "" {
		if port, err := strconv.Atoi(val); err == nil {
			config.Database.Port = port
		}
	}
	if val := os.Getenv("DB_USER"); val != "" {
		config.Database.Username = val
	}
	if val := os.Getenv("DB_PASS"); val != "" {
		config.Database.Password = val
	}
	if val := os.Getenv("DB_NAME"); val != "" {
		config.Database.Database = val
	}

	// Cache
	if val := os.Getenv("REDIS_URL"); val != "" {
		if cacheConfig, err := parseRedisURL(val); err == nil {
			config.Cache = cacheConfig
		}
	}

	// Security
	if val := os.Getenv("JWT_SECRET"); val != "" {
		config.Security.JWTSecret = val
	}

	// API
	if val := os.Getenv("API_PORT"); val != "" {
		if port, err := strconv.Atoi(val); err == nil {
			config.API.Port = port
		}
	}

	// Logging
	if val := os.Getenv("LOG_LEVEL"); val != "" {
		config.Logging.Level = val
	}
}

// loadFromFile loads configuration from config file
func loadFromFile(config *Config) error {
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath("./config")
	viper.AddConfigPath(".")

	if err := viper.ReadInConfig(); err != nil {
		return err
	}

	return viper.Unmarshal(config)
}

// parseDatabaseURL parses a database URL string
func parseDatabaseURL(url string) (DatabaseConfig, error) {
	// Simplified parsing - in production you'd want a more robust parser
	config := DatabaseConfig{}
	// Implementation would parse the URL and populate config
	return config, nil
}

// parseRedisURL parses a Redis URL string
func parseRedisURL(url string) (CacheConfig, error) {
	// Simplified parsing - in production you'd want a more robust parser
	config := CacheConfig{}
	// Implementation would parse the URL and populate config
	return config, nil
}

// validate ensures the configuration is valid
func validate(config *Config) error {
	if config.Database.Driver == "" {
		return fmt.Errorf("database driver is required")
	}
	if config.Database.Host == "" {
		return fmt.Errorf("database host is required")
	}
	if config.Database.Database == "" {
		return fmt.Errorf("database name is required")
	}
	if config.Security.JWTSecret == "" {
		return fmt.Errorf("JWT secret is required")
	}
	return nil
}
