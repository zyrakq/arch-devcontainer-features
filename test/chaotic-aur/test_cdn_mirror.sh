#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'chaotic-aur' feature with CDN mirror option.

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

# Check that mirrorlist file exists
check "mirrorlist file exists" test -f /etc/pacman.d/chaotic-mirrorlist

# Check that CDN mirror is configured in mirrorlist
check "CDN mirror configured" grep -q "cdn-mirror.chaotic.cx" /etc/pacman.d/chaotic-mirrorlist

# Check that we can access chaotic-aur repository (limit output to avoid timeout)
check "can access chaotic-aur" pacman -Sl chaotic-aur | head -n 5

# Check that pacman can search in chaotic-aur
check "can search in chaotic-aur" pacman -Ss micro

# Check that backup mirrorlist exists
check "backup mirrorlist exists" test -f /etc/pacman.d/chaotic-mirrorlist.backup

# Report result
reportResults