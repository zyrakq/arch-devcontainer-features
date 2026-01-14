#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Zyrakq.
# Licensed under the MIT License or Apache License 2.0.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/zyrakq/arch-devcontainer-features/tree/master/src/rust/README.md
# Maintainer: Zyrakq

set -e

# Environment variables
INSTALL_RUST_SRC="${INSTALLRUSTSRC:-"true"}"
INSTALL_RUST_ANALYZER="${INSTALLRUSTANALYZER:-"true"}"
GLOBAL_CRATES="${GLOBALCRATES:-""}"
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

# **************************
# ** Utility functions **
# **************************

# Function to get submodule commit hash
get_submodule_commit() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local feature_root="$(cd "${script_dir}/../.." && pwd)"
    
    # Check if we're in a git repository
    if ! git -C "$feature_root" rev-parse --git-dir >/dev/null 2>&1; then
        echo "main" # fallback to main branch
        return
    fi
    
    # Get commit hash of submodule
    local commit_hash
    commit_hash=$(git -C "$feature_root" ls-tree HEAD vendor/bartventer-features 2>/dev/null | awk '{print $3}')
    
    if [ -n "$commit_hash" ]; then
        echo "$commit_hash"
    else
        echo "main" # fallback to main branch
    fi
}

# Get bartventer commit and setup utils
echo "Determining bartventer-features version..."
BARTVENTER_COMMIT=$(get_submodule_commit)
echo "Using bartventer-features commit: $BARTVENTER_COMMIT"

_UTILS_SETUP_SCRIPT=$(mktemp)
UTILS_URL="https://raw.githubusercontent.com/bartventer/arch-devcontainer-features/${BARTVENTER_COMMIT}/scripts/archlinux_util_setup.sh"
echo "Downloading utils from: $UTILS_URL"

curl -sSL -o "$_UTILS_SETUP_SCRIPT" "$UTILS_URL" || {
    echo "Failed to download from commit $BARTVENTER_COMMIT, trying main branch..."
    curl -sSL -o "$_UTILS_SETUP_SCRIPT" "https://raw.githubusercontent.com/bartventer/arch-devcontainer-features/main/scripts/archlinux_util_setup.sh"
}

sh "$_UTILS_SETUP_SCRIPT"
rm -f "$_UTILS_SETUP_SCRIPT"

# shellcheck disable=SC1091
# shellcheck source=scripts/archlinux_util.sh
. archlinux_util.sh

# Setup STDERR.
err() {
    echo "(!) $*" >&2
}

# Source /etc/os-release to get OS info
# shellcheck disable=SC1091
. /etc/os-release

# Run checks
check_root
check_system
check_pacman

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "abc" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" >/dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u "${USERNAME}" >/dev/null 2>&1; then
    USERNAME=root
fi

# Function to run commands as non-root user
run_as_user() {
    COMMAND="$*"
    if [ "$(id -u)" = "0" ] && [ "${USERNAME}" != "root" ]; then
        sudo -u "${USERNAME}" bash -c "$COMMAND"
    else
        bash -c "$COMMAND"
    fi
}

echo "Starting Rust installation via pacman..."
echo "Using pre-compiled packages from official Arch repositories"

# Determine packages to install
# Note: rust package includes rustc, cargo, clippy, and rustfmt
PACKAGES_TO_INSTALL="rust"

if [ "$INSTALL_RUST_SRC" = "true" ]; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL rust-src"
    echo "Will install: rust-src (for IDE support)"
fi

if [ "$INSTALL_RUST_ANALYZER" = "true" ]; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL rust-analyzer"
    echo "Will install: rust-analyzer (LSP server)"
fi

echo "Packages to install: $PACKAGES_TO_INSTALL"

# Install Rust packages via pacman
echo "Installing Rust packages..."
check_and_install_packages $PACKAGES_TO_INSTALL

echo "Rust packages installed successfully!"

# Verify installation
echo "Verifying Rust installation..."

if command -v rustc &> /dev/null; then
    echo "✓ Rust compiler found: $(rustc --version)"
else
    err "Rust installation failed - rustc not found"
    exit 1
fi

if command -v cargo &> /dev/null; then
    echo "✓ Cargo found: $(cargo --version)"
else
    err "Rust installation failed - cargo not found"
    exit 1
fi

# Check components included with rust package
if cargo clippy --version &> /dev/null; then
    echo "✓ Clippy installed (included with rust package)"
