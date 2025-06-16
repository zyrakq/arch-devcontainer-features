#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "node version" node --version
check "npm version" npm --version

# Test that Node.js and npm are properly installed
check "node executable exists" command -v node
check "npm executable exists" command -v npm

# Conditional checks for non-root user
if [ "$(id -u)" -ne 0 ]; then
    # Test npm configuration (should be configured for sudo-free global installs)
    check "npm prefix configured" bash -c 'npm config get prefix | grep -q "\.npm-global"'

    # Test that npm global directory exists
    check "npm global directory exists" test -d "$HOME/.npm-global"

    # Test PATH configuration
    check "npm global bin in PATH" bash -c 'echo $PATH | grep -q "\.npm-global/bin"'

    # Test that pre-installed global packages are available
    # From scenarios.json: "globalPackages": "typescript,nodemon"
    check "typescript installed" command -v tsc
    check "nodemon installed" command -v nodemon

    # Test that TypeScript works
    check "typescript version" tsc --version

    # Test that nodemon works
    check "nodemon version" nodemon --version

    # Test that we can still install additional global packages without sudo
    check "install additional global package" npm install -g eslint --silent

    # Test that newly installed package is accessible
    check "eslint accessible" command -v eslint

    # Test that eslint works
    check "eslint version" eslint --version

    # Verify all packages are in the correct global directory
    check "typescript in global dir" test -f "$HOME/.npm-global/bin/tsc"
    check "nodemon in global dir" test -f "$HOME/.npm-global/bin/nodemon"
    check "eslint in global dir" test -f "$HOME/.npm-global/bin/eslint"
else
    echo "Skipping npm prefix and global package tests for root user."
fi

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
