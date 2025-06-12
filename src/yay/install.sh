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

echo "Starting yay AUR helper installation..."

# Check if yay is already installed
if command -v yay &> /dev/null; then
    echo "Yay is already installed, skipping installation..."
else
    echo "Installing yay AUR helper..."
    
    # Ensure required packages are installed
    echo "Installing required packages (base-devel, git)..."
    check_and_install_packages base-devel git
    
    # Create temporary directory for yay installation
    YAY_TMP_DIR=$(mktemp -d)
    cd "$YAY_TMP_DIR"
    
    echo "Cloning yay from AUR..."
    git clone https://aur.archlinux.org/yay.git
    
    echo "Building and installing yay..."
    cd yay
    
    # Build as non-root user if we're currently root
    if [ "$(id -u)" = "0" ] && [ "${USERNAME}" != "root" ]; then
        chown -R "${USERNAME}:${USERNAME}" "$YAY_TMP_DIR"
        sudo -u "${USERNAME}" makepkg -si --noconfirm
    else
        makepkg -si --noconfirm
    fi
    
    # Clean up
    cd /
    rm -rf "$YAY_TMP_DIR"
    
    echo "Yay installation completed successfully!"
fi

# Install additional AUR packages if specified
if [ -n "$INSTALL_PACKAGES" ]; then
    echo "Installing additional AUR packages: $INSTALL_PACKAGES"
    
    # Convert comma-separated list to space-separated
    PACKAGES=$(echo "$INSTALL_PACKAGES" | tr ',' ' ')
    
    # Install packages using yay as appropriate user
    if [ "$(id -u)" = "0" ] && [ "${USERNAME}" != "root" ]; then
        sudo -u "${USERNAME}" yay -Sy $PACKAGES --noconfirm
    else
        yay -Sy $PACKAGES --noconfirm
    fi
    
    echo "Additional packages installed successfully!"
fi

echo "Yay AUR helper feature installation completed!"
