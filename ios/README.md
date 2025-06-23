# WeightliftingApp iOS

A simple iOS demo app that demonstrates how to use the Rust weightlifting core library through FFI (Foreign Function Interface) bindings.

## 🎯 Purpose

This iOS app serves as a proof-of-concept for integrating the Rust core library into native iOS applications. It demonstrates:

- **FFI Integration**: Using UniFFI-generated Swift bindings to call Rust code
- **Cross-Platform Architecture**: Shared business logic in Rust, platform-specific UI in Swift
- **Complete Testing**: Both unit tests and UI demonstrations of the core functionality

## 🏗️ Architecture

```
ios/
├── WeightliftingApp/
│   ├── WeightliftingApp/
│   │   ├── WeightliftingAppApp.swift    # App entry point
│   │   ├── ContentView.swift            # Main UI demonstrating Rust functionality
│   │   └── Assets.xcassets/             # App icons and assets
│   ├── WeightliftingAppTests/
│   │   └── WeightliftingAppTests.swift  # Comprehensive FFI tests
│   └── Shared/                          # Generated FFI bindings
│       ├── weightlifting_core.swift     # Swift bindings (generated)
│       ├── weightlifting_coreFFI.h      # C header (generated)
│       ├── weightlifting_coreFFI.modulemap # Module map (generated)
│       └── libweightlifting_core.a      # Static Rust library
├── build.sh                             # Automated build script
└── README.md                            # This file
```

## 🚀 Quick Start

### Prerequisites

- **Xcode 15.0+** with iOS 17.0+ SDK
- **Rust toolchain** (for building the shared library)
- **Python 3** with `uniffi-bindgen` installed

### Building and Running

1. **Generate bindings and library** (from project root):
   ```bash
   make setup      # Install dependencies and iOS targets
   make bindings   # Generate Swift bindings + iOS library
   ```

2. **Configure Xcode manually** (one-time setup):
   - Open Xcode: `open ios/WeightliftingApp/WeightliftingApp.xcodeproj`
   - Follow the manual configuration steps in [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
   - This includes adding the Shared folder, setting up the bridging header, and configuring build settings

3. **Build and test**:
   ```bash
   make test-ios   # Run iOS tests
   make build-ios  # Build iOS project
   ```

### ⚠️ Important: Manual Xcode Configuration Required

The iOS project **requires manual Xcode configuration** because:
- **Bridging headers** need to be set in build settings
- **Shared folder** must be added to both app and test targets correctly
- **Build settings** need specific paths for FFI integration

See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for complete step-by-step instructions.

## 🧪 Testing

The project includes comprehensive tests covering:

### Unit Tests (`WeightliftingAppTests`)

- **Repository Creation**: In-memory and file-based repositories
- **Exercise Model**: CRUD operations and data validation
- **Error Handling**: Proper error propagation from Rust to Swift
- **Complete Workflows**: End-to-end testing of typical use cases
- **Performance Tests**: Measuring FFI call performance

Run tests with:
```bash
# Via build script
./ios/build.sh

# Or directly in Xcode
⌘ + U
```

### UI Demo

The main app provides an interactive demonstration:

1. **Initialize Repository**: Creates an in-memory database
2. **Add Sample Exercises**: Inserts 3 different exercises
3. **Display Exercises**: Shows all exercises with details
4. **Error Handling**: Displays any errors from the Rust layer

## 🔧 Development

### Rebuilding Bindings

If you modify the Rust library, regenerate bindings:

```bash
# From project root - recommended approach
make bindings   # Generates Swift bindings + iOS simulator library

# Or manually from shared/ directory
cd shared
make ios-bindings   # Builds library and copies to iOS project
```

### Alternative Manual Rebuild
```bash
cd shared
cargo build --release --target aarch64-apple-ios-sim
uniffi-bindgen generate src/weightlifting_core.udl --language swift --out-dir ../ios/WeightliftingApp/Shared/
cp target/aarch64-apple-ios-sim/release/libweightlifting_core.a ../ios/WeightliftingApp/Shared/
```

### Project Configuration

The Xcode project is configured with:

- **Library Search Paths**: Points to `../../shared/target/release`
- **Swift Include Paths**: Points to `$(PROJECT_DIR)/Shared`
- **Static Library Linking**: Links `libweightlifting_core.a`
- **Module Map**: Includes C header via `weightlifting_coreFFI.modulemap`

## 📱 App Features

### Main Interface

- **Modern SwiftUI Design**: Clean, intuitive interface
- **Real-time Updates**: Immediate reflection of database changes
- **Error Display**: User-friendly error messages
- **Loading States**: Visual feedback during operations

### Exercise Display

- **Color-coded Difficulty**: Visual difficulty indicators
- **Muscle Group Tags**: Clear categorization
- **Equipment Requirements**: Optional equipment display
- **Detailed Descriptions**: Full exercise information

## 🛠️ Troubleshooting

### Common Issues

1. **Build Failures**:
   - Ensure Rust toolchain is installed: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
   - Install uniffi-bindgen: `pip3 install uniffi-bindgen`

2. **Xcode Errors**:
   - Clean build folder: `⌘ + Shift + K`
   - Reset simulator: Device → Erase All Content and Settings

3. **Library Not Found**:
   - Verify static library exists: `ls -la ios/WeightliftingApp/Shared/libweightlifting_core.a`
   - Rebuild using: `./ios/build.sh`

### Debug Information

Enable verbose logging by modifying the Swift code to print more details about FFI calls and data structures.

## 🔗 Integration Guide

To integrate this pattern into your own iOS project:

1. **Copy the Shared folder** containing bindings and library
2. **Update Xcode project settings**:
   - Add library search paths
   - Include Swift paths
   - Link static library
3. **Import the module**: `import WeightliftingCore` (or your module name)
4. **Use the generated Swift classes**: Direct 1:1 mapping from Rust structs

## 📚 Learn More

- [UniFFI Documentation](https://mozilla.github.io/uniffi-rs/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui/)
- [iOS Testing Guide](https://developer.apple.com/documentation/xctest/)

This iOS app demonstrates the power of using Rust for shared business logic while maintaining native platform experiences!