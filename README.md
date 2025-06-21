# 🏋️ Weightlifting Core - Cross-Platform Rust Library

A **minimal yet complete** cross-platform Rust library for weightlifting applications, demonstrating modern Rust development practices with **UniFFI** for seamless iOS and Android integration.

## 🎯 Project Overview

This project showcases a **shared business logic architecture** where core functionality is implemented in Rust and exposed to native mobile platforms through Foreign Function Interface (FFI) bindings.

### Key Features

- **🦀 Rust Core Library**: SQLite-backed exercise repository with connection pooling
- **📱 iOS Integration**: Complete SwiftUI app with comprehensive tests
- **🤖 Android Ready**: Kotlin bindings prepared (future implementation)
- **🔗 UniFFI Bindings**: Automatic generation of platform-specific API wrappers
- **🗄️ SQLite Backend**: r2d2 connection pooling for thread-safe database operations
- **✅ Comprehensive Testing**: Unit tests in Rust, integration tests in iOS

## 📁 Project Structure

```
rust-core-lib-test/
├── 📦 shared/                    # Rust core library
│   ├── src/
│   │   ├── lib.rs               # Main library with UniFFI setup
│   │   ├── models.rs            # Exercise data model
│   │   ├── repository.rs        # SQLite repository implementation
│   │   ├── error.rs             # Custom error types
│   │   └── weightlifting_core.udl # UniFFI interface definition
│   ├── Cargo.toml               # Rust dependencies
│   ├── build.rs                 # Build script for UniFFI
│   ├── Makefile                 # Build automation
│   └── build.sh                 # Cross-platform build script
├── 📱 ios/                      # iOS demonstration app
│   ├── WeightliftingApp/        # Xcode project
│   │   ├── WeightliftingApp/    # Swift UI app
│   │   ├── WeightliftingAppTests/ # Comprehensive FFI tests
│   │   └── Shared/              # Generated bindings + static lib
│   ├── build.sh                 # iOS build automation
│   └── README.md                # iOS-specific documentation
└── README.md                    # This file
```

## 🚀 Quick Start

### Prerequisites

- **Rust toolchain** (`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`)
- **Python 3** with `uniffi-bindgen` (`pip3 install uniffi-bindgen`)
- **iOS Development** (optional): Xcode 15.0+ with iOS 17.0+ SDK

### 1. Run All Tests (Recommended)

```bash
# Run tests for both Rust and iOS from root directory
make test              # Run all tests (Rust + iOS)
make test-rust         # Run only Rust tests
make test-ios          # Run only iOS tests (requires Xcode)
```

### 2. Build Everything

```bash
# Build both Rust library and iOS project
make build             # Build all projects
make build-rust        # Build only Rust library
make build-ios         # Build only iOS project
```

### 3. Development Workflow

```bash
# Complete development workflow
make dev               # Clean, build, and test everything
make status            # Show project status and build info
make help              # See all available commands
```

### 4. Alternative: Individual Project Commands

```bash
# Rust core library
cd shared
cargo test && cargo build --release

# iOS project
./ios/build.sh
open ios/WeightliftingApp/WeightliftingApp.xcodeproj
```

## 🏗️ Architecture

### Shared Rust Core (`/shared`)

The core library implements a complete exercise management system:

```rust
// Exercise model with validation
pub struct Exercise {
    pub id: String,
    pub name: String,
    pub muscle_groups: Vec<String>,
    pub difficulty_level: u8,  // 1-10, clamped automatically
    // ... more fields
}

// Repository with SQLite backend
pub struct ExerciseRepository {
    pool: r2d2::Pool<r2d2_sqlite::SqliteConnectionManager>,
}

impl ExerciseRepository {
    pub fn add_exercise(&self, exercise: Exercise) -> Result<(), WeightliftingError>;
    pub fn get_exercise(&self, id: &str) -> Result<Exercise, WeightliftingError>;
    pub fn get_all_exercises(&self) -> Result<Vec<Exercise>, WeightliftingError>;
    pub fn delete_exercise(&self, id: &str) -> Result<bool, WeightliftingError>;
}
```

### iOS Integration (`/ios`)

A complete SwiftUI app demonstrating the FFI integration:

- **ContentView**: Interactive UI for testing core functionality
- **Comprehensive Tests**: 15+ test cases covering all FFI operations
- **Error Handling**: Proper Swift error propagation from Rust
- **Performance Tests**: Measuring FFI call overhead

## 🧪 Testing Strategy

### Rust Unit Tests (`shared/`)
```bash
cd shared && cargo test
```
- ✅ Exercise model validation
- ✅ In-memory repository CRUD operations
- ✅ File-based database persistence

