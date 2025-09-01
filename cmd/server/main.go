package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/jxlxx/civicrm/internal/core"
)

func main() {
	// Parse command line flags
	var configPath string
	flag.StringVar(&configPath, "config", "", "Path to configuration file")
	flag.Parse()

	// Set environment variable for config path if provided
	if configPath != "" {
		os.Setenv("CONFIG_PATH", configPath)
	}

	// Create and run the application
	app, err := core.NewApp()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create application: %v\n", err)
		os.Exit(1)
	}

	// Run the application
	if err := app.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Application failed: %v\n", err)
		os.Exit(1)
	}
}
