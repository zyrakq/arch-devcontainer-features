#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "node version" node --version
check "npm version" npm --version

# Test that Yarn is installed and available
check "yarn installed" command -v yarn
check "yarn version" yarn --version

# Test that pnpm is installed and available
check "pnpm installed" command -v pnpm
check "pnpm version" pnpm --version

# Conditional checks for non-root user
if [ "$(id -u)" -ne 0 ]; then
    # Test that Yarn and pnpm are in the correct global directory
    check "yarn in global dir" test -f "$HOME/.npm-global/bin/yarn"
    check "pnpm in global dir" test -f "$HOME/.npm-global/bin/pnpm"
else
    echo "Skipping global directory tests for root user."
fi

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
