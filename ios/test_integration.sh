#!/bin/bash

# Test script to verify Rust FFI integration is working
echo "🧪 Testing Rust FFI Integration"
echo "==============================="

PROJECT_PATH="WeightliftingApp/WeightliftingApp.xcodeproj"

# Test 1: Check if project builds
echo ""
echo "1. 🔨 Testing Build..."
cd WeightliftingApp

if xcodebuild -project WeightliftingApp.xcodeproj -scheme WeightliftingApp -destination 'platform=iOS Simulator,name=iPhone 16' build > build.log 2>&1; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed. Check build.log for details:"
    tail -n 20 build.log
    exit 1
fi

# Test 2: Run unit tests
echo ""
echo "2. 🧪 Running Unit Tests..."
if xcodebuild -project WeightliftingApp.xcodeproj -scheme WeightliftingApp -destination 'platform=iOS Simulator,name=iPhone 16' test > test.log 2>&1; then
    echo "✅ All tests passed!"

    # Show test summary
    echo ""
    echo "📊 Test Summary:"
    grep -E "(Test Case|Test Suite)" test.log | tail -n 10
else
    echo "❌ Tests failed. Check test.log for details:"
    tail -n 20 test.log
fi

# Test 3: Check for logging output
echo ""
echo "3. 📋 Checking for Logging Output..."
if grep -q "🧪" test.log; then
    echo "✅ Logging emojis found in test output!"
    echo ""
    echo "📝 Sample logging output:"
    grep "🧪\|✅\|➕\|🔍" test.log | head -n 5
else
    echo "⚠️  No logging emojis found in output"
fi

echo ""
echo "🎉 Integration test complete!"
echo ""
echo "📱 To see the full logging experience:"
echo "1. Run the app in simulator (Cmd+R)"
echo "2. Tap 'Initialize Repository & Add Sample Exercises'"
echo "3. Watch the Activity Log section populate with real-time logging"
echo "4. Tap 'Load All Exercises' to see more logging"
echo ""
echo "🔍 For detailed console output:"
echo "- Open Console.app"
echo "- Filter by your app name to see os.log output"
echo "- Look for messages with 🚀 🧪 ✅ ➕ 🔍 emojis"