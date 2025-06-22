#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "dotnet version" dotnet --version
check "dotnet list sdks" dotnet --list-sdks
check "dotnet list runtimes" dotnet --list-runtimes

# Check that ASP.NET Core Runtime is installed (automatically included with AUR packages)
check "aspnet runtime installed" dotnet --list-runtimes | grep "Microsoft.AspNetCore.App"

# Test basic .NET functionality
check "dotnet new console works" bash -c "cd /tmp && dotnet new console -n TestApp --force && cd TestApp && dotnet build"

# Report result
reportResults