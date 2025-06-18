#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'clone-repo' feature with no options.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' function is a part of the devcontainer CLI test lib.
# Syntax: check <LABEL> <cmd>

# Test that git is available
check "git is installed" git --version
check "git is executable" command -v git

# Test that the clone script is installed
check "clone script exists" test -f /usr/local/bin/clone-repo-ssh
check "clone script is executable" test -x /usr/local/bin/clone-repo-ssh

# Test that the script can be executed (without actual cloning since no repo URL provided)
check "clone script runs without error when no repo specified" /usr/local/bin/clone-repo-ssh

# Test basic git functionality
check "git config works" git config --global user.name "Test User"
check "git config email works" git config --global user.email "test@example.com"

# Test directory creation permissions
check "can create directories in /workspace" mkdir -p /workspace/test-dir
check "can write to /workspace" touch /workspace/test-file

# Cleanup test files
rm -rf /workspace/test-dir /workspace/test-file

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
