#!/bin/bash

# Weightlifting Core - Cross-platform Build Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    log_info "Checking requirements..."

    if ! command -v cargo &> /dev/null; then
        log_error "Cargo is not installed. Please install Rust first."
        exit 1
    fi

    if ! command -v lipo &> /dev/null && [[ "$OSTYPE" == "darwin"* ]]; then
        log_warning "lipo not found. iOS universal library creation will be skipped."
    fi

    log_success "Requirements check completed"
}

# Setup Rust targets
setup_targets() {
    log_info "Setting up Rust targets..."

    # iOS targets
    rustup target add aarch64-apple-ios || log_warning "Failed to add aarch64-apple-ios target"
    rustup target add x86_64-apple-ios || log_warning "Failed to add x86_64-apple-ios target"
    rustup target add aarch64-apple-ios-sim || log_warning "Failed to add aarch64-apple-ios-sim target"

    # Android targets
    rustup target add aarch64-linux-android || log_warning "Failed to add aarch64-linux-android target"
    rustup target add armv7-linux-androideabi || log_warning "Failed to add armv7-linux-androideabi target"
    rustup target add i686-linux-android || log_warning "Failed to add i686-linux-android target"
    rustup target add x86_64-linux-android || log_warning "Failed to add x86_64-linux-android target"

    log_success "Rust targets setup completed"
}

# Run tests
run_tests() {
    log_info "Running tests..."
    cargo test
    log_success "Tests passed"
}

# Build for iOS
build_ios() {
    log_info "Building for iOS..."

    # Build for different iOS architectures
    cargo build --release --target aarch64-apple-ios
    cargo build --release --target x86_64-apple-ios
    cargo build --release --target aarch64-apple-ios-sim

    # Create universal library if lipo is available
    if command -v lipo &> /dev/null; then
        log_info "Creating universal iOS library..."
        mkdir -p target/universal-ios/release
        lipo -create \
            target/aarch64-apple-ios/release/libweightlifting_core.a \
            target/x86_64-apple-ios/release/libweightlifting_core.a \
            target/aarch64-apple-ios-sim/release/libweightlifting_core.a \
            -output target/universal-ios/release/libweightlifting_core.a
        log_success "Universal iOS library created"
    else
        log_warning "Skipping universal library creation (lipo not available)"
    fi

    log_success "iOS build completed"
}

# Build for Android
build_android() {
    log_info "Building for Android..."

    # Check if NDK is configured
    if [[ -z "$ANDROID_NDK_HOME" ]] && [[ -z "$NDK_HOME" ]]; then
        log_warning "Android NDK not configured. Set ANDROID_NDK_HOME or NDK_HOME environment variable."
        log_warning "Android build will be attempted anyway..."
    fi

    # Build for different Android architectures
    cargo build --release --target aarch64-linux-android || log_warning "Failed to build for aarch64-linux-android"
    cargo build --release --target armv7-linux-androideabi || log_warning "Failed to build for armv7-linux-androideabi"
    cargo build --release --target i686-linux-android || log_warning "Failed to build for i686-linux-android"
    cargo build --release --target x86_64-linux-android || log_warning "Failed to build for x86_64-linux-android"

    log_success "Android build completed"
}

# Generate Swift bindings
generate_swift_bindings() {
    log_info "Generating Swift bindings..."

    mkdir -p bindings/swift

    # Use the first available iOS library for binding generation
    LIBRARY_PATH=""
    if [[ -f "target/universal-ios/release/libweightlifting_core.a" ]]; then
        LIBRARY_PATH="target/universal-ios/release/libweightlifting_core.a"
    elif [[ -f "target/aarch64-apple-ios/release/libweightlifting_core.a" ]]; then
        LIBRARY_PATH="target/aarch64-apple-ios/release/libweightlifting_core.a"
    else
        log_error "No iOS library found for Swift binding generation"
        return 1
    fi

    cargo run --bin uniffi-bindgen generate --library "$LIBRARY_PATH" --language swift --out-dir bindings/swift
    log_success "Swift bindings generated in bindings/swift/"
}

# Generate Kotlin bindings
generate_kotlin_bindings() {
    log_info "Generating Kotlin bindings..."

    mkdir -p bindings/kotlin

    # Use the first available Android library for binding generation
    LIBRARY_PATH=""
    if [[ -f "target/aarch64-linux-android/release/libweightlifting_core.so" ]]; then
        LIBRARY_PATH="target/aarch64-linux-android/release/libweightlifting_core.so"
    elif [[ -f "target/x86_64-linux-android/release/libweightlifting_core.so" ]]; then
        LIBRARY_PATH="target/x86_64-linux-android/release/libweightlifting_core.so"
    else
        log_error "No Android library found for Kotlin binding generation"
        return 1
    fi

    cargo run --bin uniffi-bindgen generate --library "$LIBRARY_PATH" --language kotlin --out-dir bindings/kotlin
    log_success "Kotlin bindings generated in bindings/kotlin/"
}

# Print usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help       Show this help message"
    echo "  -s, --setup      Setup Rust targets only"
    echo "  -t, --test       Run tests only"
    echo "  -i, --ios        Build for iOS only"
    echo "  -a, --android    Build for Android only"
    echo "  -b, --bindings   Generate bindings only"
    echo "  -q, --quick      Quick build (test + debug build)"
    echo "  -c, --clean      Clean build artifacts"
    echo "  --swift          Generate Swift bindings only"
    echo "  --kotlin         Generate Kotlin bindings only"
    echo ""
    echo "If no options are provided, runs the full build pipeline."
}

# Clean build artifacts
clean_build() {
    log_info "Cleaning build artifacts..."
    cargo clean
    rm -rf bindings/
    rm -rf target/universal-ios/
    log_success "Clean completed"
}

# Main function
main() {
    log_info "Starting Weightlifting Core build process..."

    case "${1:-}" in
        -h|--help)
            usage
            exit 0
            ;;
        -s|--setup)
            check_requirements
            setup_targets
            ;;
        -t|--test)
            check_requirements
            run_tests
            ;;
        -i|--ios)
            check_requirements
            build_ios
            ;;
        -a|--android)
            check_requirements
            build_android
            ;;
        -b|--bindings)
            generate_swift_bindings || log_warning "Swift binding generation failed"
            generate_kotlin_bindings || log_warning "Kotlin binding generation failed"
            ;;
        --swift)
            generate_swift_bindings
            ;;
        --kotlin)
            generate_kotlin_bindings
            ;;
        -q|--quick)
            check_requirements
            run_tests
            cargo build
            log_success "Quick build completed"
            ;;
        -c|--clean)
            clean_build
            ;;
        "")
            # Full build pipeline
            check_requirements
            setup_targets
            run_tests
            build_ios
            build_android
            generate_swift_bindings || log_warning "Swift binding generation failed"
            generate_kotlin_bindings || log_warning "Kotlin binding generation failed"
            log_success "Full build pipeline completed!"
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"