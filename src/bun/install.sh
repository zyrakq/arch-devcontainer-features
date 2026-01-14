#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Zyrakq.
# Licensed under the MIT License or Apache License 2.0.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/zyrakq/arch-devcontainer-features/tree/master/src/bun/README.md
# Maintainer: Zyrakq

set -e

# shellcheck disable=SC2034
VERSION="${VERSION:-"latest"}"
INSTALL_METHOD="${INSTALLMETHOD:-"pacman"}"
STRICT_INSTALL="${STRICTINSTALL:-"false"}"
GLOBAL_PACKAGES="${GLOBALPACKAGES:-""}"
INSTALL_NODE_COMPAT="${INSTALLNODECOMPAT:-"false"}"
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

# Function to check if install method is available
check_install_method_available() {
    case "$1" in
        pacman)
            command -v pacman >/dev/null 2>&1
            ;;
        yay)
            command -v yay >/dev/null 2>&1
            ;;
        official)
            command -v curl >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to determine fallback method
determine_fallback_method() {
    local current_method="$1"
    
    if [ "$STRICT_INSTALL" = "true" ]; then
        err "Requested installation method '$current_method' is not available and strictInstall is enabled"
        exit 1
    fi
    
    echo "⚠️  Installation method '$current_method' is not available" >&2
    echo "→  Attempting fallback (strictInstall=false)..." >&2
    
    # Fallback chain: yay -> pacman -> official
    case "$current_method" in
        yay)
            if check_install_method_available pacman; then
                echo "pacman"
            elif check_install_method_available official; then
                echo "official"
            else
                err "No available installation methods found"
                exit 1
            fi
            ;;
        pacman)
            if check_install_method_available yay; then
                echo "yay"
            elif check_install_method_available official; then
                echo "official"
            else
                err "No available installation methods found"
                exit 1
            fi
            ;;
        official)
            if check_install_method_available pacman; then
                echo "pacman"
            elif check_install_method_available yay; then
                echo "yay"
            else
                err "Official installation method requires curl but it's not available"
                exit 1
            fi
            ;;
        *)
            err "Unknown installation method: $current_method"
            exit 1
            ;;
    esac
}

# Function to install Bun via pacman
install_bun_pacman() {
    echo "Installing Bun via pacman..."
    check_and_install_packages bun
    echo "✓ Bun installed via pacman"
}

# Function to install Bun via yay
install_bun_yay() {
    echo "Installing Bun via yay..."
    
    if ! command -v yay >/dev/null 2>&1; then
        err "yay is not installed but required for this installation method"
        return 1
    fi
    
    # Install bun-bin from AUR
    run_as_user "yay -S --noconfirm bun-bin"
    echo "✓ Bun installed via yay (bun-bin)"
}

# Function to install Bun via official script
install_bun_official() {
    echo "Installing Bun via official script..."
    
    # Ensure curl and unzip are available
    check_and_install_packages curl unzip
    
    # Prepare version flag
    VERSION_FLAG=""
    if [ "$VERSION" != "latest" ]; then
        VERSION_FLAG="bun-v${VERSION}"
    fi
    
    # Install Bun using official script
    run_as_user "curl -fsSL https://bun.sh/install | bash -s -- ${VERSION_FLAG}"
    echo "✓ Bun installed via official script"
}

echo "Starting Bun installation..."

# Check if requested method is available
if ! check_install_method_available "$INSTALL_METHOD"; then
    FALLBACK_METHOD=$(determine_fallback_method "$INSTALL_METHOD")
    echo "→ Switching to fallback method: $FALLBACK_METHOD"
    INSTALL_METHOD="$FALLBACK_METHOD"
fi

