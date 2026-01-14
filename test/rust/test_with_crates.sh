#!/bin/bash
set -e
source dev-container-features-test-lib

check "rust version" rustc --version
check "cargo version" cargo --version
check "cargo-watch installed" cargo watch --version
check "cargo-edit installed" cargo upgrade --version

reportResults
