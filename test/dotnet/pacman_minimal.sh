#!/bin/bash

set -e

# Import test library
source dev-container-features-test-lib

# Pacman minimal installation tests (SDK only, no ASP.NET Runtime)
check "dotnet version" dotnet --version
check "dotnet executable exists" command -v dotnet

# Test that .NET SDK is available
check "dotnet SDK available" bash -c 'dotnet --list-sdks | grep -q "."'

# Test that basic .NET runtime is available (Microsoft.NETCore.App)
check "dotnet core runtime available" bash -c 'dotnet --list-runtimes | grep -q "Microsoft.NETCore.App"'

# Test that ASP.NET Core runtime is NOT installed (since installAspNetRuntime: false)
check "aspnet runtime not installed" bash -c 'dotnet --list-runtimes | grep -q "Microsoft.AspNetCore.App" && exit 1 || exit 0'

# Verify official packages are installed (not AUR -bin packages)
check "official dotnet-sdk package" bash -c 'pacman -Q | grep -E "dotnet-(sdk|host)" | grep -v "\-bin"'
check "dotnet-host dependency" pacman -Q dotnet-host

# Verify ASP.NET runtime package is NOT installed
check "no aspnet-runtime package" bash -c 'pacman -Q aspnet-runtime 2>/dev/null && exit 1 || exit 0'
check "no aspnet-runtime-8.0 package" bash -c 'pacman -Q aspnet-runtime-8.0 2>/dev/null && exit 1 || exit 0'

# Note: Skipping AUR package checks as they are not critical for functionality

# Test basic console app functionality
check "create console app" dotnet new console -n TestMinimalApp --force
check "build console app" bash -c 'cd TestMinimalApp && dotnet build'
check "run console app" bash -c 'cd TestMinimalApp && dotnet run | grep -q "Hello, World!"'

# Clean up test app
rm -rf TestMinimalApp

# Test that we cannot create web apps (should fail or warn without ASP.NET runtime)
# Note: This might still work as the template doesn't require runtime at build time,
# but we can check that ASP.NET runtime is not available
check "no aspnet runtime in list" bash -c 'dotnet --list-runtimes | grep -q "AspNetCore" && exit 1 || exit 0'

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