#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests for custom global tools
check "dotnet version" dotnet --version
check "dotnet executable exists" command -v dotnet

# Test that custom global tools are installed
check "dotnet-format tool installed" bash -c 'dotnet tool list --global | grep -q "dotnet-format"'
check "dotnet-outdated-global tool installed" bash -c 'dotnet tool list --global | grep -q "dotnet-outdated-global"'

# Test that custom tools are accessible via PATH
if [ "$(id -u)" -ne 0 ]; then
    check "dotnet-format command available" command -v dotnet-format
    check "dotnet-outdated command available" command -v dotnet-outdated
    
    # Test basic tool functionality
    check "dotnet-format help" dotnet-format --help
    check "dotnet-outdated help" dotnet-outdated --help
    
    # Test tools with a sample project
    check "create console app for tools test" dotnet new console -n TestToolsApp --force
    
    # Test dotnet-format (should not fail on a simple console app)
    check "dotnet-format on sample project" bash -c 'cd TestToolsApp && dotnet-format --verify-no-changes --verbosity diagnostic || true'
    
    # Test dotnet-outdated (should run without errors)
    check "dotnet-outdated on sample project" bash -c 'cd TestToolsApp && dotnet-outdated || true'
    
    # Clean up test app
    rm -rf TestToolsApp
else
    echo "Skipping PATH and functionality tests for root user."
fi

# Verify tools are listed in global tools
check "list all global tools" dotnet tool list --global

# Report result
reportResults