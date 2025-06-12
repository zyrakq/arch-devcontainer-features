#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'clone-repo' feature with specific branch.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "git is installed" git --version
check "clone script exists" test -f /usr/local/bin/clone-repo-ssh

# Test that the repository was cloned successfully
# The actual repository URL, target directory and branch are defined in scenarios.json
check "target directory exists" test -d /workspace/vscode-repo
check "cloned repo has .git directory" test -d /workspace/vscode-repo/.git

# Test git operations in cloned repo
cd /workspace/vscode-repo
check "can get git status" git status
check "can get current branch" git branch --show-current
check "is on correct branch" test "$(git branch --show-current)" = "main"

# Test that we can see git history
check "can get git log" git log --oneline -n 1

# Report result
reportResults
