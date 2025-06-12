#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'yay' feature with installPackages option.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "yay is installed" yay --version
check "yay is executable" which yay

# Test that specified packages are installed
# Note: This test assumes the devcontainer.json includes installPackages option
# The actual packages will be defined in scenarios.json

# Test basic yay functionality
check "yay can query installed packages" yay -Q

# Test that yay can search without installing
check "yay search works" yay -Ss vim --noconfirm

# Test user permissions for package operations
check "user can query packages" sudo -u $(whoami) yay -Q

# Report result
reportResults
