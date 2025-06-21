#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Pacman with specific .NET version tests
check "dotnet version" dotnet --version
check "dotnet executable exists" command -v dotnet

# Test that .NET 8.0 is installed (or at least version 8.x)
check "dotnet version is 8.x" bash -c 'dotnet --version | grep -q "^8\."'

# Test that .NET SDK 8.0 is available
check "dotnet SDK 8.0 available" bash -c 'dotnet --list-sdks | grep -q "8\."'

# Test that ASP.NET Core runtime 8.0 is available
check "aspnet runtime 8.0 available" bash -c 'dotnet --list-runtimes | grep -q "Microsoft.AspNetCore.App 8\."'

# Verify official packages are installed (not AUR -bin packages)
check "official dotnet-sdk-8.0 package" pacman -Q dotnet-sdk-8.0
check "official aspnet-runtime-8.0 package" pacman -Q aspnet-runtime-8.0
check "dotnet-host dependency" pacman -Q dotnet-host

# Note: Skipping AUR package checks as they are not critical for functionality

# Test creating a project with specific framework version
check "create app with net8.0" dotnet new console -n TestNet8App --framework net8.0 --force
check "build net8.0 app" bash -c 'cd TestNet8App && dotnet build'
check "run net8.0 app" bash -c 'cd TestNet8App && dotnet run | grep -q "Hello, World!"'

# Verify project file contains correct target framework
check "project targets net8.0" bash -c 'cd TestNet8App && grep -q "net8.0" *.csproj'

# Clean up test app
rm -rf TestNet8App

# Test creating ASP.NET Core app with .NET 8.0
check "create web app with net8.0" dotnet new webapi -n TestNet8WebApp --framework net8.0 --force
check "build net8.0 web app" bash -c 'cd TestNet8WebApp && dotnet build'

# Clean up test web app
rm -rf TestNet8WebApp

# Test .NET info shows correct version
check "dotnet info shows version 8" bash -c 'dotnet --info | grep -q "8\."'

# Report result
reportResults