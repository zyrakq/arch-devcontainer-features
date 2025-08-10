#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Zyrakq.
# Licensed under the MIT License.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/zyrakq/arch-devcontainer-features/tree/master/src/rust/README.md
# Maintainer: Zyrakq

set -e

# shellcheck disable=SC2034
RUST_VERSION="${RUSTVERSION:-"stable"}"
ADDITIONAL_TARGETS="${ADDITIONALTARGETS:-""}"
INSTALL_CLIPPY="${INSTALLCLIPPY:-"true"}"
INSTALL_RUSTFMT="${INSTALLRUSTFMT:-"true"}"
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
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
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

# Function to run commands as the appropriate user
sudo_if() {
    COMMAND="$*"
    if [ "$(id -u)" -ne 0 ]; then
        sudo $COMMAND
    else
        $COMMAND
    fi
}

# Function to run commands as non-root user
run_as_user() {
    COMMAND="$*"
    if [ "$(id -u)" = "0" ] && [ "${USERNAME}" != "root" ]; then
        sudo -u "${USERNAME}" bash -c "$COMMAND"
    else
        bash -c "$COMMAND"
    fi
}

echo "Starting Rust installation..."

# Install rustup and build dependencies via pacman
echo "Installing rustup and build dependencies via pacman..."
check_and_install_packages rustup base-devel

# Initialize rustup for the user
echo "Initializing rustup..."
if [ "${USERNAME}" != "root" ]; then
    # Initialize rustup for non-root user
    run_as_user "rustup default $RUST_VERSION"
else
    # Initialize rustup for root
    rustup default "$RUST_VERSION"
fi

echo "Rust $RUST_VERSION toolchain installed successfully!"

# Install additional components
if [ "$INSTALL_CLIPPY" = "true" ]; then
    echo "Installing clippy..."
    if [ "${USERNAME}" != "root" ]; then
        run_as_user "rustup component add clippy"
    else
        rustup component add clippy
    fi
    echo "Clippy installed successfully!"
fi

if [ "$INSTALL_RUSTFMT" = "true" ]; then
    echo "Installing rustfmt..."
    if [ "${USERNAME}" != "root" ]; then
        run_as_user "rustup component add rustfmt"
    else
        rustup component add rustfmt
    fi
    echo "Rustfmt installed successfully!"
fi

# Install additional targets
if [ -n "$ADDITIONAL_TARGETS" ]; then
    echo "Installing additional targets: $ADDITIONAL_TARGETS"
    
    # Convert comma-separated list to space-separated
    TARGETS=$(echo "$ADDITIONAL_TARGETS" | tr ',' ' ')
    
    for target in $TARGETS; do
        echo "Installing target: $target"
        if [ "${USERNAME}" != "root" ]; then
            run_as_user "rustup target add $target"
        else
            rustup target add "$target"
        fi
    done
    
    echo "Additional targets installed successfully!"
fi

# Install global crates
if [ -n "$GLOBAL_CRATES" ]; then
    echo "Installing global crates: $GLOBAL_CRATES"
    
    # Convert comma-separated list to space-separated
    CRATES=$(echo "$GLOBAL_CRATES" | tr ',' ' ')
    
    for crate in $CRATES; do
        echo "Installing crate: $crate"
        if [ "${USERNAME}" != "root" ]; then
            run_as_user "cargo install $crate"
        else
            cargo install "$crate"
        fi
    done
    
    echo "Global crates installed successfully!"
fi

# Setup environment variables for shell profiles
if [ "${USERNAME}" != "root" ]; then
    USER_HOME=$(eval echo "~$USERNAME")
    
    # Add cargo bin to PATH in shell profiles
    for profile in "$USER_HOME/.bashrc" "$USER_HOME/.zshrc"; do
        if [ -f "$profile" ]; then
            if ! grep -q "cargo/bin" "$profile"; then
                echo "" >> "$profile"
                echo "# Rust and Cargo configuration" >> "$profile"
                echo "export PATH=\"\$HOME/.cargo/bin:\$PATH\"" >> "$profile"
                echo "export CARGO_HOME=\"\$HOME/.cargo\"" >> "$profile"
                echo "export RUSTUP_HOME=\"\$HOME/.rustup\"" >> "$profile"
            fi
        fi
    done
    
    echo "Environment variables configured for user $USERNAME"
fi

echo "Rust feature installation completed!"

# Display installation summary
echo ""
echo "=== Installation Summary ==="
if command -v rustc &> /dev/null; then
    echo "Rust version: $(rustc --version)"
fi
if command -v cargo &> /dev/null; then
    echo "Cargo version: $(cargo --version)"
fi
if command -v rustup &> /dev/null; then
    echo "Rustup version: $(rustup --version)"
fi
if [ "$INSTALL_CLIPPY" = "true" ] && command -v cargo-clippy &> /dev/null; then
    echo "Clippy: Available"
fi
if [ "$INSTALL_RUSTFMT" = "true" ] && command -v rustfmt &> /dev/null; then
    echo "Rustfmt: Available"
fi
if [ -n "$ADDITIONAL_TARGETS" ]; then
    echo "Additional targets: $ADDITIONAL_TARGETS"
fi
if [ -n "$GLOBAL_CRATES" ]; then
    echo "Global crates: $GLOBAL_CRATES"
fi
echo "=========================="