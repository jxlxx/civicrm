package logger

import (
	"io"
	"os"

	"github.com/jxlxx/civicrm/internal/config"
	"log/slog"
)

// Logger wraps the slog logger with additional methods
type Logger struct {
	*slog.Logger
	config *config.LoggingConfig
}

// New creates a new logger instance
func New(config *config.LoggingConfig) (*Logger, error) {
	var level slog.Level

	switch config.Level {
	case "debug":
		level = slog.LevelDebug
	case "info":
		level = slog.LevelInfo
	case "warn":
		level = slog.LevelWarn
	case "error":
		level = slog.LevelError
	default:
		level = slog.LevelInfo
	}

	// Configure handler options
	opts := &slog.HandlerOptions{
		Level: level,
	}

	var handler slog.Handler

	// Configure output
	if config.Output == "stdout" {
		if config.Format == "json" {
			handler = slog.NewJSONHandler(os.Stdout, opts)
		} else {
			handler = slog.NewTextHandler(os.Stdout, opts)
		}
	} else {
		// For file output, we'd need to open the file
		// For now, fall back to stdout
		if config.Format == "json" {
			handler = slog.NewJSONHandler(os.Stdout, opts)
		} else {
			handler = slog.NewTextHandler(os.Stdout, opts)
		}
	}

	// Create logger
	slogLogger := slog.New(handler)

	return &Logger{
		Logger: slogLogger,
		config: config,
	}, nil
}

// Info logs an info level message
func (l *Logger) Info(msg string, args ...interface{}) {
	l.Logger.Info(msg, args...)
}

// Error logs an error level message
func (l *Logger) Error(msg string, args ...interface{}) {
	l.Logger.Error(msg, args...)
}

// Debug logs a debug level message
func (l *Logger) Debug(msg string, args ...interface{}) {
	l.Logger.Debug(msg, args...)
}

// Warn logs a warning level message
func (l *Logger) Warn(msg string, args ...interface{}) {
	l.Logger.Warn(msg, args...)
}

// Fatal logs a fatal level message and exits
func (l *Logger) Fatal(msg string, args ...interface{}) {
	l.Logger.Error(msg, args...)
	os.Exit(1)
}

// WithContext adds context fields to the logger
func (l *Logger) WithContext(ctx map[string]interface{}) *Logger {
	// Convert map to key-value pairs for slog
	args := make([]interface{}, 0, len(ctx)*2)
	for k, v := range ctx {
		args = append(args, k, v)
	}
	
	// slog.With returns a new logger with the given attributes
	newLogger := l.Logger.With(args...)
	
	return &Logger{
		Logger: newLogger,
		config: l.config,
	}
}

// Sync flushes any buffered log entries
func (l *Logger) Sync() error {
	// slog doesn't have a Sync method, but we can implement it if needed
	// For now, return nil as slog handles buffering internally
	return nil
}

// NewNop creates a no-op logger for testing
func NewNop() *Logger {
	return &Logger{
		Logger: slog.New(slog.NewTextHandler(io.Discard, nil)),
		config: &config.LoggingConfig{},
	}
}
