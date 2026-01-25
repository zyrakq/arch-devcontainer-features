#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------
# Test script for pacman-mirror feature - URL mode
#-----------------------------------------------------------------------------------------------------------------

set -e

echo "Running pacman-mirror feature tests (url mode)..."

# Test 1: Check mirrorlist file exists
echo "Test 1: Checking mirrorlist file exists..."
test -f /etc/pacman.d/mirrorlist
echo "PASSED: Mirrorlist file exists"

# Test 2: Check backup file exists
echo "Test 2: Checking backup file exists..."
test -f /etc/pacman.d/mirrorlist.backup
echo "PASSED: Backup file exists"

# Test 3: Check mirrorlist contains Server entries
echo "Test 3: Checking mirrorlist contains Server entries..."
grep -q "^Server = " /etc/pacman.d/mirrorlist
echo "PASSED: Mirrorlist contains Server entries"

# Test 4: Detect architecture and verify format
echo "Test 4: Detecting architecture and verifying format..."
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"

if [ "$ARCH" = "x86_64" ]; then
    # Verify x86_64 format: $repo/os/$arch
    grep -q '\$repo/os/\$arch' /etc/pacman.d/mirrorlist
    echo "PASSED: x86_64 mirror format is correct"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "armv7l" ]; then
    # Verify ARM format: $arch/$repo
    grep -q '\$arch/\$repo' /etc/pacman.d/mirrorlist
    echo "PASSED: ARM mirror format is correct"
else
    echo "WARNING: Unknown architecture: $ARCH"
fi

# Test 5: Verify mirrorlist was downloaded from URL (check for uncommented mirrors)
echo "Test 5: Verifying mirrorlist contains uncommented mirrors from URL..."
UNCOMMENTED_COUNT=$(grep "^Server = " /etc/pacman.d/mirrorlist | wc -l)
test "$UNCOMMENTED_COUNT" -ge 1
echo "PASSED: Mirrorlist has $UNCOMMENTED_COUNT uncommented mirrors"

echo ""
echo "========================================="
echo "All tests passed successfully!"
echo "========================================="
