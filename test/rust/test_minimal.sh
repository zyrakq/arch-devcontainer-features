#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test basic Rust installation
check "rustc version" rustc --version
check "cargo version" cargo --version
check "rustup version" rustup --version

# Test that executables exist
check "rustc executable exists" command -v rustc
check "cargo executable exists" command -v cargo
check "rustup executable exists" command -v rustup

# Test default toolchain
check "default toolchain is stable" bash -c 'rustup default | grep -q stable'

# Minimal setup - only basic Rust functionality is tested
# (No additional components or global crates should be installed)
echo "Testing minimal Rust setup - basic functionality only"

# Test PATH configuration (cargo should be available)
check "cargo available in PATH" command -v cargo

# Test that we can still create and build a simple Rust project
check "create new cargo project" cargo new test_minimal_project --bin
check "build cargo project" bash -c 'cd test_minimal_project && cargo build'
check "run cargo project" bash -c 'cd test_minimal_project && cargo run | grep -q "Hello, world!"'

# Clean up test project
rm -rf test_minimal_project

# Report result
reportResults