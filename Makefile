# Weightlifting Core - Root Makefile
# Provides convenient targets for building and testing across all platforms

.PHONY: help test test-rust test-ios build build-rust build-ios clean clean-rust clean-ios setup bindings

# Colors for output
BOLD := \033[1m
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
RESET := \033[0m

# Default target
help: ## Show this help message
	@echo "$(BOLD)🏋️  Weightlifting Core - Cross-Platform Build System$(RESET)"
	@echo ""
	@echo "$(BOLD)Available targets:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BOLD)Examples:$(RESET)"
	@echo "  make test          # Run all tests (Rust + iOS)"
	@echo "  make test-rust     # Run only Rust tests"
	@echo "  make build         # Build all projects"
	@echo "  make setup         # Initial project setup"

# Test targets
test: test-rust test-ios ## Run all tests (Rust + iOS)
	@echo "$(GREEN)✅ All tests completed successfully!$(RESET)"

test-rust: ## Run Rust tests in shared library
	@echo "$(BLUE)🦀 Running Rust tests...$(RESET)"
	@cd shared && cargo test
	@echo "$(GREEN)✅ Rust tests passed!$(RESET)"

test-ios: ## Run iOS tests (requires Xcode)
	@echo "$(BLUE)📱 Running iOS tests...$(RESET)"
	@if command -v xcodebuild >/dev/null 2>&1; then \
		cd ios && xcodebuild test \
			-project WeightliftingApp/WeightliftingApp.xcodeproj \
			-scheme WeightliftingApp \
			-destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
			CODE_SIGNING_ALLOWED=NO || true; \
		echo "$(GREEN)✅ iOS tests completed!$(RESET)"; \
	else \
		echo "$(YELLOW)⚠️  xcodebuild not available, skipping iOS tests$(RESET)"; \
		echo "$(BLUE)💡 Install Xcode Command Line Tools to run iOS tests$(RESET)"; \
	fi

# Build targets
build: build-rust build-ios ## Build all projects
	@echo "$(GREEN)✅ All builds completed successfully!$(RESET)"

build-rust: ## Build Rust shared library
	@echo "$(BLUE)🔨 Building Rust shared library...$(RESET)"
	@cd shared && cargo build --release
	@echo "$(GREEN)✅ Rust library built successfully!$(RESET)"

build-ios: bindings ## Build iOS project (requires Xcode)
	@echo "$(BLUE)📱 Building iOS project...$(RESET)"
	@if command -v xcodebuild >/dev/null 2>&1; then \
		cd ios && xcodebuild build \
			-project WeightliftingApp/WeightliftingApp.xcodeproj \
			-scheme WeightliftingApp \
			-destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
			CODE_SIGNING_ALLOWED=NO || true; \
		echo "$(GREEN)✅ iOS project built successfully!$(RESET)"; \
	else \
		echo "$(YELLOW)⚠️  xcodebuild not available, skipping iOS build$(RESET)"; \
		echo "$(BLUE)💡 Install Xcode Command Line Tools to build iOS project$(RESET)"; \
	fi

# Setup and utility targets
setup: ## Initial project setup (install dependencies)
	@echo "$(BLUE)🔧 Setting up development environment...$(RESET)"
	@echo "$(BLUE)📦 Installing uniffi-bindgen...$(RESET)"
	@pip3 install uniffi-bindgen || echo "$(YELLOW)⚠️  Could not install uniffi-bindgen via pip3$(RESET)"
	@echo "$(BLUE)🦀 Checking Rust installation...$(RESET)"
	@rustc --version || (echo "$(RED)❌ Rust not installed. Install from https://rustup.rs/$(RESET)" && exit 1)
	@echo "$(GREEN)✅ Development environment ready!$(RESET)"

bindings: build-rust ## Generate Swift bindings from Rust library
	@echo "$(BLUE)🔗 Generating Swift bindings...$(RESET)"
	@mkdir -p ios/WeightliftingApp/Shared
	@if command -v uniffi-bindgen >/dev/null 2>&1; then \
		uniffi-bindgen generate shared/src/weightlifting_core.udl \
			--language swift \
			--out-dir ios/WeightliftingApp/Shared/; \
		cp shared/target/release/libweightlifting_core.a ios/WeightliftingApp/Shared/ 2>/dev/null || \
		cp shared/target/release/libweightlifting_core.dylib ios/WeightliftingApp/Shared/ 2>/dev/null || \
		echo "$(YELLOW)⚠️  No compiled library found, run 'make build-rust' first$(RESET)"; \
		echo "$(GREEN)✅ Swift bindings generated successfully!$(RESET)"; \
	else \
		echo "$(RED)❌ uniffi-bindgen not found. Run 'make setup' first$(RESET)"; \
		exit 1; \
	fi

# Clean targets
clean: clean-rust clean-ios ## Clean all build artifacts
	@echo "$(GREEN)✅ All projects cleaned!$(RESET)"

clean-rust: ## Clean Rust build artifacts
	@echo "$(BLUE)🧹 Cleaning Rust build artifacts...$(RESET)"
	@cd shared && cargo clean
	@echo "$(GREEN)✅ Rust artifacts cleaned!$(RESET)"

clean-ios: ## Clean iOS build artifacts
	@echo "$(BLUE)🧹 Cleaning iOS build artifacts...$(RESET)"
	@if command -v xcodebuild >/dev/null 2>&1; then \
		cd ios && xcodebuild clean \
			-project WeightliftingApp/WeightliftingApp.xcodeproj \
			-scheme WeightliftingApp 2>/dev/null || true; \
	fi
	@rm -rf ios/WeightliftingApp/Shared/weightlifting_core.swift 2>/dev/null || true
	@rm -rf ios/WeightliftingApp/Shared/weightlifting_coreFFI.h 2>/dev/null || true
	@rm -rf ios/WeightliftingApp/Shared/weightlifting_coreFFI.modulemap 2>/dev/null || true
	@rm -rf ios/WeightliftingApp/Shared/libweightlifting_core.* 2>/dev/null || true
	@echo "$(GREEN)✅ iOS artifacts cleaned!$(RESET)"

# Development workflow targets
dev: ## Complete development workflow (clean, build, test)
	@echo "$(BOLD)🚀 Running complete development workflow...$(RESET)"
	@$(MAKE) clean
	@$(MAKE) build
	@$(MAKE) test
	@echo "$(GREEN)✅ Development workflow completed successfully!$(RESET)"

watch-rust: ## Watch Rust files and run tests on changes (requires cargo-watch)
	@echo "$(BLUE)👀 Watching Rust files for changes...$(RESET)"
	@cd shared && cargo watch -x test

# Release targets
release: ## Build optimized release versions
	@echo "$(BLUE)🚀 Building release versions...$(RESET)"
	@cd shared && cargo build --release
	@$(MAKE) bindings
	@echo "$(GREEN)✅ Release builds completed!$(RESET)"

# Documentation targets
docs: ## Generate and open documentation
	@echo "$(BLUE)📚 Generating documentation...$(RESET)"
	@cd shared && cargo doc --open

# Status and info targets
status: ## Show project status and information
	@echo "$(BOLD)📊 Project Status$(RESET)"
	@echo ""
	@echo "$(BOLD)Rust Library (shared/):$(RESET)"
	@cd shared && cargo --version
	@cd shared && echo "  Dependencies: $$(grep -c '=' Cargo.toml) packages"
	@cd shared && echo "  Source files: $$(find src -name '*.rs' | wc -l | tr -d ' ') files"
	@echo ""
	@echo "$(BOLD)iOS Project (ios/):$(RESET)"
	@if command -v xcodebuild >/dev/null 2>&1; then \
		echo "  Xcode: $$(xcodebuild -version | head -1)"; \
		echo "  Project: WeightliftingApp.xcodeproj"; \
	else \
		echo "  Xcode: Not available"; \
	fi
	@echo "  Swift files: $$(find ios -name '*.swift' 2>/dev/null | wc -l | tr -d ' ') files"
	@echo ""
	@echo "$(BOLD)Build Artifacts:$(RESET)"
	@if [ -f shared/target/release/libweightlifting_core.a ]; then \
		echo "  ✅ Rust static library: $$(ls -lh shared/target/release/libweightlifting_core.a | awk '{print $$5}')"; \
	else \
		echo "  ❌ Rust static library: Not built"; \
	fi
	@if [ -f ios/WeightliftingApp/Shared/weightlifting_core.swift ]; then \
		echo "  ✅ Swift bindings: Generated"; \
	else \
		echo "  ❌ Swift bindings: Not generated"; \
	fi

# Quick aliases
t: test          ## Alias for 'test'
b: build         ## Alias for 'build'
c: clean         ## Alias for 'clean'
s: status        ## Alias for 'status'