### iOS Integration Tests (`ios/`)
```bash
./ios/build.sh  # Runs tests automatically
```
- ✅ FFI binding correctness
- ✅ Error propagation from Rust to Swift
- ✅ Memory management across FFI boundary
- ✅ Performance benchmarking
- ✅ Complete workflow testing

## 🔧 Technical Implementation

### UniFFI Integration

The project uses **UniFFI 0.25** for automatic binding generation:

```rust
// weightlifting_core.udl - Interface definition
namespace weightlifting_core {
  ExerciseRepository create_exercise_repository(string db_path);
  ExerciseRepository create_in_memory_repository();
};

dictionary Exercise {
  string id;
  string name;
  sequence<string> muscle_groups;
  u8 difficulty_level;
};
```

### Database Schema

```sql
CREATE TABLE exercises (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    muscle_groups TEXT NOT NULL,  -- JSON array
    equipment_needed TEXT,
    difficulty_level INTEGER NOT NULL
);
```

### Error Handling

Custom error types with automatic UniFFI conversion:

```rust
#[derive(Error, Debug, uniffi::Error)]
pub enum WeightliftingError {
    #[error("Database error: {message}")]
    DatabaseError { message: String },

    #[error("Exercise not found with id: {id}")]
    ExerciseNotFound { id: String },
}
```

## 📊 Performance Characteristics

- **FFI Call Overhead**: ~1-5μs per call (measured in iOS tests)
- **Database Operations**: Optimized with connection pooling
- **Memory Usage**: Minimal heap allocations, efficient JSON serialization
- **Binary Size**: ~2MB static library (release build)

## 🛠️ Development Workflow

### Adding New Features

1. **Update Rust Core**: Modify `shared/src/` files
2. **Update UDL Interface**: Add to `shared/src/weightlifting_core.udl`
3. **Rebuild Bindings**: Run `./ios/build.sh` or `cd shared && make bindings`
4. **Test Integration**: Verify in iOS app and add tests

### Cross-Platform Expansion

The architecture is designed for easy expansion:

- **Android**: Generate Kotlin bindings using the same UDL file
- **Web/WASM**: Compile Rust to WebAssembly
- **Desktop**: Native integration or CLI tools

## 📚 Key Dependencies

### Rust Core
- **UniFFI 0.25**: FFI binding generation
- **rusqlite 0.32**: SQLite database access
- **r2d2_sqlite 0.25**: Connection pooling
- **serde**: Serialization (JSON for muscle_groups)
- **uuid**: Unique ID generation
- **thiserror**: Error handling

### iOS
- **SwiftUI**: Modern declarative UI
- **XCTest**: Comprehensive testing framework

## 🎯 Use Cases

This project demonstrates patterns useful for:

- **Mobile Apps**: Shared business logic across iOS/Android
- **Data Processing**: SQLite-backed applications with Rust performance
- **FFI Integration**: Best practices for Rust ↔ Swift interop
- **Testing Strategies**: Comprehensive cross-language testing

## 🔄 Build Automation

The project includes comprehensive build automation at multiple levels:

### Root-Level Makefile
A unified build system that orchestrates both Rust and iOS projects:

```bash
make help              # Show all available commands
make test              # Run all tests (Rust + iOS)
make build             # Build all projects
make dev               # Complete development workflow
make status            # Show project status
```

### Individual Project Automation
- **`/shared`**: Rust-specific Makefile and build scripts
- **`/ios`**: iOS build script with Xcode integration
- **Shell Scripts**: Cross-platform automation with colored output
- **CI/CD Ready**: All commands designed for automated environments

## 🚀 Getting Started Guide

1. **Clone & Explore**:
   ```bash
   git clone [repository-url]
   cd rust-core-lib-test
   ```

2. **Build Shared Library**:
   ```bash
   cd shared
   cargo test && cargo build --release
   ```

3. **Try iOS Demo**:
   ```bash
   ./ios/build.sh
   open ios/WeightliftingApp/WeightliftingApp.xcodeproj
   ```

4. **Extend for Your Use Case**:
   - Modify the Exercise model in `shared/src/models.rs`
   - Add repository methods in `shared/src/repository.rs`
   - Update the UDL interface in `shared/src/weightlifting_core.udl`
   - Regenerate bindings and test!

## 📖 Documentation

- [`/shared/README.md`](shared/README.md) - Rust library documentation
- [`/ios/README.md`](ios/README.md) - iOS integration guide
- [`/shared/binding_generation.md`](shared/binding_generation.md) - UniFFI binding guide

## 🤝 Contributing

This is a reference implementation showcasing Rust + UniFFI patterns. Feel free to fork and adapt for your specific use cases!

---

**Built with ❤️ using Rust 🦀 and SwiftUI 📱**

*This project demonstrates modern cross-platform development with shared Rust business logic and native platform UIs.*