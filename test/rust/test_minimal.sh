#!/bin/bash
set -e
source dev-container-features-test-lib

# Only basic components
check "rust version" rustc --version
check "cargo version" cargo --version

# Clippy and rustfmt are ALWAYS included with rust package
check "clippy available" cargo clippy --version
check "rustfmt available" rustfmt --version

# Should not have optional components
check "no rust-analyzer" bash -c "! command -v rust-analyzer"

reportResults
