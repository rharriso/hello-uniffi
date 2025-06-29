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

    rustup target add aarch64-apple-ios
    rustup target add aarch64-apple-ios-macabi
    rustup target add aarch64-apple-ios-sim
    rustup target add armv7s-apple-ios
    rustup target add i386-apple-ios
    rustup target add x86_64-apple-ios
    rustup target add x86_64-apple-ios-macabi
    cargo install cargo-lipo || log_error "Failed to install cargo-lipo"

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

    # Build universal library for different iOS architectures
    cargo lipo --release

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

    # Check if UDL file exists
    if [[ ! -f "src/weightlifting_core.udl" ]]; then
        log_error "UDL file not found at src/weightlifting_core.udl"
        return 1
    fi

    # Generate Swift bindings using UDL file
    uniffi-bindgen generate src/weightlifting_core.udl --language swift --out-dir bindings/swift
    log_success "Swift bindings generated in bindings/swift/"
}

# Generate Kotlin bindings
generate_kotlin_bindings() {
    log_info "Generating Kotlin bindings..."

    mkdir -p bindings/kotlin

    # Check if UDL file exists
    if [[ ! -f "src/weightlifting_core.udl" ]]; then
        log_error "UDL file not found at src/weightlifting_core.udl"
        return 1
    fi

    # Generate Kotlin bindings using UDL file
    uniffi-bindgen generate src/weightlifting_core.udl --language kotlin --out-dir bindings/kotlin
    log_success "Kotlin bindings generated in bindings/kotlin/"
}

# iOS project integration - generate bindings and copy to iOS project
ios_project_integration() {
    log_info "Generating iOS bindings and integrating with iOS project..."

    # First ensure we have iOS libraries built
    if [[ ! -f "target/aarch64-apple-ios/release/libweightlifting_core.a" ]] && [[ ! -f "target/universal-ios/release/libweightlifting_core.a" ]]; then
        log_info "iOS libraries not found, building them first..."
        build_ios
    fi

    # Generate Swift bindings
    generate_swift_bindings || {
        log_error "Failed to generate Swift bindings"
        return 1
    }

    # Create iOS project directory structure
    IOS_PROJECT_DIR="../ios/WeightliftingApp/Shared"
    log_info "Creating iOS project directory: $IOS_PROJECT_DIR"
    mkdir -p "$IOS_PROJECT_DIR"

    # Copy Swift bindings
    log_info "Copying Swift bindings to iOS project..."
    if [[ -d "bindings/swift" ]]; then
        cp bindings/swift/* "$IOS_PROJECT_DIR/" 2>/dev/null || log_warning "Some Swift binding files may not have copied"
    fi

    # Copy iOS libraries
    log_info "Copying iOS device library..."
    if [[ -f "target/universal-ios/release/libweightlifting_core.a" ]]; then
        cp target/universal-ios/release/libweightlifting_core.a "$IOS_PROJECT_DIR/libweightlifting_core_device.a"
    elif [[ -f "target/aarch64-apple-ios/release/libweightlifting_core.a" ]]; then
        cp target/aarch64-apple-ios/release/libweightlifting_core.a "$IOS_PROJECT_DIR/libweightlifting_core_device.a"
    else
        log_warning "No device library found"
    fi

    log_info "Copying iOS simulator library..."
    if [[ -f "target/universal-ios/release/libweightlifting_core_sim.a" ]]; then
        cp target/universal-ios/release/libweightlifting_core_sim.a "$IOS_PROJECT_DIR/libweightlifting_core_sim.a"
    elif [[ -f "target/aarch64-apple-ios-sim/release/libweightlifting_core.a" ]]; then
        cp target/aarch64-apple-ios-sim/release/libweightlifting_core.a "$IOS_PROJECT_DIR/libweightlifting_core_sim.a"
    else
        log_warning "No simulator library found"
    fi

    log_success "iOS bindings and libraries copied to $IOS_PROJECT_DIR"
    log_info "Libraries available:"
    [[ -f "$IOS_PROJECT_DIR/libweightlifting_core_device.a" ]] && log_info "  - Device library: libweightlifting_core_device.a"
    [[ -f "$IOS_PROJECT_DIR/libweightlifting_core_sim.a" ]] && log_info "  - Simulator library: libweightlifting_core_sim.a"
    log_info "Next: Configure Xcode project manually (see ../ios/INTEGRATION_GUIDE.md)"
}

# Print usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help           Show this help message"
    echo "  -s, --setup          Setup Rust targets only"
    echo "  -t, --test           Run tests only"
    echo "  -i, --ios            Build for iOS only"
    echo "  -a, --android        Build for Android only"
    echo "  -b, --bindings       Generate bindings only"
    echo "  -q, --quick          Quick build (test + debug build)"
    echo "  -c, --clean          Clean build artifacts"
    echo "  --swift              Generate Swift bindings only"
    echo "  --kotlin             Generate Kotlin bindings only"
    echo "  --ios-bindings       Generate iOS bindings and integrate with project"
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
        --ios-bindings)
            check_requirements
            ios_project_integration
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