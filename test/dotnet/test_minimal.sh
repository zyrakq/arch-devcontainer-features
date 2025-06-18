#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for minimal installation (SDK only, no ASP.NET Runtime)
check "dotnet version" dotnet --version
check "dotnet executable exists" command -v dotnet

# Test that .NET SDK is available
check "dotnet SDK available" bash -c 'dotnet --list-sdks | grep -q "."'

# Test that basic .NET runtime is available (Microsoft.NETCore.App)
check "dotnet core runtime available" bash -c 'dotnet --list-runtimes | grep -q "Microsoft.NETCore.App"'

# Test that ASP.NET Core runtime is NOT installed (since installAspNetRuntime: false)
check "aspnet runtime not installed" bash -c '! dotnet --list-runtimes | grep -q "Microsoft.AspNetCore.App"'

# Test basic console app functionality
check "create console app" dotnet new console -n TestMinimalApp --force
check "build console app" bash -c 'cd TestMinimalApp && dotnet build'
check "run console app" bash -c 'cd TestMinimalApp && dotnet run | grep -q "Hello, World!"'

# Clean up test app
rm -rf TestMinimalApp

# Test that we cannot create web apps (should fail or warn without ASP.NET runtime)
# Note: This might still work as the template doesn't require runtime at build time,
# but we can check that ASP.NET runtime is not available
check "no aspnet runtime in list" bash -c '! dotnet --list-runtimes | grep -q "AspNetCore"'

# Verify no global tools are installed by default in minimal setup
if [ "$(id -u)" -ne 0 ]; then
    check "no global tools installed" bash -c 'dotnet tool list --global | wc -l | grep -q "^[0-3]$"'
else
    echo "Skipping global tools check for root user."
fi

# Test .NET info command
check "dotnet info" dotnet --info

# Report result
reportResults