else
    echo "⚠ Warning: Clippy not found"
fi

if rustfmt --version &> /dev/null; then
    echo "✓ Rustfmt installed (included with rust package)"
else
    echo "⚠ Warning: Rustfmt not found"
fi

# Check optional components

if [ "$INSTALL_RUST_ANALYZER" = "true" ]; then
    if command -v rust-analyzer &> /dev/null; then
        echo "✓ Rust-analyzer installed"
    else
        echo "⚠ Warning: Rust-analyzer not found"
    fi
fi

echo "Rust installation verification completed!"

# Configure cargo tools PATH
USER_HOME=$(eval echo "~$USERNAME")
CARGO_HOME="$USER_HOME/.cargo"
CARGO_BIN="$CARGO_HOME/bin"

echo "Configuring Cargo environment..."
echo "User: $USERNAME"
echo "Home: $USER_HOME"
echo "Cargo bin: $CARGO_BIN"

# Add cargo bin to PATH via shell profiles
if [ "${USERNAME}" != "root" ]; then
    for profile in "$USER_HOME/.bashrc" "$USER_HOME/.zshrc"; do
        if [ -f "$profile" ]; then
            if ! grep -q "\.cargo/bin" "$profile"; then
                echo "" >> "$profile"
                echo "# Rust and Cargo configuration" >> "$profile"
                echo "export PATH=\"\$HOME/.cargo/bin:\$PATH\"" >> "$profile"
                echo "✓ Added cargo bin to PATH in $profile"
            else
                echo "○ Cargo bin already in PATH ($profile)"
            fi
        fi
    done
    
    echo "Environment configured for user $USERNAME"
fi

# Export for current session
export PATH="$CARGO_BIN:$PATH"

# Install global crates via cargo install
if [ -n "$GLOBAL_CRATES" ]; then
    echo ""
    echo "Installing global crates: $GLOBAL_CRATES"
    
    # Convert comma-separated to space-separated
    CRATES=$(echo "$GLOBAL_CRATES" | tr ',' ' ')
    
    for crate in $CRATES; do
        echo "Installing crate: $crate"
        if [ "${USERNAME}" != "root" ]; then
            if run_as_user "export PATH=\"$CARGO_BIN:\$PATH\" && cargo install $crate"; then
                echo "✓ Successfully installed: $crate"
            else
                echo "✗ Failed to install: $crate (continuing...)"
            fi
        else
            if cargo install "$crate"; then
                echo "✓ Successfully installed: $crate"
            else
                echo "✗ Failed to install: $crate (continuing...)"
            fi
        fi
    done
    
    echo "Global crates installation completed!"
else
    echo "No global crates to install (globalCrates is empty)"
fi

echo ""
echo "Rust feature installation completed!"

# Output installation summary
echo ""
echo "=== Installation Summary ==="
echo "Installation method: pacman (pre-compiled packages)"
echo "Rust version: $(rustc --version 2>/dev/null || echo 'unknown')"
echo "Cargo version: $(cargo --version 2>/dev/null || echo 'unknown')"

# Installed components
echo ""
echo "Installed components:"
# Clippy and rustfmt are always included with rust package
if cargo clippy --version &> /dev/null; then
    echo "  ✓ Clippy: $(cargo clippy --version 2>/dev/null | head -n1) [included]"
fi
if rustfmt --version &> /dev/null; then
    echo "  ✓ Rustfmt: $(rustfmt --version 2>/dev/null) [included]"
fi
if [ "$INSTALL_RUST_SRC" = "true" ]; then
    echo "  ✓ Rust source code (rust-src)"
fi
if [ "$INSTALL_RUST_ANALYZER" = "true" ] && command -v rust-analyzer &> /dev/null; then
    echo "  ✓ Rust-analyzer: Available"
fi

# Global crates
if [ -n "$GLOBAL_CRATES" ]; then
    echo ""
    echo "Global crates installed:"
    for crate in $(echo "$GLOBAL_CRATES" | tr ',' ' '); do
        echo "  - $crate"
    done
fi

# Additional information
if [ "${USERNAME}" != "root" ]; then
    echo ""
    echo "Cargo bin directory: $CARGO_BIN"
    echo "Install global tools with: cargo install <crate-name>"
fi

echo ""
echo "For beta/nightly Rust or cross-compilation targets, use the 'rust-bin' feature instead."
echo "=========================="
