#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Feature-specific tests
check "bun is installed" bun --version

# Check global packages are installed
# Use bun pm ls -g to list global packages
check "typescript is installed globally" bun pm ls -g | grep typescript
check "esbuild is installed globally" bun pm ls -g | grep esbuild

# Report results
reportResults
