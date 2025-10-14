#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'chaotic-aur' feature with installPackages option.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# Check that chaotic-aur is configured
check "chaotic-aur configured" grep -q "^\[chaotic-aur\]" /etc/pacman.conf

# Check that chaotic-keyring is installed
check "chaotic-keyring installed" pacman -Qi chaotic-keyring

# Check that chaotic-mirrorlist is installed
check "chaotic-mirrorlist installed" pacman -Qi chaotic-mirrorlist

# Check that the specified package (micro) is installed
# Note: micro is a small text editor available in chaotic-aur
check "package micro installed" pacman -Qi micro

# Check that the package binary is available
check "micro binary exists" command -v micro

# Check that we can query chaotic-aur packages
check "can query chaotic-aur packages" pacman -Sl chaotic-aur

# Check that pacman can search in chaotic-aur
check "can search in chaotic-aur" pacman -Ss --repo chaotic-aur

# Report result
reportResults