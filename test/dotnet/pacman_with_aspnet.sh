#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Pacman with ASP.NET Runtime tests
check "dotnet version" dotnet --version
check "dotnet executable exists" command -v dotnet

# Test that .NET SDK is properly installed
check "dotnet SDK available" bash -c 'dotnet --list-sdks | grep -q "."'

# Test that ASP.NET Core runtime is installed
check "aspnet runtime available" bash -c 'dotnet --list-runtimes | grep -q "Microsoft.AspNetCore.App"'

# Verify official packages are installed (not AUR -bin packages)
check "official dotnet-sdk package" bash -c 'pacman -Q | grep -E "dotnet-(sdk|host)" | grep -v "\-bin"'
check "official aspnet-runtime package" bash -c 'pacman -Q | grep -E "aspnet-runtime" | grep -v "\-bin"'
check "dotnet-host dependency" pacman -Q dotnet-host

# Note: Skipping AUR package checks as they are not critical for functionality

# Test creating ASP.NET Core web app
check "create web app" dotnet new webapi -n TestWebApp --force
check "build web app" bash -c 'cd TestWebApp && dotnet build'

# Test that web app can be restored and built
check "restore web app" bash -c 'cd TestWebApp && dotnet restore'

# Clean up test app
rm -rf TestWebApp

# Test basic console app functionality
check "create console app" dotnet new console -n TestApp --force
check "build console app" bash -c 'cd TestApp && dotnet build'
check "run console app" bash -c 'cd TestApp && dotnet run | grep -q "Hello, World!"'

# Clean up test app
rm -rf TestApp

# Test .NET info shows ASP.NET runtime
check "dotnet info includes aspnet" bash -c 'dotnet --info | grep -q -i "asp\|web"'

# Report result
reportResults