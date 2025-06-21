#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "dotnet version" dotnet --version
check "dotnet list sdks" dotnet --list-sdks
check "dotnet list runtimes" dotnet --list-runtimes

# Check if custom tool (dotnet-format) is installed
check "dotnet-format tool installed" dotnet tool list --global | grep dotnet-format

# Test custom tool functionality
check "dotnet-format help" dotnet format --help

# Report result
reportResults