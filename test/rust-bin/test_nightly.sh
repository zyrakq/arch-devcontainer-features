#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test nightly Rust installation
check "rustc version" rustc --version
check "cargo version" cargo --version
check "rustup version" rustup --version

# Test that nightly toolchain is default
check "default toolchain is nightly" bash -c 'rustup default | grep -q nightly'

# Test nightly-specific features work
check "create new cargo project" cargo new test_nightly_project --bin

# Test that we can use nightly features (if any are available)
check "build nightly project" bash -c 'cd test_nightly_project && cargo build'
check "run nightly project" bash -c 'cd test_nightly_project && cargo run | grep -q "Hello, world!"'

# Clean up
rm -rf test_nightly_project

# Report result
reportResults