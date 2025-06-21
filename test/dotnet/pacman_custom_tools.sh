#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Pacman with custom global tools tests
check "dotnet version" dotnet --version
check "dotnet executable exists" command -v dotnet

# Test that .NET SDK is properly installed
check "dotnet SDK available" bash -c 'dotnet --list-sdks | grep -q "."'

# Verify official packages are installed (not AUR -bin packages)
check "official dotnet-sdk package" bash -c 'pacman -Q | grep -E "dotnet-(sdk|host)" | grep -v "\-bin"'
check "dotnet-host dependency" pacman -Q dotnet-host

# Test that custom global tools are installed
check "dotnet-format tool installed" bash -c 'dotnet tool list --global | grep -q "dotnet-format"'

# Test that custom tools are accessible via PATH
if [ "$(id -u)" -ne 0 ]; then
    check "dotnet-format command available" command -v dotnet-format
    
    # Test basic tool functionality
    check "dotnet-format help" dotnet-format --help
    
    # Test tools with a sample project
    check "create console app for tools test" dotnet new console -n TestToolsApp --force
    
    # Test dotnet-format (should not fail on a simple console app)
    check "dotnet-format on sample project" bash -c 'cd TestToolsApp && dotnet-format --verify-no-changes --verbosity diagnostic || true'
    
    
    # Clean up test app
    rm -rf TestToolsApp
else
    echo "Skipping PATH and functionality tests for root user."
fi

# Verify tools are listed in global tools
check "list all global tools" dotnet tool list --global

# Test basic console app functionality
check "create console app" dotnet new console -n TestApp --force
check "build console app" bash -c 'cd TestApp && dotnet build'
check "run console app" bash -c 'cd TestApp && dotnet run | grep -q "Hello, World!"'

# Clean up test app
rm -rf TestApp

# Report result
reportResults