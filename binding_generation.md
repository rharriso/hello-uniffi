# Language Binding Generation Guide

This guide explains how to generate Swift and Kotlin bindings from the Rust library using UniFFI.

## Prerequisites

1. Build the Rust library first:
   ```bash
   cargo build --release
   ```

2. Ensure you have the UniFFI CLI tool (uniffi-bindgen) available.

## Method 1: Using a Custom Binary

Create a simple binary to help with binding generation:

```rust
// In a file called `bindgen.rs`
fn main() {
    uniffi::uniffi_bindgen_main()
}
```

Then add to your `Cargo.toml`:
```toml
[[bin]]
name = "bindgen"
path = "bindgen.rs"
```

## Method 2: Using Python uniffi-bindgen

1. Install the Python version:
   ```bash
   pip install uniffi-bindgen
   ```

2. Generate Swift bindings:
   ```bash
   uniffi-bindgen generate src/weightlifting_core.udl --language swift --out-dir bindings/swift
   ```

3. Generate Kotlin bindings:
   ```bash
   uniffi-bindgen generate src/weightlifting_core.udl --language kotlin --out-dir bindings/kotlin
   ```

## Method 3: Using build.rs

Add this to your `build.rs` to generate bindings during build:

```rust
fn main() {
    // Generate scaffolding
    uniffi::generate_scaffolding("src/weightlifting_core.udl").unwrap();

    // Optionally generate bindings during build
    // Note: This requires additional setup for each target language
}
```

## Method 4: Manual Generation

For development and testing, you can generate bindings manually:

1. Ensure your UDL file (`src/weightlifting_core.udl`) is correct
2. Build your library: `cargo build --release`
3. Use the generated library files to create bindings

### Swift Bindings
- Library: `target/release/libweightlifting_core.a` (static library)
- Header: Generated automatically
- Swift file: Generated from UDL

### Kotlin Bindings
- Library: `target/release/libweightlifting_core.so` (dynamic library)
- JAR: Generated from UDL
- Kotlin files: Generated from UDL

## File Locations After Generation

### Swift (iOS)
- `bindings/swift/weightlifting_core.swift`
- `bindings/swift/weightlifting_coreFFI.h`
- Static library: `target/release/libweightlifting_core.a`

### Kotlin (Android)
- `bindings/kotlin/weightlifting_core/weightlifting_core.kt`
- `bindings/kotlin/weightlifting_core.jar`
- Dynamic libraries: `target/<target>/release/libweightlifting_core.so`

## Cross-Platform Build Targets

### iOS Targets
```bash
rustup target add aarch64-apple-ios        # iOS ARM64
rustup target add x86_64-apple-ios         # iOS Simulator (Intel)
rustup target add aarch64-apple-ios-sim    # iOS Simulator (ARM64)
```

### Android Targets
```bash
rustup target add aarch64-linux-android    # ARM64
rustup target add armv7-linux-androideabi  # ARMv7
rustup target add i686-linux-android       # x86
rustup target add x86_64-linux-android     # x86_64
```

## Example Build Commands

### iOS
```bash
cargo build --release --target aarch64-apple-ios
cargo build --release --target x86_64-apple-ios
cargo build --release --target aarch64-apple-ios-sim

# Create universal library
lipo -create \
  target/aarch64-apple-ios/release/libweightlifting_core.a \
  target/x86_64-apple-ios/release/libweightlifting_core.a \
  target/aarch64-apple-ios-sim/release/libweightlifting_core.a \
  -output target/universal/libweightlifting_core.a
```

### Android
```bash
cargo build --release --target aarch64-linux-android
cargo build --release --target armv7-linux-androideabi
cargo build --release --target i686-linux-android
cargo build --release --target x86_64-linux-android
```

## Integration

### iOS Integration
1. Add the generated `.a` file to your Xcode project
2. Import the generated Swift bindings
3. Add the header file to your bridging header if needed

### Android Integration
1. Add the generated `.so` files to your `jniLibs` directory
2. Import the generated Kotlin bindings
3. Initialize the library in your Application class

## Troubleshooting

1. **"Cannot find uniffi-bindgen"**: Install it via pip or use the Rust crate directly
2. **"UDL file not found"**: Ensure the path in build.rs is correct
3. **"Library not found"**: Build the library first with `cargo build --release`
4. **"Architecture mismatch"**: Ensure you're building for the correct target platform

For more details, see the main README.md file.