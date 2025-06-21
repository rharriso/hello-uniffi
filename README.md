# Weightlifting Core

A minimal cross-platform Rust library for weightlifting applications, providing shared model and repository layers for iOS and Android using UniFFI.

## Features

- **Cross-platform**: Single Rust codebase compiles to both iOS (Swift) and Android (Kotlin)
- **Exercise Management**: Simple Exercise model with CRUD operations
- **SQLite Backend**: Persistent storage with connection pooling using r2d2
- **UniFFI Integration**: Automatic binding generation for Swift and Kotlin
- **Comprehensive Testing**: Full test suite with in-memory and file-based testing

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   iOS (Swift)   │    │ Android (Kotlin)│
├─────────────────┤    ├─────────────────┤
│  Swift Bindings │    │ Kotlin Bindings │
├─────────────────┤    ├─────────────────┤
│                 │    │                 │
│    Rust Core Library (UniFFI)         │
│                                        │
│  ┌─────────────┐  ┌─────────────────┐  │
│  │   Models    │  │   Repository    │  │
│  │             │  │                 │  │
│  │  Exercise   │  │ ExerciseRepo    │  │
│  └─────────────┘  └─────────────────┘  │
│                                        │
│           SQLite Database              │
│        (with connection pooling)       │
└────────────────────────────────────────┘
```

## Prerequisites

- **Rust** (latest stable version)
- **iOS Development**: Xcode and iOS SDK
- **Android Development**: Android NDK
- **UniFFI CLI**: For binding generation

## Quick Start

### 1. Setup

```bash
# Clone the repository
git clone <repository-url>
cd weightlifting-core

# Make build script executable
chmod +x build.sh

# Setup Rust targets and run full build
./build.sh
```

### 2. Alternative Setup (using Makefile)

```bash
# Setup targets
make setup

# Run tests
make test

# Build everything
make all
```

## Build Options

### Using Shell Script

```bash
# Full build pipeline
./build.sh

# Quick development build
./build.sh --quick

# Build for specific platforms
./build.sh --ios
./build.sh --android

# Generate bindings only
./build.sh --bindings
./build.sh --swift
./build.sh --kotlin

# Clean build artifacts
./build.sh --clean
```

### Using Makefile

```bash
# Development cycle
make dev          # Debug build
make test         # Run tests
make quick        # Test + debug build

# Platform-specific builds
make build-ios    # iOS static library
make build-android # Android dynamic library

# Generate bindings
make swift-bindings
make kotlin-bindings
make bindings     # Both Swift and Kotlin

# Code quality
make check        # Linting and formatting check
make fmt          # Format code

# CI pipeline
make ci           # Full CI pipeline
```

## Usage Examples

### Rust

```rust
use weightlifting_core::{Exercise, create_in_memory_repository};

// Create a repository
let repo = create_in_memory_repository()?;

// Create an exercise
let exercise = Exercise::new(
    "Push-up".to_string(),
    Some("Basic bodyweight exercise".to_string()),
    vec!["Chest".to_string(), "Triceps".to_string()],
    None,
    3,
);

// Add to repository
repo.add_exercise(exercise.clone())?;

// Retrieve exercise
let retrieved = repo.get_exercise(exercise.id.clone())?;
println!("Exercise: {} - Difficulty: {}", retrieved.name, retrieved.difficulty_level);
```

### Swift (iOS)

```swift
import WeightliftingCore

do {
    // Create repository
    let repo = try createInMemoryRepository()

    // Create exercise
    let exercise = Exercise(
        id: UUID().uuidString,
        name: "Push-up",
        description: "Basic bodyweight exercise",
        muscleGroups: ["Chest", "Triceps"],
        equipmentNeeded: nil,
        difficultyLevel: 3
    )

    // Add exercise
    try repo.addExercise(exercise: exercise)

    // Retrieve exercise
    let retrieved = try repo.getExercise(id: exercise.id)
    print("Exercise: \(retrieved.name) - Difficulty: \(retrieved.difficultyLevel)")

} catch {
    print("Error: \(error)")
}
```

### Kotlin (Android)

```kotlin
import uniffi.weightlifting_core.*

