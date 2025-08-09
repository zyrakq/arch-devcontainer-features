#!/bin/bash

# This test file will test the behavior when a repository already exists
# in the target directory (simulating container rebuild scenario)

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "git is installed" git --version
check "clone script exists" test -f /usr/local/bin/clone-repo-ssh

# Create a test scenario: simulate an existing repository
TEST_REPO_URL="https://github.com/octocat/Hello-World.git"
TEST_TARGET_DIR="/workspace/existing-repo-test"

# First, manually clone the repository to simulate existing state
check "can create target directory" mkdir -p "$TEST_TARGET_DIR"
check "can clone repository manually" git clone "$TEST_REPO_URL" "$TEST_TARGET_DIR"
check "repository was cloned" test -d "$TEST_TARGET_DIR/.git"

# Get the original remote URL to verify it matches
ORIGINAL_URL=$(git -C "$TEST_TARGET_DIR" remote get-url origin)
check "can get original remote URL" test -n "$ORIGINAL_URL"

# Create a config file to simulate the feature being run again
CONFIG_FILE="/usr/local/etc/clone-repo-config-test"
cat > "$CONFIG_FILE" << EOF
# Clone repository configuration
REPO_URL="$TEST_REPO_URL"
TARGET_DIR="$TEST_TARGET_DIR"
BRANCH=""
USERNAME="$(whoami)"
EOF

# Modify the clone script to use our test config
TEST_CLONE_SCRIPT="/usr/local/bin/clone-repo-ssh-test"
cp /usr/local/bin/clone-repo-ssh "$TEST_CLONE_SCRIPT"
sed -i "s|/usr/local/etc/clone-repo-config|$CONFIG_FILE|g" "$TEST_CLONE_SCRIPT"
chmod +x "$TEST_CLONE_SCRIPT"

# Test 1: Same repository URL should skip cloning
echo "Testing same repository URL (should skip)..."
check "clone script runs successfully with existing repo" "$TEST_CLONE_SCRIPT"
check "repository still exists" test -d "$TEST_TARGET_DIR/.git"
check "remote URL unchanged" test "$(git -C "$TEST_TARGET_DIR" remote get-url origin)" = "$ORIGINAL_URL"

# Test 2: Different repository URL should fail with error
echo "Testing different repository URL (should fail)..."
DIFFERENT_REPO_URL="https://github.com/microsoft/vscode.git"
cat > "$CONFIG_FILE" << EOF
# Clone repository configuration
REPO_URL="$DIFFERENT_REPO_URL"
TARGET_DIR="$TEST_TARGET_DIR"
BRANCH=""
USERNAME="$(whoami)"
EOF

# This should fail with exit code 1
if "$TEST_CLONE_SCRIPT" 2>/dev/null; then
    echo "ERROR: Script should have failed with different repository URL"
    exit 1
else
    echo "SUCCESS: Script correctly failed with different repository URL"
fi

check "repository still exists after failed attempt" test -d "$TEST_TARGET_DIR/.git"
check "original remote URL preserved" test "$(git -C "$TEST_TARGET_DIR" remote get-url origin)" = "$ORIGINAL_URL"

# Test 3: Non-git directory should be backed up
echo "Testing non-git directory backup..."
NON_GIT_DIR="/workspace/non-git-test"
mkdir -p "$NON_GIT_DIR"
echo "test file" > "$NON_GIT_DIR/test.txt"

cat > "$CONFIG_FILE" << EOF
# Clone repository configuration
REPO_URL="$TEST_REPO_URL"
TARGET_DIR="$NON_GIT_DIR"
BRANCH=""
USERNAME="$(whoami)"
EOF

check "clone script handles non-git directory" "$TEST_CLONE_SCRIPT"
check "new repository was cloned" test -d "$NON_GIT_DIR/.git"
check "backup directory was created" test -d "${NON_GIT_DIR}.backup."*

# Cleanup
rm -rf "$TEST_TARGET_DIR" "$NON_GIT_DIR" "${NON_GIT_DIR}.backup."* "$CONFIG_FILE" "$TEST_CLONE_SCRIPT"

# Report result
reportResults