#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'chaotic-aur' feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' function is a part of the devcontainer CLI test lib.
# Syntax: check <LABEL> <cmd>

# Check that chaotic-keyring is installed
check "chaotic-keyring installed" pacman -Qi chaotic-keyring

# Check that chaotic-mirrorlist is installed
check "chaotic-mirrorlist installed" pacman -Qi chaotic-mirrorlist

# Check that chaotic-aur is configured in pacman.conf
check "chaotic-aur in pacman.conf" grep -q "^\[chaotic-aur\]" /etc/pacman.conf

# Check that mirrorlist file exists
check "mirrorlist file exists" test -f /etc/pacman.d/chaotic-mirrorlist

# Check that we can query chaotic-aur packages
check "can query chaotic-aur packages" pacman -Sl chaotic-aur

# Check that pacman can search in chaotic-aur
check "can search in chaotic-aur" pacman -Ss --repo chaotic-aur micro

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults