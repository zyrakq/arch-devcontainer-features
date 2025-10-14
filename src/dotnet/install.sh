#!/usr/bin/env bash
#-----------------------------------------------------------------------------------------------------------------
# Copyright (c) Zyrakq.
# Licensed under the MIT License or Apache License 2.0.
#-----------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/zyrakq/arch-devcontainer-features/tree/master/src/dotnet/README.md
# Maintainer: Zyrakq

set -e

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

# Function to install packages via pacman (official packages)
install_via_pacman() {
    local packages="$*"
    echo "Installing packages via pacman: $packages"
    
    # Update package database
    sudo_if pacman -Sy
    
    # Check if packages are available before installing
    echo "Checking package availability..."
    local available_packages=""
    local unavailable_packages=""
    
    for pkg in $packages; do
        if pacman -Si "$pkg" >/dev/null 2>&1; then
            echo "✓ Package $pkg is available"
            available_packages="$available_packages $pkg"
        else
            echo "✗ Package $pkg is NOT available"
            unavailable_packages="$unavailable_packages $pkg"
        fi
    done
    
    if [ -n "$unavailable_packages" ]; then
        echo "Unavailable packages:$unavailable_packages"
        echo "Searching for available .NET packages..."
        echo "Available .NET packages in repository:"
        pacman -Ss "dotnet" | grep -E "^(extra|core|community)/" | head -10 || true
        echo "Available ASP.NET packages in repository:"
        pacman -Ss "aspnet" | grep -E "^(extra|core|community)/" | head -5 || true
        
        # Try to suggest alternatives
        echo "Warning: Some official packages are not available."
        echo "Consider using the dotnet-bin feature for AUR packages instead."
        
        if [ -z "$available_packages" ]; then
            err "No .NET packages are available in official repositories."
            err "Please use the dotnet-bin feature to install from AUR."
            exit 1
        fi
    fi
    
    # Install only available packages
    if [ -n "$available_packages" ]; then
        echo "Installing available packages:$available_packages"
        sudo_if pacman -S --noconfirm $available_packages
    fi
}

# Function to get official package names based on version
get_official_packages() {
    local version="$1"
    local install_aspnet="$2"
    local packages=""
    
    # Check what .NET packages are actually available in the repository
    echo "Checking available .NET packages in official repositories..." >&2
    
    # Update package database first to ensure we have latest package info
    pacman -Sy >/dev/null 2>&1 || true
    
    # Base packages - dotnet-host is installed automatically as dependency
    if [ "$version" = "latest" ]; then
        # Try latest version packages first
        if pacman -Si "dotnet-sdk" >/dev/null 2>&1; then
            packages="dotnet-sdk"
        else
            echo "Warning: No .NET SDK package found in official repositories" >&2
        fi
        
        if [ "$install_aspnet" = "true" ]; then
            if pacman -Si "aspnet-runtime" >/dev/null 2>&1; then
                packages="$packages aspnet-runtime"
            else
                echo "Warning: No ASP.NET runtime package found in official repositories" >&2
            fi
        fi
    else
        # Try versioned packages
        case "$version" in
            "8.0"|"7.0"|"6.0")
                if pacman -Si "dotnet-sdk-${version}" >/dev/null 2>&1; then
                    packages="dotnet-sdk-${version}"
                else
                    echo "Warning: .NET SDK ${version} not found in official repositories" >&2
                    echo "Trying to fallback to latest version..." >&2
                    if pacman -Si "dotnet-sdk" >/dev/null 2>&1; then
                        packages="dotnet-sdk"
                    fi
                fi
                
                if [ "$install_aspnet" = "true" ]; then
                    if pacman -Si "aspnet-runtime-${version}" >/dev/null 2>&1; then
                        packages="$packages aspnet-runtime-${version}"
                    elif pacman -Si "aspnet-runtime" >/dev/null 2>&1; then
                        packages="$packages aspnet-runtime"
                    fi
                fi
                ;;
            *)
                echo "Warning: Version $version may not be available in official packages" >&2
                echo "Trying to fallback to latest version..." >&2
                if pacman -Si "dotnet-sdk" >/dev/null 2>&1; then
                    packages="dotnet-sdk"
                    if [ "$install_aspnet" = "true" ] && pacman -Si "aspnet-runtime" >/dev/null 2>&1; then
                        packages="$packages aspnet-runtime"
                    fi
                fi
                ;;
        esac
    fi
    
    echo "$packages"
}

echo "Starting .NET installation..."
echo "Using official packages from extra repository"
echo "Requested .NET version: $DOTNET_VERSION"
echo "Install ASP.NET Runtime: $INSTALL_ASPNET_RUNTIME"

# Determine packages to install from official repositories
echo "Determining available packages..."
PACKAGES_TO_INSTALL=$(get_official_packages "$DOTNET_VERSION" "$INSTALL_ASPNET_RUNTIME")

if [ -z "$PACKAGES_TO_INSTALL" ]; then
    err "No .NET packages found in official repositories!"
    err "Please check if .NET packages are available in your Arch Linux version"
    err "For AUR packages, use the dotnet-bin feature instead"
    exit 1
fi

echo "Packages to install: $PACKAGES_TO_INSTALL"

# Install .NET packages via pacman
install_via_pacman $PACKAGES_TO_INSTALL

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
        if [ "$PACKAGE_MANAGER" = "yay" ]; then
            echo "AUR packages installed:"
            pacman -Q | grep -E "dotnet.*-bin" || echo "No dotnet-*-bin packages found"
        else
            echo "Official packages installed:"
            pacman -Q | grep dotnet || echo "No dotnet packages found"
        fi
        
        echo "PATH: $PATH"
        echo "Dotnet location: $(command -v dotnet 2>/dev/null || echo 'not found')"
        
        err ".NET installation verification failed"
        exit 1
    fi
else
    echo "✗ dotnet command not found"
    
    # Additional diagnostics
    echo "Checking installed packages..."
    echo "Official packages installed:"
    pacman -Q | grep dotnet || echo "No dotnet packages found"
    
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