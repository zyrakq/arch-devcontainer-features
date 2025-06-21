#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "dotnet version" dotnet --version
check "dotnet executable exists" command -v dotnet

# Test that .NET SDK is properly installed
check "dotnet SDK available" bash -c 'dotnet --list-sdks | grep -q "."'

# Test that .NET runtime is available
check "dotnet runtime available" bash -c 'dotnet --list-runtimes | grep -q "."'

# Verify official packages are installed (not AUR -bin packages)
check "official dotnet package installed" bash -c 'pacman -Q | grep -E "dotnet-(sdk|host)" | grep -v "\-bin"'

# Note: Skipping AUR package checks as they are not critical for functionality

echo "DEBUG: Starting .NET functionality tests..."

# Test basic .NET functionality
echo "DEBUG: About to create console app..."
check "create console app" dotnet new console -n TestApp --force

echo "DEBUG: About to build console app..."
check "build console app" bash -c 'cd TestApp && dotnet build'

echo "DEBUG: About to run console app..."
check "run console app" bash -c 'cd TestApp && dotnet run | grep -q "Hello, World!"'

echo "DEBUG: .NET functionality tests completed."

# Clean up test app
rm -rf TestApp

echo "DEBUG: Starting conditional checks for user $(id -u)..."

# Conditional checks for non-root user
if [ "$(id -u)" -ne 0 ]; then
    echo "DEBUG: Running non-root user tests..."
    # Test dotnet tools PATH configuration
    check "dotnet tools in PATH" bash -c 'echo $PATH | grep -q "\.dotnet/tools"'
    
    # Test that dotnet tools directory exists
    check "dotnet tools directory exists" test -d "$HOME/.dotnet/tools"
    
    # Test that we can list global tools (even if empty)
    check "list global tools" dotnet tool list --global
else
    echo "Skipping dotnet tools PATH tests for root user."
fi

echo "DEBUG: About to test dotnet info command..."
# Test .NET info command
check "dotnet info" dotnet --info

echo "DEBUG: All tests completed, about to report results..."

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults