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

# Test components are installed
check "clippy component installed" rustup component list --installed | grep -q clippy
check "rustfmt component installed" rustup component list --installed | grep -q rustfmt

# Test clippy and rustfmt executables
check "clippy executable exists" command -v cargo-clippy
check "rustfmt executable exists" command -v rustfmt

# Test additional targets
check "wasm32-unknown-unknown target installed" rustup target list --installed | grep -q "wasm32-unknown-unknown"

# Test global crates
CARGO_BIN_PATH="${CARGO_HOME:-$HOME/.cargo}/bin"
check "cargo-watch installed" bash -c 'PATH="$CARGO_BIN_PATH:$PATH" cargo watch --version'
check "cargo-audit installed" bash -c 'PATH="$CARGO_BIN_PATH:$PATH" cargo audit --version'

# Test PATH configuration (cargo should be available)
check "cargo available in PATH" command -v cargo

# Test that we can create and build a comprehensive Rust project
check "create new cargo project" cargo new test_full_project --bin

cd test_full_project

# Test that global crates are installed (including ripgrep and fd-find)
CARGO_BIN_PATH="${CARGO_HOME:-$HOME/.cargo}/bin"
check "ripgrep installed" test -f "$CARGO_BIN_PATH/rg"
check "fd-find installed" test -f "$CARGO_BIN_PATH/fd"

# Test building a simple project
check "build full project" cargo build

# Test running the project
check "run full project" cargo run | grep -q "Hello, world!"

# Test clippy on the project
check "clippy works on full project" cargo clippy

# Test rustfmt on the project
check "rustfmt works on full project" cargo fmt --check

# Test building for WebAssembly target
check "build for wasm32-unknown-unknown" cargo build --target wasm32-unknown-unknown

# Test global crates
check "cargo-audit works" bash -c 'PATH="$CARGO_BIN_PATH:$PATH" cargo audit --version'

# Clean up
cd ..
rm -rf test_full_project

# Report result
reportResults