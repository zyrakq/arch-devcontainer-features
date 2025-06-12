#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'yay' feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' function is a part of the devcontainer CLI test lib.
# Syntax: check <LABEL> <cmd>
check "yay is installed" yay --version
check "yay is executable" which yay
check "yay help works" yay --help

# Test that yay can query packages (without installing)
check "yay can search packages" yay -Ss git --noconfirm

# Test that makepkg is available (required for AUR)
check "makepkg is available" which makepkg

# Test that git is available (required for AUR)
check "git is available" which git

# Test that base-devel group is installed
check "base-devel is installed" pacman -Qi base-devel

# Test user permissions
check "user can run yay" sudo -u $(whoami) yay --version

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
