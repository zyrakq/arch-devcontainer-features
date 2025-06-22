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

# Verify AUR packages are installed (not official packages)
check "AUR dotnet-sdk-bin package" pacman -Q dotnet-sdk-bin
check "AUR dotnet-host-bin package" pacman -Q dotnet-host-bin

# Note: We don't check for absence of official packages since AUR packages
# provide the same functionality and pacman -Q has partial matching issues

# Test basic .NET functionality
check "create console app" dotnet new console -n TestApp --force
check "build console app" bash -c 'cd TestApp && dotnet build'
check "run console app" bash -c 'cd TestApp && dotnet run | grep -q "Hello, World!"'

# Clean up test app
rm -rf TestApp

# Conditional checks for non-root user
if [ "$(id -u)" -ne 0 ]; then
    # Test dotnet tools PATH configuration
    check "dotnet tools in PATH" bash -c 'echo $PATH | grep -q "\.dotnet/tools"'
    
    # Test that dotnet tools directory exists
    check "dotnet tools directory exists" test -d "$HOME/.dotnet/tools"
    
    # Test that we can list global tools (even if empty)
    check "list global tools" dotnet tool list --global
else
    echo "Skipping dotnet tools PATH tests for root user."
fi

# Test .NET info command
check "dotnet info" dotnet --info

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults