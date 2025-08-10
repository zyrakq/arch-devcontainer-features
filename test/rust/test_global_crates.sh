#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Test basic Rust installation
check "rustc version" rustc --version
check "cargo version" cargo --version
check "rustup version" rustup --version

# Get the globalCrates setting from environment variable
GLOBAL_CRATES="${GLOBALCRATES:-}"

# If global crates are specified, test them
if [ -n "$GLOBAL_CRATES" ]; then
    echo "Testing global crates: $GLOBAL_CRATES"
    
    # Set cargo bin path
    CARGO_BIN_PATH="${CARGO_HOME:-$HOME/.cargo}/bin"
    
    # Convert comma-separated list to array
    IFS=',' read -ra CRATES <<< "$GLOBAL_CRATES"
    
    # Test each specified crate
    for crate in "${CRATES[@]}"; do
        # Trim whitespace
        crate=$(echo "$crate" | xargs)
        
        case "$crate" in
            "ripgrep")
                check "ripgrep installed" test -f "$CARGO_BIN_PATH/rg"
                check "ripgrep works" bash -c 'echo "test content" | "$CARGO_BIN_PATH/rg" "test"'
                ;;
            "fd-find")
                check "fd-find installed" test -f "$CARGO_BIN_PATH/fd"
                check "fd works" bash -c '"$CARGO_BIN_PATH/fd" --version'
                ;;
            "cargo-watch")
                check "cargo-watch installed" bash -c 'PATH="$CARGO_BIN_PATH:$PATH" cargo watch --version'
                ;;
            "cargo-audit")
                check "cargo-audit installed" bash -c 'PATH="$CARGO_BIN_PATH:$PATH" cargo audit --version'
                ;;
            *)
                echo "Warning: Unknown crate '$crate', skipping specific tests"
                ;;
        esac
    done
fi

# Report result
reportResults