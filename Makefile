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

# Build for iOS (static library)
.PHONY: build-ios
build-ios:
	@echo "Building for iOS targets..."
	cargo build --release --target aarch64-apple-ios
	cargo build --release --target x86_64-apple-ios
	cargo build --release --target aarch64-apple-ios-sim
	@echo "Creating universal iOS library..."
	mkdir -p target/universal-ios/release
	lipo -create \
		target/aarch64-apple-ios/release/libweightlifting_core.a \
		target/x86_64-apple-ios/release/libweightlifting_core.a \
		target/aarch64-apple-ios-sim/release/libweightlifting_core.a \
		-output target/universal-ios/release/libweightlifting_core.a

# Build for Android (dynamic library)
.PHONY: build-android
build-android:
	@echo "Building for Android targets..."
	cargo build --release --target aarch64-linux-android
	cargo build --release --target armv7-linux-androideabi
	cargo build --release --target i686-linux-android
	cargo build --release --target x86_64-linux-android

# Generate Swift bindings
.PHONY: swift-bindings
swift-bindings: build-ios
	@echo "Generating Swift bindings..."
	mkdir -p bindings/swift
	cargo run --bin uniffi-bindgen generate --library target/aarch64-apple-ios/release/libweightlifting_core.a --language swift --out-dir bindings/swift

# Generate Kotlin bindings
.PHONY: kotlin-bindings
kotlin-bindings: build-android
	@echo "Generating Kotlin bindings..."
	mkdir -p bindings/kotlin
	cargo run --bin uniffi-bindgen generate --library target/aarch64-linux-android/release/libweightlifting_core.so --language kotlin --out-dir bindings/kotlin

# Generate all bindings
.PHONY: bindings
bindings: swift-bindings kotlin-bindings

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
ci: fmt check test build-ios build-android bindings

# Quick development cycle
.PHONY: quick
quick: test dev

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  setup          - Install required Rust targets and tools"
	@echo "  test           - Run Rust tests"
	@echo "  build-ios      - Build static library for iOS"
	@echo "  build-android  - Build dynamic library for Android"
	@echo "  swift-bindings - Generate Swift bindings"
	@echo "  kotlin-bindings- Generate Kotlin bindings"
	@echo "  bindings       - Generate all language bindings"
	@echo "  dev            - Development build (debug mode)"
	@echo "  clean          - Clean build artifacts"
	@echo "  check          - Check formatting and linting"
	@echo "  fmt            - Format code"
	@echo "  ci             - Full CI pipeline"
	@echo "  quick          - Quick development cycle (test + dev build)"
	@echo "  all            - Build everything (default)"
	@echo "  help           - Show this help"