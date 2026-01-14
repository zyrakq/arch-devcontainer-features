#!/bin/bash
set -e
source dev-container-features-test-lib

check "rust version" rustc --version
check "cargo version" cargo --version
check "clippy available" cargo clippy --version
check "rustfmt available" rustfmt --version

# Verify minimal profile doesn't have docs
check "no rust docs (minimal profile)" bash -c "! rustup doc --path 2>/dev/null"

reportResults
