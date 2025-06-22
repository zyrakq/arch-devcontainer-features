#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "dotnet version" dotnet --version
check "dotnet list sdks" dotnet --list-sdks
check "dotnet list runtimes" dotnet --list-runtimes

# Check if all global tools are installed
check "dotnet-ef tool installed" dotnet tool list --global | grep dotnet-ef
check "dotnet-aspnet-codegenerator tool installed" dotnet tool list --global | grep dotnet-aspnet-codegenerator
check "dotnet-dev-certs tool installed" dotnet tool list --global | grep dotnet-dev-certs

# Test all tools functionality
check "dotnet-ef help" dotnet ef --help
check "dotnet-aspnet-codegenerator help" dotnet aspnet-codegenerator --help
check "dotnet-dev-certs help" dotnet dev-certs --help

# Test basic .NET functionality
check "dotnet new console works" bash -c "cd /tmp && dotnet new console -n TestAppWithTools --force && cd TestAppWithTools && dotnet build"

# Report result
reportResults