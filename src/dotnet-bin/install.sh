#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Zyrakq.
# Licensed under the MIT License or Apache License 2.0.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/zyrakq/arch-devcontainer-features/tree/master/src/dotnet-bin/README.md
# Maintainer: Zyrakq

set -e

# shellcheck disable=SC2034
DOTNET_VERSION="${DOTNETVERSION:-"latest"}"
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

# Function to run yay as appropriate user
run_yay() {
    PACKAGES="$*"
    if [ "${USERNAME}" = "root" ]; then
        # If running as root, find a non-root user or create one
        POSSIBLE_USERS=("vscode" "abc" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
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
    echo "Packages to install: $PACKAGES"
    
    # Install packages one by one to better track failures
    for package in $PACKAGES; do
        echo "Installing package: $package"
        if sudo -u "$YAY_USER" yay -S --noconfirm "$package"; then
            echo "✓ Successfully installed: $package"
        else
            echo "✗ Failed to install: $package"
            # Continue with other packages instead of failing completely
        fi
    done

    # Clean up temporary user if created
    if [ "$YAY_USER" = "yay-user" ]; then
        userdel -r "$YAY_USER"
        rm -f "/etc/sudoers.d/$YAY_USER"
        echo "Removed temporary user $YAY_USER."
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

# Function to check if a global tool exists in NuGet
check_tool_availability() {
    local tool_name="$1"
    echo "Checking availability of tool: $tool_name"
    
    # Try to get package info from NuGet API
    local nuget_url="https://api.nuget.org/v3-flatcontainer/${tool_name}/index.json"
    if curl -s --fail "$nuget_url" >/dev/null 2>&1; then
        echo "✓ Tool $tool_name is available in NuGet"
        return 0
    else
        echo "✗ Tool $tool_name is not available in NuGet"
        return 1
    fi
}

# Function to get AUR package names
get_aur_packages() {
    # AUR packages include ASP.NET runtime automatically as dependency
    # Order matters: host -> runtime -> sdk -> aspnet-runtime
    local packages="dotnet-host-bin dotnet-runtime-bin dotnet-sdk-bin aspnet-runtime-bin"
    
    echo "$packages"
}

echo "Starting .NET installation via AUR packages..."
echo "Requested .NET version: $DOTNET_VERSION (AUR packages provide latest)"
echo "Note: ASP.NET Core Runtime is included automatically with AUR packages"

# Get AUR packages to install
PACKAGES_TO_INSTALL=$(get_aur_packages)
echo "Packages to install: $PACKAGES_TO_INSTALL"

# Install .NET packages via yay
run_yay $PACKAGES_TO_INSTALL

# Verify installation
echo "Verifying .NET installation..."

# Check if dotnet command exists
if command -v dotnet &> /dev/null; then
    echo "✓ dotnet command found at: $(command -v dotnet)"
    
    # Try to get version
    if dotnet_version=$(dotnet --version 2>&1); then
        echo "✓ .NET installation completed successfully!"
        echo "Installed .NET version: $dotnet_version"
    else
        echo "✗ dotnet command exists but version check failed:"
        echo "$dotnet_version"
        
        # Additional diagnostics
        echo "Checking installed packages..."
        echo "AUR packages installed:"
        pacman -Q | grep -E "dotnet.*-bin" || echo "No dotnet-*-bin packages found"
        
        echo "PATH: $PATH"
        echo "Dotnet location: $(command -v dotnet 2>/dev/null || echo 'not found')"
        
        err ".NET installation verification failed"
        exit 1
    fi
else
    echo "✗ dotnet command not found"
    
    # Additional diagnostics
    echo "Checking installed packages..."
    echo "AUR packages installed:"
    pacman -Q | grep -E "dotnet.*-bin" || echo "No dotnet-*-bin packages found"
    
    echo "PATH: $PATH"
    echo "Looking for dotnet in common locations:"
    find /usr -name "dotnet" 2>/dev/null || echo "dotnet binary not found in /usr"
    
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
    
    AVAILABLE_TOOLS=""
    UNAVAILABLE_TOOLS=""
    
    # Check availability of each tool first
    for tool in $TOOLS_TO_INSTALL; do
        if check_tool_availability "$tool"; then
            AVAILABLE_TOOLS="$AVAILABLE_TOOLS $tool"
        else
            UNAVAILABLE_TOOLS="$UNAVAILABLE_TOOLS $tool"
        fi
    done
    
    # Report unavailable tools
    if [ -n "$UNAVAILABLE_TOOLS" ]; then
        echo "Warning: The following tools are not available in NuGet and will be skipped:$UNAVAILABLE_TOOLS"
    fi
    
    # Install available tools
    if [ -n "$AVAILABLE_TOOLS" ]; then
        echo "Installing available global tools:$AVAILABLE_TOOLS"
        
        for tool in $AVAILABLE_TOOLS; do
            echo "Installing global tool: $tool"
            if [ "${USERNAME}" != "root" ]; then
                if run_as_user "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\" && dotnet tool install --global $tool"; then
                    echo "✓ Successfully installed: $tool"
                else
                    echo "✗ Failed to install: $tool"
                fi
            else
                if dotnet tool install --global $tool; then
                    echo "✓ Successfully installed: $tool"
                else
                    echo "✗ Failed to install: $tool"
                fi
            fi
        done
        
        echo "Global tools installation completed!"
    else
        echo "No available global tools to install."
    fi
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