#!/bin/bash

# This test file will be executed against a devcontainer.json that
# includes the 'clone-repo' feature with HTTPS repository URL.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "git is installed" git --version
check "clone script exists" test -f /usr/local/bin/clone-repo-ssh

# Test that the repository was cloned successfully
# The actual repository URL and target directory are defined in scenarios.json
check "target directory exists" test -d /workspace/test-repo
check "cloned repo has .git directory" test -d /workspace/test-repo/.git
check "cloned repo has files" test -f /workspace/test-repo/README.md

# Test git operations in cloned repo
cd /workspace/test-repo
check "can get git status" git status
check "can get git log" git log --oneline -n 1
check "can get current branch" git branch --show-current

# Test file permissions
check "files are readable" test -r /workspace/test-repo/README.md
check "directory is writable" touch /workspace/test-repo/test-write && rm /workspace/test-repo/test-write

# Report result
reportResults
