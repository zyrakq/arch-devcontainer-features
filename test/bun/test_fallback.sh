#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Feature-specific tests
# This test expects yay to NOT be installed, so it should fallback to pacman
check "bun is installed via fallback" bun --version
check "bun command works" bun --help

# Report results
reportResults
