#!/bin/bash

# Configure Xcode project for Rust FFI integration
# This script adds the necessary files and build settings

PROJECT_PATH="WeightliftingApp/WeightliftingApp.xcodeproj"
SHARED_PATH="WeightliftingApp/Shared"

echo "🔧 Configuring Xcode project for Rust FFI integration..."

# Check if required files exist
if [ ! -f "$SHARED_PATH/libweightlifting_core.a" ]; then
    echo "❌ Error: libweightlifting_core.a not found in $SHARED_PATH"
    exit 1
fi

if [ ! -f "$SHARED_PATH/weightlifting_core.swift" ]; then
    echo "❌ Error: weightlifting_core.swift not found in $SHARED_PATH"
    exit 1
fi

if [ ! -f "$SHARED_PATH/weightlifting_coreFFI.h" ]; then
    echo "❌ Error: weightlifting_coreFFI.h not found in $SHARED_PATH"
    exit 1
fi

if [ ! -f "$SHARED_PATH/weightlifting_coreFFI.modulemap" ]; then
    echo "❌ Error: weightlifting_coreFFI.modulemap not found in $SHARED_PATH"
    exit 1
fi

echo "✅ All required FFI files found"

# Instructions for manual Xcode configuration
echo ""
echo "📋 Manual Xcode Configuration Steps:"
echo "======================================"
echo ""
echo "1. 📁 ADD FILES TO PROJECT:"
echo "   - Right-click on 'WeightliftingApp' in the project navigator"
echo "   - Select 'Add Files to WeightliftingApp'"
echo "   - Navigate to and select the 'Shared' folder"
echo "   - Make sure 'Create groups' is selected"
echo "   - Click 'Add'"
echo ""
echo "2. ⚙️ CONFIGURE BUILD SETTINGS:"
echo "   - Select the WeightliftingApp project in navigator"
echo "   - Select the WeightliftingApp target"
echo "   - Go to 'Build Settings' tab"
echo "   - Search for 'Library Search Paths'"
echo "   - Add: \$(PROJECT_DIR)/Shared"
echo ""
echo "3. 🔗 CONFIGURE LINKING:"
echo "   - Go to 'Build Phases' tab"
echo "   - Expand 'Link Binary With Libraries'"
echo "   - Click '+' to add library"
echo "   - Click 'Add Other...' → 'Add Files...'"
echo "   - Navigate to Shared/libweightlifting_core.a and add it"
echo ""
echo "4. 📥 CONFIGURE IMPORT PATHS:"
echo "   - In Build Settings, search for 'Swift Compiler - Search Paths'"
echo "   - Add to 'Import Paths': \$(PROJECT_DIR)/Shared"
echo ""
echo "5. 🏗️ ADDITIONAL SETTINGS:"
echo "   - Search for 'Other Linker Flags'"
echo "   - Add: -lc++"
echo "   - This is needed for Rust's standard library"
echo ""
echo "6. 🧪 TEST THE INTEGRATION:"
echo "   - Build the project (Cmd+B)"
echo "   - Run tests (Cmd+U)"
echo "   - Run the app (Cmd+R)"
echo ""

# Check Xcode version
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    echo "🔍 Detected: $XCODE_VERSION"
fi

echo ""
echo "🎯 Expected Result:"
echo "- Build should succeed without errors"
echo "- App should show logging activity when you tap buttons"
echo "- Tests should pass with comprehensive logging output"
echo ""
echo "🚀 Once configured, your app will have full Rust library integration with logging!"

# Verify file sizes (helpful for debugging)
echo ""
echo "📊 File Information:"
echo "==================="
ls -lh "$SHARED_PATH"