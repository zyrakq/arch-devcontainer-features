#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Basic pacman installation tests
check "dotnet version" dotnet --version
check "dotnet executable exists" command -v dotnet

# Test that .NET SDK is properly installed
check "dotnet SDK available" bash -c 'dotnet --list-sdks | grep -q "."'

# Test that .NET runtime is available
check "dotnet runtime available" bash -c 'dotnet --list-runtimes | grep -q "."'

# Verify official packages are installed (not AUR -bin packages)
check "official dotnet-sdk package" bash -c 'pacman -Q | grep -E "dotnet-(sdk|host)" | grep -v "\-bin"'
check "dotnet-host dependency" pacman -Q dotnet-host

# Note: Skipping AUR package checks as they are not critical for functionality

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
reportResults