# Weightlifting Core - Cross-platform Build Makefile

# Default target
.PHONY: all
all: test build-ios build-android

# Install required tools and targets
.PHONY: setup
setup:
	@echo "Installing required Rust targets and tools..."
	./build.sh --setup
	cargo install uniffi-bindgen-go || true
	@echo "Setup complete!"

# Run tests
.PHONY: test
test:
	@echo "Running Rust tests..."
	./build.sh --test

# iOS Builds
.PHONY: build-ios
build-ios:
	@echo "Building iOS release (device + simulator)..."
	./build.sh --ios

# Android Builds
.PHONY: build-android
build-android:
	@echo "Building Android release for all targets..."
	./build.sh --android

# iOS Bindings and Integration
.PHONY: ios-bindings
ios-bindings:
	@echo "Generating iOS bindings and integrating with project..."
	./build.sh --ios-bindings

# Android Bindings and Integration
.PHONY: android-bindings
android-bindings: build-android
	@echo "Generating Android bindings..."
	./build.sh --kotlin

# Legacy aliases (for backward compatibility)
.PHONY: build-ios build-android swift-bindings kotlin-bindings bindings
build-ios: build-ios
build-android: build-android
swift-bindings: ios-bindings
kotlin-bindings: android-bindings
bindings: ios-bindings android-bindings

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	./build.sh --clean

# Development build (debug mode)
.PHONY: dev
dev:
	@echo "Building in development mode..."
	cargo build

# Check code formatting and linting
.PHONY: check
check:
	@echo "Checking code formatting and linting..."
	cargo fmt --check
	cargo clippy -- -D warnings

# Format code
.PHONY: fmt
fmt:
	@echo "Formatting code..."
	cargo fmt

# Full CI pipeline
.PHONY: ci
ci: fmt check test build-ios build-android ios-bindings android-bindings

# Quick development cycle
.PHONY: quick
quick:
	@echo "Running quick build cycle..."
	./build.sh --quick

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  setup              - Install required Rust targets and tools"
	@echo "  all                - Build everything (default)"
	@echo "  android-bindings   - Generate Android bindings"
	@echo "  build-android      - Build Android release (all targets)"
	@echo "  build-ios          - Build iOS release (device + simulator)"
	@echo "  check              - Check formatting and linting"
	@echo "  ci                 - Full CI pipeline"
	@echo "  clean              - Clean build artifacts"
	@echo "  fmt                - Format code"
	@echo "  help               - Show this help"
	@echo "  ios-bindings       - Generate iOS bindings and copy to project"
	@echo "  quick              - Quick development cycle (test + dev build)"
	@echo "  test               - Run Rust tests"