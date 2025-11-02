.PHONY: help build-cpp run-cpp clean-cpp install test-cpp compile-contracts deploy test-contracts all clean

# Default target
help:
	@echo "DEX Trading Engine - Available Commands:"
	@echo ""
	@echo "C++ Commands:"
	@echo "  make build-cpp         - Build C++ matching engine"
	@echo "  make run-cpp          - Run C++ demo"
	@echo "  make clean-cpp        - Clean C++ build files"
	@echo "  make test-cpp         - Run C++ tests"
	@echo ""
	@echo "Smart Contract Commands:"
	@echo "  make install          - Install npm dependencies"
	@echo "  make compile-contracts - Compile Solidity contracts"
	@echo "  make deploy           - Deploy contracts to local network"
	@echo "  make test-contracts   - Run contract tests"
	@echo ""
	@echo "Shortcuts:"
	@echo "  make all              - Build everything (C++ + contracts)"
	@echo "  make clean            - Clean all build files"

# Install dependencies
install:
	@echo "Installing npm dependencies..."
	npm install

# Build C++ components
build-cpp:
	@echo "Building C++ matching engine..."
	@mkdir -p build
	@cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make

# Run C++ demo
run-cpp: build-cpp
	@echo "Running C++ demo..."
	@cd build && ./dex_demo

# Clean C++ build
clean-cpp:
	@echo "Cleaning C++ build files..."
	@rm -rf build

# Compile smart contracts
compile-contracts:
	@echo "Compiling Solidity contracts..."
	npm run compile

# Deploy contracts
deploy:
	@echo "Deploying contracts..."
	npm run deploy

# Run contract tests
test-contracts:
	@echo "Running contract tests..."
	npm test

# Build everything
all: install build-cpp
	@echo "Building all components..."

# Clean everything
clean: clean-cpp
	@echo "Cleaning all build artifacts..."
	@rm -rf node_modules contracts/artifacts contracts/cache

# Development shortcuts
dev-cpp: clean-cpp
	@echo "Building C++ in debug mode..."
	@mkdir -p build-debug
	@cd build-debug && cmake -DCMAKE_BUILD_TYPE=Debug .. && make
	@echo "Running with debug symbols..."
	@cd build-debug && ./dex_demo

# Quick test
quick-test: build-cpp run-cpp
	@echo "Quick test completed!"

# Show project stats
stats:
	@echo "Project Statistics:"
	@echo "C++ files:"
	@find cpp -name "*.cpp" -o -name "*.hpp" | wc -l
	@echo "Solidity files:"
	@find contracts/src -name "*.sol" | wc -l
	@echo "JavaScript files:"
	@find web3 -name "*.js" | wc -l
	@echo ""
	@echo "Lines of code:"
	@echo "C++:"
	@find cpp -name "*.cpp" -o -name "*.hpp" | xargs wc -l | tail -1
	@echo "Solidity:"
	@find contracts/src -name "*.sol" | xargs wc -l | tail -1
	@echo "JavaScript:"
	@find web3 -name "*.js" | xargs wc -l | tail -1
