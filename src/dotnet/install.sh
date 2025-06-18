#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Zyrakq.
# Licensed under the MIT License.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/zyrakq/arch-devcontainer-features/tree/master/src/dotnet/README.md
# Maintainer: Zyrakq

set -e

# shellcheck disable=SC2034
DOTNET_VERSION="${DOTNETVERSION:-"latest"}"
INSTALL_ASPNET_RUNTIME="${INSTALLASPNETRUNTIME:-"true"}"
INSTALL_ENTITY_FRAMEWORK="${INSTALLENTITYFRAMEWORK:-"false"}"
INSTALL_ASPNET_CODEGENERATOR="${INSTALLASPNETCODEGENERATOR:-"false"}"
INSTALL_DEV_CERTS="${INSTALLDEVCERTS:-"false"}"
INSTALL_GLOBAL_TOOLS="${INSTALLGLOBALTOOLS:-""}"
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

# Check if yay is available
if ! command -v yay &> /dev/null; then
    err "yay is not installed. Please install the yay feature first."
    exit 1
fi

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

# Function to run yay as appropriate user
run_yay() {
    PACKAGES="$*"
    if [ "${USERNAME}" = "root" ]; then
        # If running as root, find a non-root user or create one
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
}

echo "Starting .NET installation..."

# Determine packages to install based on version
PACKAGES_TO_INSTALL="dotnet-host-bin dotnet-sdk-bin"

if [ "$DOTNET_VERSION" != "latest" ]; then
    # For specific versions, try to use versioned packages
    PACKAGES_TO_INSTALL="dotnet-host-bin dotnet-sdk-bin-${DOTNET_VERSION}"
    echo "Installing .NET SDK version: $DOTNET_VERSION"
else
    echo "Installing latest .NET SDK version"
fi

# Add ASP.NET Runtime if requested
if [ "$INSTALL_ASPNET_RUNTIME" = "true" ]; then
    if [ "$DOTNET_VERSION" != "latest" ]; then
        PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL aspnet-runtime-bin-${DOTNET_VERSION}"
    else
        PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL aspnet-runtime-bin"
    fi
    echo "ASP.NET Core Runtime will be installed"
fi

# Install .NET packages via yay
echo "Installing .NET packages: $PACKAGES_TO_INSTALL"
run_yay $PACKAGES_TO_INSTALL

# Verify installation
if command -v dotnet &> /dev/null; then
    echo ".NET installation completed successfully!"
    echo "Installed .NET version: $(dotnet --version)"
else
    err ".NET installation failed - dotnet command not found"
    exit 1
fi

# Configure dotnet tools PATH
USER_HOME=$(eval echo "~$USERNAME")
DOTNET_TOOLS_PATH="$USER_HOME/.dotnet/tools"

# Add dotnet tools to PATH in shell profiles
if [ "${USERNAME}" != "root" ]; then
    for profile in "$USER_HOME/.bashrc" "$USER_HOME/.zshrc"; do
        if [ -f "$profile" ]; then
            if ! grep -q "\.dotnet/tools" "$profile"; then
                echo "" >> "$profile"
                echo "# .NET tools" >> "$profile"
                echo "export PATH=\"\$HOME/.dotnet/tools:\$PATH\"" >> "$profile"
            fi
        fi
    done
    
    # Set environment variables for current session
    export PATH="$DOTNET_TOOLS_PATH:$PATH"
    
    echo "Configured .NET tools PATH: $DOTNET_TOOLS_PATH"
fi

# Install global tools
TOOLS_TO_INSTALL=""

# Add predefined tools based on options
if [ "$INSTALL_ENTITY_FRAMEWORK" = "true" ]; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL dotnet-ef"
    echo "Entity Framework Core CLI will be installed"
fi

if [ "$INSTALL_ASPNET_CODEGENERATOR" = "true" ]; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL dotnet-aspnet-codegenerator"
    echo "ASP.NET Core Code Generator will be installed"
fi

if [ "$INSTALL_DEV_CERTS" = "true" ]; then
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL dotnet-dev-certs"
    echo "Development certificates tool will be installed"
fi

# Add custom global tools
if [ -n "$INSTALL_GLOBAL_TOOLS" ]; then
    # Convert comma-separated list to space-separated
    CUSTOM_TOOLS=$(echo "$INSTALL_GLOBAL_TOOLS" | tr ',' ' ')
    TOOLS_TO_INSTALL="$TOOLS_TO_INSTALL $CUSTOM_TOOLS"
    echo "Additional global tools will be installed: $CUSTOM_TOOLS"
fi

# Install global tools if any are specified
if [ -n "$TOOLS_TO_INSTALL" ]; then
    echo "Installing .NET global tools: $TOOLS_TO_INSTALL"
    
    for tool in $TOOLS_TO_INSTALL; do
        echo "Installing global tool: $tool"
        if [ "${USERNAME}" != "root" ]; then
            run_as_user "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\" && dotnet tool install --global $tool"
        else
            dotnet tool install --global $tool
        fi
    done
    
    echo "Global tools installation completed!"
fi

echo ".NET feature installation completed!"

# Display installation summary
echo ""
echo "=== Installation Summary ==="
if command -v dotnet &> /dev/null; then
    echo ".NET version: $(dotnet --version)"
    
    # Check installed runtimes
    echo "Installed runtimes:"
    dotnet --list-runtimes 2>/dev/null || echo "  Unable to list runtimes"
    
    # Check installed SDKs
    echo "Installed SDKs:"
    dotnet --list-sdks 2>/dev/null || echo "  Unable to list SDKs"
    
    # List global tools if any were installed
    if [ -n "$TOOLS_TO_INSTALL" ]; then
        echo "Installed global tools:"
        if [ "${USERNAME}" != "root" ]; then
            run_as_user "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\" && dotnet tool list --global" 2>/dev/null || echo "  Unable to list global tools"
        else
            dotnet tool list --global 2>/dev/null || echo "  Unable to list global tools"
        fi
    fi
    
    if [ "${USERNAME}" != "root" ]; then
        echo ".NET tools path: $DOTNET_TOOLS_PATH"
        echo "Global tools can be installed with: dotnet tool install --global <tool-name>"
    fi
fi
echo "=========================="