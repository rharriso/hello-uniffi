# Weightlifting Core - Cross-platform Build Makefile

# Default target
.PHONY: all
all: test build-ios build-android

# Install required tools and targets
.PHONY: setup
setup:
	@echo "Installing required Rust targets and tools..."
	rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim
	rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
	cargo install uniffi-bindgen-go || true
	@echo "Setup complete!"

# Run tests
.PHONY: test
test:
	@echo "Running Rust tests..."
	cargo test

# iOS Builds
.PHONY: build-ios-release
build-ios-release:
	@echo "Building iOS release (device + simulator)..."
	cargo build --release --target aarch64-apple-ios
	cargo build --release --target x86_64-apple-ios
	cargo build --release --target aarch64-apple-ios-sim
	@echo "Creating iOS device library (arm64 + x86_64)..."
	mkdir -p target/universal-ios/release
	lipo -create \
		target/aarch64-apple-ios/release/libweightlifting_core.a \
		target/x86_64-apple-ios/release/libweightlifting_core.a \
		-output target/universal-ios/release/libweightlifting_core.a
	@echo "iOS simulator library available at: target/aarch64-apple-ios-sim/release/libweightlifting_core.a"
	@echo "iOS device library available at: target/universal-ios/release/libweightlifting_core.a"

.PHONY: build-ios-test
build-ios-test:
	@echo "Building iOS for testing (simulator only)..."
	cargo build --target aarch64-apple-ios-sim
	@echo "iOS test library built at: target/aarch64-apple-ios-sim/debug/libweightlifting_core.a"

.PHONY: build-ios-sim
build-ios-sim:
	@echo "Building for iOS Simulator (aarch64-apple-ios-sim)..."
	cargo build --release --target aarch64-apple-ios-sim
	@echo "iOS Simulator library built at: target/aarch64-apple-ios-sim/release/libweightlifting_core.a"

# Android Builds
.PHONY: build-android-release
build-android-release:
	@echo "Building Android release for all targets..."
	cargo build --release --target aarch64-linux-android
	cargo build --release --target armv7-linux-androideabi
	cargo build --release --target i686-linux-android
	cargo build --release --target x86_64-linux-android

.PHONY: build-android-test
build-android-test:
	@echo "Building Android for testing..."
	cargo build --target aarch64-linux-android
	@echo "Android test library built at: target/aarch64-linux-android/debug/libweightlifting_core.so"

# iOS Bindings and Integration
.PHONY: ios-bindings
ios-bindings: build-ios-sim
	@echo "Generating iOS bindings..."
	mkdir -p ../ios/WeightliftingApp/Shared
	uniffi-bindgen generate src/weightlifting_core.udl --language swift --out-dir ../ios/WeightliftingApp/Shared/
	cp target/aarch64-apple-ios-sim/release/libweightlifting_core.a ../ios/WeightliftingApp/Shared/
	@echo "iOS bindings and library copied to ../ios/WeightliftingApp/Shared/"
	@echo "Next: Configure Xcode project manually (see ../ios/INTEGRATION_GUIDE.md)"

.PHONY: ios-test
ios-test: build-ios-test
	@echo "iOS test build ready for integration testing"

# Android Bindings and Integration
.PHONY: android-bindings
android-bindings: build-android-release
	@echo "Generating Android bindings..."
	mkdir -p bindings/android
	uniffi-bindgen generate src/weightlifting_core.udl --language kotlin --out-dir bindings/android

.PHONY: android-test
android-test: build-android-test
	@echo "Android test build ready for integration testing"

# Legacy aliases (for backward compatibility)
.PHONY: build-ios build-android swift-bindings kotlin-bindings bindings
build-ios: build-ios-release
build-android: build-android-release
swift-bindings: ios-bindings
kotlin-bindings: android-bindings
bindings: ios-bindings android-bindings

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	cargo clean
	rm -rf bindings/
	rm -rf target/universal-ios/

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
ci: fmt check test build-ios-release build-android-release ios-bindings android-bindings

# Quick development cycle
.PHONY: quick
quick: test dev

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  setup              - Install required Rust targets and tools"
	@echo "  test               - Run Rust tests"
	@echo "  build-ios-release  - Build iOS release (device + simulator)"
	@echo "  build-ios-test     - Build iOS for testing (debug, simulator only)"
	@echo "  build-ios-sim      - Build iOS simulator release"
	@echo "  build-android-release - Build Android release (all targets)"
	@echo "  build-android-test - Build Android for testing (debug)"
	@echo "  ios-bindings       - Generate iOS bindings and copy to project"
	@echo "  ios-test           - Prepare iOS for testing"
	@echo "  android-bindings   - Generate Android bindings"
	@echo "  android-test       - Prepare Android for testing"
	@echo "  dev                - Development build (debug mode)"
	@echo "  clean              - Clean build artifacts"
	@echo "  check              - Check formatting and linting"
	@echo "  fmt                - Format code"
	@echo "  ci                 - Full CI pipeline"
	@echo "  quick              - Quick development cycle (test + dev build)"
	@echo "  all                - Build everything (default)"
	@echo "  help               - Show this help"