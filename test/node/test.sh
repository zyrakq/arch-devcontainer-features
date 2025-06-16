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

    # Test NPM_CONFIG_PREFIX environment variable
    check "NPM_CONFIG_PREFIX set" bash -c 'echo $NPM_CONFIG_PREFIX | grep -q "\.npm-global"'

    # Test that we can install a global package without sudo
    check "install global package without sudo" npm install -g cowsay --silent

    # Test that globally installed package is accessible
    check "global package accessible" command -v cowsay

    # Test that we can run the globally installed package
    check "global package works" cowsay "Node.js feature test passed!"
else
    echo "Skipping npm prefix tests for root user."
fi

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
