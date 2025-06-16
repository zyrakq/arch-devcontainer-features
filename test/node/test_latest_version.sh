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

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
