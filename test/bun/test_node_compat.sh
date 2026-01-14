#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Feature-specific tests
check "bun is installed" bun --version

# Check Node.js compatibility shims
check "node command available" command -v node
check "npm command available" command -v npm
check "npx command available" command -v npx

# Verify symlinks point to bun
check "node points to bun" test "$(readlink -f $(which node))" = "$(readlink -f $(which bun))"
check "npm points to bun" test "$(readlink -f $(which npm))" = "$(readlink -f $(which bun))"
check "npx points to bun" test "$(readlink -f $(which npx))" = "$(readlink -f $(which bun))"

# Report results
reportResults
