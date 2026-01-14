#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Feature-specific tests
check "bun is installed" bun --version
check "bun command works" bun --help

# Report results
reportResults
