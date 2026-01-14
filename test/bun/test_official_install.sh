#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Load Bun PATH for official installation
export PATH="$HOME/.bun/bin:$PATH"

# Feature-specific tests
check "bun is installed" bun --version
check "bun command works" bun --help

# Check that .bun directory exists (official installation creates it)
check "bun installed in user home" test -d "$HOME/.bun"

# Report results
reportResults
