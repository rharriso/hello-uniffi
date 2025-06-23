# 🏋️ iOS Integration Guide

This guide shows how to manually configure Xcode to work with the Rust weightlifting core library after the bindings have been generated.

## 📋 Prerequisites

Before following this guide, ensure you have:

✅ **Generated bindings**: Run `make bindings` from project root
✅ **Shared folder exists**: `ios/WeightliftingApp/Shared/` with FFI files
✅ **Xcode project**: `WeightliftingApp.xcodeproj` ready to configure

## 🚀 Manual Xcode Configuration Steps

### Step 1: Add Shared Folder to Xcode Project

1. **Open Xcode**: `open ios/WeightliftingApp/WeightliftingApp.xcodeproj`
2. **In Project Navigator** (left sidebar), right-click on **"WeightliftingApp"** folder (the blue one with app icon)
3. **Select** "Add Files to WeightliftingApp"
4. **Navigate to** and select the **`Shared`** folder (in same directory as .xcodeproj)
5. **IMPORTANT**: Make sure **"Create groups"** is selected (not "Create folder references")
6. **IMPORTANT**: Make sure **"WeightliftingApp"** target is checked (uncheck "WeightliftingAppTests")
7. **Click** "Add"

### Step 2: Configure Bridging Header

1. **Create bridging header file**: In Xcode, right-click **"WeightliftingApp"** folder → **"New File"** → **"Header File"**
2. **Name it**: `WeightliftingApp-Bridging-Header.h`
3. **Replace contents** with:
   ```objc
   #ifndef WeightliftingApp_Bridging_Header_h
   #define WeightliftingApp_Bridging_Header_h

   #import "../Shared/weightlifting_coreFFI.h"

   #endif
   ```
4. **Configure bridging header in build settings**:
   - Select **WeightliftingApp** target
   - Go to **"Build Settings"**
   - Search for **"Objective-C Bridging Header"**
   - Set value to: `WeightliftingApp/WeightliftingApp-Bridging-Header.h`

### Step 3: Configure Test Target Bridging Header

1. **Select WeightliftingAppTests** target
2. **In Build Settings**, search for **"Objective-C Bridging Header"**
3. **Set same value**: `WeightliftingApp/WeightliftingApp-Bridging-Header.h`

### Step 4: Add Static Library to Both Targets

1. **Select WeightliftingApp** target
2. **Go to "Build Phases"** tab
3. **Expand "Link Binary With Libraries"**
4. **Click "+"** → **"Add Other..."** → **"Add Files..."**
5. **Navigate to** `Shared/libweightlifting_core.a` and add it
6. **Repeat for WeightliftingAppTests** target

## ✅ Verification Steps

### Build and Test

1. **Clean build folder**: `⌘ + Shift + K`
2. **Build project**: `⌘ + B` - should build without errors
3. **Run tests**: `⌘ + U` - should pass 12+ tests
4. **Run app**: `⌘ + R` - should show UI with working buttons

### Expected Build Output

When building, you should see:
- ✅ Swift compilation of `weightlifting_core.swift` from Shared folder
- ✅ Bridging header being processed (`-import-objc-header`)
- ✅ Static library linking successfully
- ✅ No FFI type errors (like `RustBuffer not found`)

## 🎯 What This Configuration Achieves

- **FFI Types Available**: `RustBuffer`, `ForeignBytes`, `RustCallStatus` accessible in Swift
- **Module Integration**: Swift can call Rust functions through generated bindings
- **Error Handling**: Proper error propagation from Rust to Swift
- **Memory Management**: Correct FFI memory handling across language boundary
- **Testing Support**: Both app and test targets can use Rust functionality

## 🧪 Testing Integration

### Automated Testing
```bash
# From project root after Xcode configuration
make test-ios   # Runs comprehensive test suite
```

### Manual Testing in Xcode
1. **Build** the project (⌘+B) - should complete without errors
2. **Run tests** (⌘+U) - should see 12+ passing tests
3. **Run app** (⌘+R) - should show functional UI