# Install Bun based on selected method
case "$INSTALL_METHOD" in
    pacman)
        install_bun_pacman || exit 1
        ;;
    yay)
        install_bun_yay || {
            if [ "$STRICT_INSTALL" = "false" ]; then
                echo "→ yay installation failed, trying fallback..."
                if check_install_method_available pacman; then
                    install_bun_pacman || install_bun_official
                else
                    install_bun_official
                fi
                USER_HOME=$(eval echo "~$USERNAME")
                BUN_INSTALL="$USER_HOME/.bun"
                [ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"
            else
                exit 1
            fi
        }
        ;;
    official)
        install_bun_official || exit 1
        USER_HOME=$(eval echo "~$USERNAME")
        BUN_INSTALL="$USER_HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        ;;
    *)
        err "Unknown installation method: $INSTALL_METHOD"
        exit 1
        ;;
esac

# Verify Bun installation
if ! command -v bun >/dev/null 2>&1; then
    err "Bun installation failed - bun command not found"
    exit 1
fi

echo "Bun installed successfully: $(bun --version)"

# Configure PATH for shell profiles
USER_HOME=$(eval echo "~$USERNAME")
BUN_INSTALL="$USER_HOME/.bun"

# Only configure PATH if Bun was installed via official method (to user's home)
if [ "$INSTALL_METHOD" = "official" ] || [ -d "$BUN_INSTALL" ]; then
    echo "Configuring Bun PATH in shell profiles..."
    
    for profile in "$USER_HOME/.bashrc" "$USER_HOME/.zshrc"; do
        if [ -f "$profile" ]; then
            if ! grep -q "BUN_INSTALL" "$profile"; then
                echo "" >> "$profile"
                echo "# Bun configuration" >> "$profile"
                echo "export BUN_INSTALL=\"\$HOME/.bun\"" >> "$profile"
                echo "export PATH=\"\$BUN_INSTALL/bin:\$PATH\"" >> "$profile"
                echo "✓ Added Bun to $(basename $profile)"
            else
                echo "→ Bun already configured in $(basename $profile)"
            fi
        fi
    done
fi

# Install global packages if specified
if [ -n "$GLOBAL_PACKAGES" ]; then
    echo "Installing global packages: $GLOBAL_PACKAGES"
    
    # Convert comma-separated list to space-separated
    PACKAGES=$(echo "$GLOBAL_PACKAGES" | tr ',' ' ')
    
    # Set PATH to include Bun
    export PATH="$BUN_INSTALL/bin:$PATH"
    
    # Install packages globally
    if [ "${USERNAME}" != "root" ]; then
        run_as_user "PATH=\"$BUN_INSTALL/bin:\$PATH\" bun add -g $PACKAGES"
    else
        bun add -g $PACKAGES
    fi
    
    echo "✓ Global packages installed successfully"
fi

# Install Node.js compatibility shims if requested
if [ "$INSTALL_NODE_COMPAT" = "true" ]; then
    echo "Installing Node.js compatibility shims..."
    
    # Determine where Bun is installed
    BUN_PATH=$(command -v bun)
    
    if [ -z "$BUN_PATH" ]; then
        err "Cannot create Node.js compatibility - bun command not found"
        exit 1
    fi
    
    # Determine the bin directory
    if [ -d "$BUN_INSTALL/bin" ]; then
        BIN_DIR="$BUN_INSTALL/bin"
    else
        BIN_DIR=$(dirname "$BUN_PATH")
    fi
    
    # Create symlinks
    for cmd in node npm npx; do
        if [ -f "$BIN_DIR/$cmd" ] || [ -L "$BIN_DIR/$cmd" ]; then
            echo "→ $cmd already exists in $BIN_DIR, skipping..."
        else
            ln -s "$BUN_PATH" "$BIN_DIR/$cmd"
            echo "✓ Created symlink: $cmd -> bun"
        fi
    done
    
    echo "✓ Node.js compatibility shims installed"
fi

# Display installation summary
echo ""
echo "=== Installation Summary ==="
echo "Bun version: $(bun --version)"
echo "Installation method: $INSTALL_METHOD"
if [ -n "$GLOBAL_PACKAGES" ]; then
    echo "Global packages: $GLOBAL_PACKAGES"
fi
if [ "$INSTALL_NODE_COMPAT" = "true" ]; then
    echo "Node.js compatibility: enabled (node, npm, npx -> bun)"
fi
echo "=========================="
echo ""
echo "✓ Bun feature installation completed!"
