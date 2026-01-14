#!/bin/bash
set -e
source dev-container-features-test-lib

# Check basic components
check "rust version" rustc --version
check "cargo version" cargo --version
check "clippy available" cargo clippy --version
check "rustfmt available" rustfmt --version
check "rust-analyzer available" rust-analyzer --version

# Check that this is pacman installation (not rustup)
check "no rustup installed" bash -c "! command -v rustup"

# Check that we can compile simple project
check "can compile hello world" bash -c "cd /tmp && cargo new hello && cd hello && cargo build"

reportResults
