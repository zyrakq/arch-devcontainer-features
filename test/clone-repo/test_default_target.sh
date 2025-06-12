#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'clone-repo' feature with default target directory.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "git is installed" git --version
check "clone script exists" test -f /usr/local/bin/clone-repo-ssh

# Test that the repository was cloned to default location (/workspace)
# The actual repository URL is defined in scenarios.json
check "default workspace directory exists" test -d /workspace
check "cloned repo exists in workspace" test -d /workspace/.git

# Test git operations in cloned repo
cd /workspace
check "can get git status" git status
check "can get git log" git log --oneline -n 1
check "can get current branch" git branch --show-current

# Test that files were cloned
check "repository files exist" test -f /workspace/README.md

# Report result
reportResults
