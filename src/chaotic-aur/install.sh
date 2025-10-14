#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Zyrakq.
# Licensed under the MIT License or Apache License 2.0.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/zyrakq/arch-devcontainer-features/tree/master/src/chaotic-aur/README.md
# Maintainer: Zyrakq

set -e

# shellcheck disable=SC2034
MIRROR="${MIRROR:-auto}"
INSTALL_PACKAGES="${INSTALLPACKAGES:-}"

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

echo "Starting Chaotic-AUR repository installation..."

# Check if Chaotic-AUR is already configured
if grep -q "^\[chaotic-aur\]" /etc/pacman.conf 2>/dev/null; then
    echo "Chaotic-AUR is already configured in /etc/pacman.conf"
else
    echo "Installing Chaotic-AUR repository..."
    
    # Initialize pacman keyring if needed
    echo "Initializing pacman keyring..."
    _init_pacman_keyring
    
    # Receive and sign the primary key
    echo "Importing Chaotic-AUR GPG key..."
    pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key 3056513887B78AEB
    
    # Install keyring and mirrorlist
    echo "Installing chaotic-keyring and chaotic-mirrorlist..."
    pacman -U --noconfirm \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    
    # Configure mirror in /etc/pacman.conf
    echo "Configuring Chaotic-AUR repository in /etc/pacman.conf..."
    
    # Add repository configuration
    echo "" >> /etc/pacman.conf
    echo "[chaotic-aur]" >> /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf
    
    # Configure mirror preference if CDN is selected
    if [ "$MIRROR" = "cdn" ]; then
        echo "Configuring CDN mirror..."
        # Backup original mirrorlist
        cp /etc/pacman.d/chaotic-mirrorlist /etc/pacman.d/chaotic-mirrorlist.backup
        
        # Set CDN as primary mirror
        cat > /etc/pacman.d/chaotic-mirrorlist << 'EOF'
##
## Chaotic-AUR mirrorlist
## Configured to use CDN
##

## CDN (Global)
Server = https://cdn-mirror.chaotic.cx/$repo/$arch
EOF
    else
        echo "Using auto (geo-mirror) configuration..."
        # The default mirrorlist from the package already uses geo-mirror
    fi
    
    # Synchronize package databases
    echo "Synchronizing package databases..."
    pacman -Sy
    
    echo "Chaotic-AUR repository installation completed successfully!"
fi

# Install additional packages if specified
if [ -n "$INSTALL_PACKAGES" ]; then
    echo "Installing additional packages from Chaotic-AUR: $INSTALL_PACKAGES"
    
    # Convert comma-separated list to space-separated
    PACKAGES=$(echo "$INSTALL_PACKAGES" | tr ',' ' ')
    
    # Install packages
    echo "Installing packages: $PACKAGES"
    pacman -S --noconfirm $PACKAGES
    
    echo "Additional packages installed successfully!"
fi

echo "Chaotic-AUR feature installation completed!"