try {
    // Create repository
    val repo = createInMemoryRepository()

    // Create exercise
    val exercise = Exercise(
        id = UUID.randomUUID().toString(),
        name = "Push-up",
        description = "Basic bodyweight exercise",
        muscleGroups = listOf("Chest", "Triceps"),
        equipmentNeeded = null,
        difficultyLevel = 3u
    )

    // Add exercise
    repo.addExercise(exercise)

    // Retrieve exercise
    val retrieved = repo.getExercise(exercise.id)
    println("Exercise: ${retrieved.name} - Difficulty: ${retrieved.difficultyLevel}")

} catch (e: WeightliftingException) {
    println("Error: ${e}")
}
```

## Generated Files

After running the build, you'll find:

### iOS Files
- `target/universal-ios/release/libweightlifting_core.a` - Universal static library
- `bindings/swift/WeightliftingCore.swift` - Swift bindings
- `bindings/swift/weightlifting_coreFFI.h` - C header file

### Android Files
- `target/aarch64-linux-android/release/libweightlifting_core.so` - ARM64 library
- `target/armv7-linux-androideabi/release/libweightlifting_core.so` - ARMv7 library
- `target/x86_64-linux-android/release/libweightlifting_core.so` - x86_64 library
- `target/i686-linux-android/release/libweightlifting_core.so` - x86 library
- `bindings/kotlin/uniffi/` - Kotlin bindings

## Testing

```bash
# Run all tests
cargo test

# Run specific test
cargo test test_exercise_creation

# Run tests with output
cargo test -- --nocapture
```

## API Reference

### Exercise Model

```rust
pub struct Exercise {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub muscle_groups: Vec<String>,
    pub equipment_needed: Option<String>,
    pub difficulty_level: u8, // 1-10 scale
}
```

### ExerciseRepository Methods

- `add_exercise(exercise: Exercise)` - Add a new exercise
- `get_exercise(id: String)` - Get exercise by ID
- `get_all_exercises()` - Get all exercises (sorted by name)
- `delete_exercise(id: String)` - Delete exercise by ID

### Error Handling

The library uses a custom `WeightliftingError` enum for error handling:

- `DatabaseError` - SQLite database errors
- `ExerciseNotFound` - Exercise not found by ID
- `InvalidInput` - Invalid input data
- `PoolError` - Connection pool errors

## Integration

### iOS Integration

1. Add the generated static library to your Xcode project
2. Import the Swift bindings file
3. Add the C header to your bridging header if needed

### Android Integration

1. Add the generated `.so` files to your `jniLibs` directory
2. Import the Kotlin bindings into your project
3. Initialize the library in your Application class

## Development

### Project Structure

```
├── src/
│   ├── lib.rs           # Main library file
│   ├── models.rs        # Exercise model
│   ├── repository.rs    # Repository implementation
│   └── error.rs         # Error types
├── tests/
│   └── integration_tests.rs  # Integration tests
├── weightlifting_core.udl    # UniFFI interface definition
├── build.rs             # Build script
├── Cargo.toml          # Dependencies
├── Makefile            # Build automation
├── build.sh            # Cross-platform build script
└── README.md           # This file
```

### Adding New Features

1. Update the Rust code in `src/`
2. Update the UniFFI interface in `weightlifting_core.udl`
3. Add tests in `tests/`
4. Rebuild and regenerate bindings

### Contributing

1. Run tests: `make test`
2. Check formatting: `make check`
3. Format code: `make fmt`
4. Build all targets: `make ci`

## Troubleshooting

### Common Issues

1. **Android NDK not found**: Set `ANDROID_NDK_HOME` environment variable
2. **iOS targets missing**: Run `./build.sh --setup` to install targets
3. **UniFFI binding generation fails**: Ensure libraries are built first
4. **lipo command not found**: Install Xcode command line tools on macOS

### Debug Build

For development, use debug builds which are faster to compile:

```bash
cargo build  # Debug build
./build.sh --quick  # Quick development cycle
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Future Enhancements

- [ ] Workout model and repository
- [ ] Set model and repository
- [ ] Progress tracking
- [ ] Data synchronization
- [ ] Offline support
- [ ] Export/import functionality