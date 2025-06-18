#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Zyrakq.
# Licensed under the MIT License.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/zyrakq/arch-devcontainer-features/tree/master/src/node/README.md
# Maintainer: Zyrakq

set -e

# shellcheck disable=SC2034
NODE_VERSION="${NODEVERSION:-"lts"}"
INSTALL_METHOD="${INSTALLMETHOD:-"pacman"}"
NVM_VERSION="${NVMVERSION:-"latest"}"
INSTALL_YARN="${INSTALLYARN:-"false"}"
INSTALL_PNPM="${INSTALLPNPM:-"false"}"
GLOBAL_PACKAGES="${GLOBALPACKAGES:-""}"
CONFIGURE_NPM_PREFIX="${CONFIGURENPMPREFIX:-"true"}"
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

echo "Starting Node.js installation..."

# Install Node.js based on selected method
if [ "$INSTALL_METHOD" = "nvm" ]; then
    echo "Installing Node.js via nvm..."
    
    # Install curl if not present
    check_and_install_packages curl
    
    # Determine nvm version
    if [ "$NVM_VERSION" = "latest" ]; then
        NVM_VERSION=$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
    fi
    echo "Installing nvm $NVM_VERSION..."
    

    # Install nvm
    run_as_user "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash"

    # Source nvm and install Node.js
    USER_HOME=$(eval echo "~$USERNAME")
    NVM_DIR="$USER_HOME/.nvm"

    # Install Node.js version
    if [ "$NODE_VERSION" = "lts" ]; then
        run_as_user "export NVM_DIR=\"$NVM_DIR\" && [ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\" && nvm install --lts && nvm use --lts && nvm alias default lts/*"
    elif [ "$NODE_VERSION" = "latest" ]; then
        run_as_user "export NVM_DIR=\"$NVM_DIR\" && [ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\" && nvm install node && nvm use node && nvm alias default node"
    else
        run_as_user "export NVM_DIR=\"$NVM_DIR\" && [ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\" && nvm install $NODE_VERSION && nvm use $NODE_VERSION && nvm alias default $NODE_VERSION"
    fi

    # Add nvm to shell profiles
    for profile in "$USER_HOME/.bashrc" "$USER_HOME/.zshrc"; do
        if [ -f "$profile" ]; then
            if ! grep -q "NVM_DIR" "$profile"; then
                echo "" >> "$profile"
                echo "# nvm configuration" >> "$profile"
                echo "export NVM_DIR=\"\$HOME/.nvm\"" >> "$profile"
                echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"" >> "$profile"
                echo "[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"" >> "$profile"
            fi
        fi
    done
fi

if [ "$INSTALL_METHOD" = "pacman" ]; then
    echo "Installing Node.js via pacman..."
    
    # Check if Node.js is already installed
    if command -v node &> /dev/null; then
        echo "Node.js is already installed: $(node --version)"
    else
        echo "Installing Node.js and npm packages..."
        check_and_install_packages nodejs npm
        echo "Node.js installation completed: $(node --version)"
        echo "npm installation completed: $(npm --version)"
    fi
fi

# Configure npm prefix for sudo-free global installs
if [ "$CONFIGURE_NPM_PREFIX" = "true" ]; then
    echo "Configuring npm for sudo-free global package installation..."
    
    if [ "${USERNAME}" != "root" ]; then
        USER_HOME=$(eval echo "~$USERNAME")
        NPM_GLOBAL_DIR="$USER_HOME/.npm-global"
        
        # Create npm global directory
        run_as_user "mkdir -p \"$NPM_GLOBAL_DIR\""
        
        # Configure npm prefix
        run_as_user "npm config set prefix \"$NPM_GLOBAL_DIR\""
        
        # Add npm global bin to PATH in shell profiles
        for profile in "$USER_HOME/.bashrc" "$USER_HOME/.zshrc"; do
            if [ -f "$profile" ]; then
                if ! grep -q "npm-global/bin" "$profile"; then
                    echo "" >> "$profile"
                    echo "# npm global packages" >> "$profile"
                    echo "export PATH=\"\$HOME/.npm-global/bin:\$PATH\"" >> "$profile"
                    echo "export NPM_CONFIG_PREFIX=\"\$HOME/.npm-global\"" >> "$profile"
                fi
            fi
        done
        
        # Set environment variables for current session
        export PATH="$NPM_GLOBAL_DIR/bin:$PATH"
        export NPM_CONFIG_PREFIX="$NPM_GLOBAL_DIR"
        
        echo "npm configured to install global packages in $NPM_GLOBAL_DIR"
    else
        echo "Skipping npm prefix configuration for root user"
    fi
fi

# Install Yarn and pnpm if specified
if [ "$INSTALL_YARN" = "true" ]; then
    echo "Installing Yarn..."
    if [ "${USERNAME}" != "root" ] && [ "$CONFIGURE_NPM_PREFIX" = "true" ]; then
        run_as_user "npm install -g yarn"
    else
        sudo_if "npm install -g yarn"
    fi
    echo "Yarn installed successfully!"
fi

if [ "$INSTALL_PNPM" = "true" ]; then
    echo "Installing pnpm..."
    if [ "${USERNAME}" != "root" ] && [ "$CONFIGURE_NPM_PREFIX" = "true" ]; then
        run_as_user "npm install -g pnpm"
    else
        sudo_if "npm install -g pnpm"
    fi
    echo "pnpm installed successfully!"
fi

# Install global npm packages if specified
if [ -n "$GLOBAL_PACKAGES" ]; then
    echo "Installing global npm packages: $GLOBAL_PACKAGES"
    
    # Convert comma-separated list to space-separated
    PACKAGES=$(echo "$GLOBAL_PACKAGES" | tr ',' ' ')
    
    # Install packages
    if [ "${USERNAME}" != "root" ] && [ "$CONFIGURE_NPM_PREFIX" = "true" ]; then
        # Install as user with configured prefix
        USER_HOME=$(eval echo "~$USERNAME")
        NPM_GLOBAL_DIR="$USER_HOME/.npm-global"
        run_as_user "export PATH=\"$NPM_GLOBAL_DIR/bin:\$PATH\" && export NPM_CONFIG_PREFIX=\"$NPM_GLOBAL_DIR\" && npm install -g $PACKAGES"
    else
        # Install globally (may require sudo)
        if [ "$(id -u)" = "0" ]; then
            npm install -g $PACKAGES
        else
            sudo npm install -g $PACKAGES
        fi
    fi
    
    echo "Global packages installed successfully!"
fi

echo "Node.js feature installation completed!"

# Display installation summary
echo ""
echo "=== Installation Summary ==="
if command -v node &> /dev/null; then
    echo "Node.js version: $(node --version)"
fi
if command -v npm &> /dev/null; then
    echo "npm version: $(npm --version)"
    if [ "$CONFIGURE_NPM_PREFIX" = "true" ] && [ "${USERNAME}" != "root" ]; then
        USER_HOME=$(eval echo "~$USERNAME")
        echo "npm global prefix: $USER_HOME/.npm-global"
        echo "Global packages can be installed without sudo: npm install -g <package>"
    fi
fi
if [ "$INSTALL_YARN" = "true" ] && command -v yarn &> /dev/null; then
    echo "Yarn version: $(yarn --version)"
fi
if [ "$INSTALL_PNPM" = "true" ] && command -v pnpm &> /dev/null; then
    echo "pnpm version: $(pnpm --version)"
fi
echo "=========================="
