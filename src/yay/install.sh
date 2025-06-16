#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Zeritiq.
# Licensed under the MIT License.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/zeritiq/arch-devcontainer-features/tree/master/src/yay/README.md
# Maintainer: Zeritiq

set -e

# shellcheck disable=SC2034
INSTALL_PACKAGES="${INSTALLPACKAGES:-}"
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

echo "Starting yay AUR helper installation..."

# Check if yay is already installed
if command -v yay &> /dev/null; then
    echo "Yay is already installed, skipping installation..."
else
    echo "Installing yay AUR helper..."
    
    # Ensure required packages are installed
    echo "Installing required packages (base-devel, git)..."
    check_and_install_packages base-devel git

    # Create a temporary build user
    BUILD_USER="builder"
    useradd -m -G wheel "$BUILD_USER"
    
    # Give the build user passwordless sudo privileges
    echo "$BUILD_USER ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$BUILD_USER"
    
    # Create temporary directory for yay installation
    YAY_TMP_DIR=$(mktemp -d -p "/home/$BUILD_USER")
    chown "$BUILD_USER" "$YAY_TMP_DIR"
    
    echo "Cloning yay from AUR..."
    sudo -u "$BUILD_USER" git clone https://aur.archlinux.org/yay.git "$YAY_TMP_DIR"
    
    echo "Building and installing yay..."
    cd "$YAY_TMP_DIR"
    
    # Build and install as the build user
    sudo -u "$BUILD_USER" makepkg -si --noconfirm
    
    # Clean up
    cd /
    rm -rf "$YAY_TMP_DIR"
    userdel -r "$BUILD_USER"
    rm -f "/etc/sudoers.d/$BUILD_USER"
    
    echo "Yay installation completed successfully!"
fi

# Install additional AUR packages if specified
if [ -n "$INSTALL_PACKAGES" ]; then
    echo "Installing additional AUR packages: $INSTALL_PACKAGES"
    
    # Convert comma-separated list to space-separated
    PACKAGES=$(echo "$INSTALL_PACKAGES" | tr ',' ' ')
    
    # Determine user to run yay as
    if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ] || [ "${USERNAME}" = "root" ]; then
        # If running as root or auto, find a non-root user or create one
        POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
        YAY_USER=""
        for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
            if id -u "${CURRENT_USER}" >/dev/null 2>&1; then
                YAY_USER=${CURRENT_USER}
                break
            fi
        done
        if [ -z "$YAY_USER" ]; then
            YAY_USER="yay-user"
            useradd -m -G wheel "$YAY_USER"
            echo "$YAY_USER ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$YAY_USER"
            echo "Created temporary user $YAY_USER to run yay."
        fi
    else
        YAY_USER="${USERNAME}"
    fi

    echo "Installing packages as user: $YAY_USER"
    sudo -u "$YAY_USER" yay -S --noconfirm $PACKAGES

    # Clean up temporary user if created
    if [ "$YAY_USER" = "yay-user" ]; then
        userdel -r "$YAY_USER"
        rm -f "/etc/sudoers.d/$YAY_USER"
        echo "Removed temporary user $YAY_USER."
    fi
    
    echo "Additional packages installed successfully!"
fi

echo "Yay AUR helper feature installation completed!"