## 📱 Expected App Behavior

When you run the app:

1. **On Launch**:
   - Rust logging initializes automatically
   - Activity log shows "🚀 iOS app started, initializing Rust library..."

2. **Initialize Repository Button**:
   - Creates in-memory SQLite database
   - Adds 3 sample exercises (Push-ups, Squats, Deadlift)
   - Shows real-time logging in Activity Log section

3. **Load All Exercises Button**:
   - Retrieves all exercises from repository
   - Displays them in the list below
   - Shows logging for each operation

## 🔍 Logging Features

### Visual Logging
- **Activity Log** section in app shows timestamped entries
- **Emoji-coded** messages for easy identification
- **Real-time** updates as operations occur

### Console Logging
- **Console.app**: Filter by "WeightliftingApp" to see os.log output
- **Xcode Console**: Shows during debugging
- **Comprehensive** coverage of all Rust operations

### Logging Emoji Guide
- 🚀 **Startup/Initialization**
- 🧪 **Test Operations**
- ✅ **Success Messages**
- ❌ **Error Messages**
- ➕ **Adding Data**
- 🔍 **Querying Data**
- 🗑️ **Deleting Data**
- 📊 **Statistics/Counts**
- 🏗️ **Repository Operations**
- 💾 **Database Operations**

## 📊 Test Coverage

### 15+ Comprehensive Tests
1. **Repository Creation** (in-memory, file-based)
2. **Exercise Models** (creation, validation)
3. **CRUD Operations** (add, get, update, delete)
4. **Error Handling** (non-existent records, duplicates)
5. **Complete Workflows** (end-to-end scenarios)
6. **Performance Tests** (bulk operations)

### Test Logging
- Each test logs its progress with emojis
- Setup/teardown operations logged
- Detailed operation tracking
- Success/failure reporting

## 🎯 Success Indicators

✅ **Build succeeds** without errors
✅ **All tests pass** (15+ tests)
✅ **App launches** and shows UI
✅ **Buttons work** and trigger logging
✅ **Activity log** populates with messages
✅ **Exercises appear** in the list
✅ **Console shows** Rust library output

## 🐛 Troubleshooting

### Build Errors
- **`RustBuffer not found`**: Bridging header not configured correctly
- **`Module not found`**: Shared folder not added to project or wrong target
- **Linker errors**: Static library not added to "Link Binary With Libraries"

### Configuration Issues
- **Tests fail**: Test target may not have bridging header configured
- **Type conflicts**: Shared folder added to both targets (should only be in app target)
- **Import errors**: Bridging header path incorrect

### Quick Fixes
1. **Clean and rebuild**: `⌘ + Shift + K` then `⌘ + B`
2. **Check targets**: Shared folder should only be in WeightliftingApp target
3. **Verify bridging header**: Path should be `WeightliftingApp/WeightliftingApp-Bridging-Header.h`
4. **Regenerate bindings**: Run `make bindings` from project root

## 🔄 Rebuilding Components

If you modify the Rust library and need to update the iOS integration:

```bash
# From project root - recommended
make bindings   # Rebuilds iOS library and regenerates Swift bindings

# Or from shared/ directory
cd shared
make ios-bindings   # Builds iOS simulator library and copies everything
```

### Manual rebuild (if needed):
```bash
cd shared
cargo build --release --target aarch64-apple-ios-sim
uniffi-bindgen generate src/weightlifting_core.udl --language swift --out-dir ../ios/WeightliftingApp/Shared/
cp target/aarch64-apple-ios-sim/release/libweightlifting_core.a ../ios/WeightliftingApp/Shared/
```

## 🏆 Final Result

You now have a complete iOS app that:
- Uses a Rust core library for business logic
- Shows comprehensive logging of all operations
- Has full test coverage with detailed logging
- Demonstrates real-time FFI integration
- Provides a modern SwiftUI interface

The logging system gives you complete visibility into what the Rust library is doing, making it perfect for debugging and understanding the integration!