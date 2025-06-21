#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Basic tests for dotnet-bin feature
check "dotnet version" dotnet --version
check "dotnet sdk installed" dotnet --list-sdks
check "dotnet runtime installed" dotnet --list-runtimes

# Verify AUR packages are installed (not official packages)
check "AUR dotnet-sdk-bin package" pacman -Q dotnet-sdk-bin
check "AUR dotnet-host-bin package" pacman -Q dotnet-host-bin

# Check for ASP.NET runtime (always installed with AUR packages)
check "aspnet runtime installed" dotnet --list-runtimes | grep -i aspnet
check "AUR aspnet-runtime-bin package" pacman -Q aspnet-runtime-bin

# Note: We don't check for absence of official packages since AUR packages
# provide the same functionality and pacman -Q has partial matching issues

# Test basic functionality
check "create console app" dotnet new console -n TestApp --force
check "build console app" bash -c 'cd TestApp && dotnet build'
check "run console app" bash -c 'cd TestApp && dotnet run | grep -i "hello"'

# Clean up
rm -rf TestApp

# Report result
reportResults