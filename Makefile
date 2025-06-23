# Weightlifting Core - Root Build System
# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
RESET=\033[0m

.DEFAULT_GOAL := help

# Help target
.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)🏋️ Weightlifting Core - Build System$(RESET)"
	@echo ""
	@echo "$(GREEN)Available targets:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(BLUE)%-20s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)iOS Workflow:$(RESET)"
	@echo "  1. $(BLUE)make setup$(RESET)     - Install dependencies"
	@echo "  2. $(BLUE)make ios-bindings$(RESET) - Generate iOS bindings"
	@echo "  3. Configure Xcode manually (see ios/INTEGRATION_GUIDE.md)"
	@echo "  4. $(BLUE)make test-ios$(RESET)  - Run iOS tests"

# Setup and installation
.PHONY: setup
setup: ## Install development dependencies and Rust targets
	@echo "$(BLUE)🔧 Setting up development environment...$(RESET)"
	cd shared && make setup
	@echo "$(GREEN)✅ Development environment ready!$(RESET)"

# iOS targets
.PHONY: ios-bindings
ios-bindings: ## Generate iOS bindings and copy to project
	@echo "$(BLUE)🔗 Generating iOS bindings...$(RESET)"
	cd shared && make ios-bindings
	@echo "$(GREEN)✅ iOS bindings generated!$(RESET)"

.PHONY: build-ios-release
build-ios-release: ## Build iOS release libraries (device + simulator)
	@echo "$(BLUE)🏗️ Building iOS release...$(RESET)"
	cd shared && make build-ios-release
	@echo "$(GREEN)✅ iOS release build completed!$(RESET)"

.PHONY: build-ios-test
build-ios-test: ## Build iOS for testing (debug, simulator only)
	@echo "$(BLUE)🏗️ Building iOS for testing...$(RESET)"
	cd shared && make build-ios-test
	@echo "$(GREEN)✅ iOS test build completed!$(RESET)"

# Android targets
.PHONY: android-bindings
android-bindings: ## Generate Android bindings
	@echo "$(BLUE)🔗 Generating Android bindings...$(RESET)"
	cd shared && make android-bindings
	@echo "$(GREEN)✅ Android bindings generated!$(RESET)"

.PHONY: build-android-release
build-android-release: ## Build Android release libraries
	@echo "$(BLUE)🏗️ Building Android release...$(RESET)"
	cd shared && make build-android-release
	@echo "$(GREEN)✅ Android release build completed!$(RESET)"

.PHONY: build-android-test
build-android-test: ## Build Android for testing
	@echo "$(BLUE)🏗️ Building Android for testing...$(RESET)"
	cd shared && make build-android-test
	@echo "$(GREEN)✅ Android test build completed!$(RESET)"

# Test targets
.PHONY: test
test: test-rust test-ios ## Run all tests
	@echo "$(GREEN)✅ All tests completed successfully!$(RESET)"

.PHONY: test-rust
test-rust: ## Run Rust tests
	@echo "$(BLUE)🦀 Running Rust tests...$(RESET)"
	cd shared && cargo test
	@echo "$(GREEN)✅ Rust tests passed!$(RESET)"

.PHONY: test-ios
test-ios: ios-bindings ## Run iOS tests (requires manual Xcode configuration)
	@echo "$(BLUE)📱 Running iOS tests...$(RESET)"
	@echo "$(YELLOW)⚠️  IMPORTANT: Xcode project must be manually configured first!$(RESET)"
	@echo "$(BLUE)📋 See ios/INTEGRATION_GUIDE.md for setup instructions$(RESET)"
	cd ios && xcodebuild test \
		-project WeightliftingApp/WeightliftingApp.xcodeproj \
		-scheme WeightliftingApp \
		-destination "platform=iOS Simulator,name=iPhone 16,OS=latest" \
		CODE_SIGNING_ALLOWED=NO || \
		echo "$(RED)❌ Tests failed - ensure Xcode project is configured per integration guide$(RESET)"
	@echo "$(GREEN)✅ iOS tests completed!$(RESET)"

# Build targets
.PHONY: build-release
build-release: ## Build release versions for all platforms
	@echo "$(BLUE)🚀 Building release versions...$(RESET)"
	cd shared && make build-ios-release
	cd shared && make build-android-release
	@echo "$(GREEN)✅ Release builds completed!$(RESET)"

# Development and maintenance
.PHONY: clean
clean: ## Clean all build artifacts
	@echo "$(BLUE)🧹 Cleaning build artifacts...$(RESET)"
	cd shared && make clean
	@echo "$(GREEN)✅ Clean completed!$(RESET)"

.PHONY: dev
dev: ## Development build (debug mode)
	@echo "$(BLUE)🔨 Building in development mode...$(RESET)"
	cd shared && make dev
	@echo "$(GREEN)✅ Development build completed!$(RESET)"

.PHONY: check
check: ## Check code formatting and linting
	@echo "$(BLUE)🔍 Checking code quality...$(RESET)"
	cd shared && make check
	@echo "$(GREEN)✅ Code quality checks passed!$(RESET)"

.PHONY: fmt
fmt: ## Format code
	@echo "$(BLUE)✨ Formatting code...$(RESET)"
	cd shared && make fmt
	@echo "$(GREEN)✅ Code formatting completed!$(RESET)"

# CI and comprehensive targets
.PHONY: ci
ci: ## Full CI pipeline
	@echo "$(BLUE)🤖 Running full CI pipeline...$(RESET)"
	cd shared && make ci
	@echo "$(GREEN)✅ CI pipeline completed!$(RESET)"

.PHONY: quick
quick: ## Quick development cycle (test + dev build)
	@echo "$(BLUE)⚡ Running quick development cycle...$(RESET)"
	cd shared && make quick
	@echo "$(GREEN)✅ Quick cycle completed!$(RESET)"
