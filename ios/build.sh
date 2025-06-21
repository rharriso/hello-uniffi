#!/bin/bash

# Build script for WeightliftingApp iOS project
# This script builds the Rust shared library and generates Swift bindings

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SHARED_DIR="$PROJECT_ROOT/shared"
IOS_DIR="$PROJECT_ROOT/ios"
BINDING_OUTPUT_DIR="$IOS_DIR/WeightliftingApp/Shared"

print_color $BLUE "🏗️  Building WeightliftingApp iOS Project"
echo "Project Root: $PROJECT_ROOT"
echo "Shared Rust Library: $SHARED_DIR"
echo "iOS Project: $IOS_DIR"
echo ""

# Step 1: Build the Rust library
print_color $YELLOW "📦 Building Rust shared library..."
cd "$SHARED_DIR"

# Run tests first
print_color $BLUE "🧪 Running Rust tests..."
cargo test

# Build release version
print_color $BLUE "🔨 Building release version..."
cargo build --release

# Check if the library was built successfully
if [ ! -f "$SHARED_DIR/target/release/libweightlifting_core.a" ]; then
    print_color $RED "❌ Failed to build Rust library"
    exit 1
fi

print_color $GREEN "✅ Rust library built successfully"

# Step 2: Generate Swift bindings
print_color $YELLOW "🔗 Generating Swift bindings..."

# Create output directory if it doesn't exist
mkdir -p "$BINDING_OUTPUT_DIR"

# Generate bindings using uniffi-bindgen
uniffi-bindgen generate "$SHARED_DIR/src/weightlifting_core.udl" --language swift --out-dir "$BINDING_OUTPUT_DIR"

if [ ! -f "$BINDING_OUTPUT_DIR/weightlifting_core.swift" ]; then
    print_color $RED "❌ Failed to generate Swift bindings"
    exit 1
fi

print_color $GREEN "✅ Swift bindings generated successfully"

# Step 3: Copy the static library
print_color $YELLOW "📋 Copying static library..."
cp "$SHARED_DIR/target/release/libweightlifting_core.a" "$BINDING_OUTPUT_DIR/"

print_color $GREEN "✅ Static library copied successfully"

# Step 4: Build iOS project (if xcodebuild is available)
cd "$IOS_DIR"

if command -v xcodebuild &> /dev/null; then
    print_color $YELLOW "🍎 Building iOS project..."

    # Clean build folder
    xcodebuild clean -project WeightliftingApp/WeightliftingApp.xcodeproj -scheme WeightliftingApp

    # Build for iOS Simulator (x86_64/arm64)
    xcodebuild build -project WeightliftingApp/WeightliftingApp.xcodeproj -scheme WeightliftingApp -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' CODE_SIGNING_ALLOWED=NO

    print_color $GREEN "✅ iOS project built successfully"

    # Run tests
    print_color $YELLOW "🧪 Running iOS tests..."
    xcodebuild test -project WeightliftingApp/WeightliftingApp.xcodeproj -scheme WeightliftingApp -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' CODE_SIGNING_ALLOWED=NO

    print_color $GREEN "✅ iOS tests completed successfully"
else
    print_color $YELLOW "⚠️  xcodebuild not available, skipping iOS build"
    print_color $BLUE "💡 You can build the project manually in Xcode"
fi

# Summary
print_color $GREEN "🎉 Build completed successfully!"
echo ""
print_color $BLUE "📁 Generated files:"
echo "  - Swift bindings: $BINDING_OUTPUT_DIR/weightlifting_core.swift"
echo "  - Header file: $BINDING_OUTPUT_DIR/weightlifting_coreFFI.h"
echo "  - Module map: $BINDING_OUTPUT_DIR/weightlifting_coreFFI.modulemap"
echo "  - Static library: $BINDING_OUTPUT_DIR/libweightlifting_core.a"
echo ""
print_color $BLUE "🚀 Next steps:"
echo "  1. Open ios/WeightliftingApp/WeightliftingApp.xcodeproj in Xcode"
echo "  2. Build and run the project"
echo "  3. Run tests to verify FFI bindings work correctly"