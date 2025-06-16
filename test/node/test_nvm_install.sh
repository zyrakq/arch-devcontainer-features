#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "node version" bash -c "source ~/.nvm/nvm.sh && node --version"
check "npm version" bash -c "source ~/.nvm/nvm.sh && npm --version"

# Test that Node.js and npm are properly installed
check "node executable exists" bash -c "source ~/.nvm/nvm.sh && command -v node"
check "npm executable exists" bash -c "source ~/.nvm/nvm.sh && command -v npm"

# Test that nvm is installed and available
check "nvm installed" bash -c "source ~/.nvm/nvm.sh && command -v nvm"

# Test that nvm directory exists
check "nvm directory exists" test -d "$HOME/.nvm"

# Test that the correct Node.js version is installed
# From scenarios.json: "nodeVersion": "18.17.0"
check "correct node version" bash -c 'source ~/.nvm/nvm.sh && node --version | grep -q "v18.17.0"'

# Test that nvm can list installed versions
check "nvm list works" bash -c 'source ~/.nvm/nvm.sh && nvm list | grep -q "18.17.0"'

# Test that the version is set as default
check "correct default version" bash -c 'source ~/.nvm/nvm.sh && nvm version default | grep -q "18.17.0"'

# Conditional checks for non-root user
if [ "$(id -u)" -ne 0 ]; then
    # Test npm configuration (should be configured for sudo-free global installs)
    check "npm prefix configured" bash -c 'source ~/.nvm/nvm.sh && npm config get prefix | grep -q "\.npm-global"'

    # Test that npm global directory exists
    check "npm global directory exists" test -d "$HOME/.npm-global"

    # Test PATH configuration (should include both nvm and npm-global)
    check "npm global bin in PATH" bash -c 'echo $PATH | grep -q "\.npm-global/bin"'

    # Test NPM_CONFIG_PREFIX environment variable
    check "NPM_CONFIG_PREFIX set" bash -c 'echo $NPM_CONFIG_PREFIX | grep -q "\.npm-global"'

    # Test that we can install a global package without sudo
    check "install global package without sudo" bash -c "source ~/.nvm/nvm.sh && npm install -g json-server --silent"

    # Test that globally installed package is accessible
    check "global package accessible" command -v json-server

    # Test that we can run the globally installed package
    check "global package works" json-server --version

    # Test that shell profiles are properly configured
    check "bashrc has nvm config" grep -q "NVM_DIR" "$HOME/.bashrc"
    check "bashrc has npm config" grep -q "npm-global" "$HOME/.bashrc"
else
    echo "Skipping npm prefix tests for root user."
fi

# Test that we can switch Node.js versions with nvm (install another version)
check "install another node version" bash -c 'source ~/.nvm/nvm.sh && nvm install 16.20.0'
check "switch back to default" bash -c 'source ~/.nvm/nvm.sh && nvm use default'
check "still correct version after switch" bash -c 'source ~/.nvm/nvm.sh && node --version | grep -q "v18.17.0"'

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
