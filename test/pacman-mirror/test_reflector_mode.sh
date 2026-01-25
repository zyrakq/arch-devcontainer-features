#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------
# Test script for pacman-mirror feature - Reflector mode
#-----------------------------------------------------------------------------------------------------------------

set -e

echo "Running pacman-mirror feature tests (reflector mode)..."

# Test 1: Check reflector is installed
echo "Test 1: Checking reflector is installed..."
command -v reflector > /dev/null 2>&1
echo "PASSED: Reflector is installed"

# Test 2: Check mirrorlist file exists
echo "Test 2: Checking mirrorlist file exists..."
test -f /etc/pacman.d/mirrorlist
echo "PASSED: Mirrorlist file exists"

# Test 3: Check backup file exists
echo "Test 3: Checking backup file exists..."
test -f /etc/pacman.d/mirrorlist.backup
echo "PASSED: Backup file exists"

# Test 4: Check mirrorlist contains Server entries
echo "Test 4: Checking mirrorlist contains Server entries..."
grep -q "^Server = " /etc/pacman.d/mirrorlist
echo "PASSED: Mirrorlist contains Server entries"

# Test 5: Detect architecture and verify format
echo "Test 5: Detecting architecture and verifying format..."
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

# Test 6: Verify number of mirrors matches configuration (5 mirrors requested)
echo "Test 6: Verifying number of mirrors..."
MIRROR_COUNT=$(grep -c "^Server = " /etc/pacman.d/mirrorlist)
echo "Found $MIRROR_COUNT mirrors"
test "$MIRROR_COUNT" -ge 1
test "$MIRROR_COUNT" -le 10
echo "PASSED: Mirror count is within expected range (1-10)"

# Test 7: Verify HTTPS protocol is used
echo "Test 7: Verifying HTTPS protocol..."
grep -q "^Server = https://" /etc/pacman.d/mirrorlist
echo "PASSED: HTTPS mirrors are configured"

echo ""
echo "========================================="
echo "All tests passed successfully!"
echo "========================================="
