#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.

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

# Test components based on configuration
INSTALL_CLIPPY="${INSTALLCLIPPY:-true}"
INSTALL_RUSTFMT="${INSTALLRUSTFMT:-true}"

if [ "$INSTALL_CLIPPY" = "true" ]; then
    check "clippy component installed" rustup component list --installed | grep -q clippy
    check "clippy executable exists" command -v cargo-clippy
fi

if [ "$INSTALL_RUSTFMT" = "true" ]; then
    check "rustfmt component installed" rustup component list --installed | grep -q rustfmt
    check "rustfmt executable exists" command -v rustfmt
fi

# Test global crates installation based on configuration
GLOBAL_CRATES="${GLOBALCRATES:-}"
if [ -n "$GLOBAL_CRATES" ]; then
    echo "Global crates configured: $GLOBAL_CRATES"
fi

# Test PATH configuration (cargo should be available)
check "cargo available in PATH" command -v cargo

# Test that we can create and build a simple Rust project
check "create new cargo project" cargo new test_project --bin
check "build cargo project" bash -c 'cd test_project && cargo build'
check "run cargo project" bash -c 'cd test_project && cargo run | grep -q "Hello, world!"'

# Test clippy on the project if installed
if [ "$INSTALL_CLIPPY" = "true" ]; then
    check "clippy works" bash -c 'cd test_project && cargo clippy'
fi

# Test rustfmt on the project if installed
if [ "$INSTALL_RUSTFMT" = "true" ]; then
    check "rustfmt works" bash -c 'cd test_project && cargo fmt --check'
fi

# Clean up test project
rm -rf test_project

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults