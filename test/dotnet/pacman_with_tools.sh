#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Pacman with global tools tests
check "dotnet version" dotnet --version
check "dotnet executable exists" command -v dotnet

# Test that .NET SDK is properly installed
check "dotnet SDK available" bash -c 'dotnet --list-sdks | grep -q "."'

# Verify official packages are installed (not AUR -bin packages)
check "official dotnet-sdk package" bash -c 'pacman -Q | grep -E "dotnet-(sdk|host)" | grep -v "\-bin"'
check "dotnet-host dependency" pacman -Q dotnet-host

# Test that global tools are installed
check "dotnet-ef tool installed" bash -c 'dotnet tool list --global | grep -q "dotnet-ef"'
check "dotnet-aspnet-codegenerator tool installed" bash -c 'dotnet tool list --global | grep -q "dotnet-aspnet-codegenerator"'
check "dotnet-dev-certs tool installed" bash -c 'dotnet tool list --global | grep -q "dotnet-dev-certs"'

# Test that tools are accessible via PATH
if [ "$(id -u)" -ne 0 ]; then
    check "dotnet-ef command available" command -v dotnet-ef
    check "dotnet-aspnet-codegenerator command available" command -v dotnet-aspnet-codegenerator
    check "dotnet-dev-certs command available" command -v dotnet-dev-certs
    
    # Test basic tool functionality
    check "dotnet-ef help" dotnet-ef --help
    check "dotnet-aspnet-codegenerator help" dotnet-aspnet-codegenerator --help
    check "dotnet-dev-certs help" dotnet-dev-certs --help
else
    echo "Skipping PATH tests for root user."
fi

# Test creating a project and using EF tool
check "create web app with EF" dotnet new webapi -n TestEFApp --force
check "add EF package" bash -c 'cd TestEFApp && dotnet add package Microsoft.EntityFrameworkCore.InMemory'
check "build EF app" bash -c 'cd TestEFApp && dotnet build'

# Clean up test app
rm -rf TestEFApp

# Test basic console app functionality
check "create console app" dotnet new console -n TestApp --force
check "build console app" bash -c 'cd TestApp && dotnet build'
check "run console app" bash -c 'cd TestApp && dotnet run | grep -q "Hello, World!"'

# Clean up test app
rm -rf TestApp

# Report result
reportResults