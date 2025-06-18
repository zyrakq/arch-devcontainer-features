#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for ASP.NET Runtime
check "dotnet version" dotnet --version
check "dotnet executable exists" command -v dotnet

# Test that ASP.NET Core runtime is installed
check "aspnet runtime available" bash -c 'dotnet --list-runtimes | grep -q "Microsoft.AspNetCore.App"'

# Test creating ASP.NET Core web app
check "create web app" dotnet new webapi -n TestWebApp --force
check "build web app" bash -c 'cd TestWebApp && dotnet build'

# Test that web app can be restored and built
check "restore web app" bash -c 'cd TestWebApp && dotnet restore'

# Clean up test app
rm -rf TestWebApp

# Test .NET info shows ASP.NET runtime
check "dotnet info includes aspnet" bash -c 'dotnet --info | grep -q -i "asp\|web"'

# Report result
reportResults