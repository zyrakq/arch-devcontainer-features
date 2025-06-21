## 📝 Description

This feature installs .NET SDK and runtime from AUR packages for Arch Linux DevContainers. This is a legacy/compatibility feature that provides .NET through AUR binary packages. Automatically:

-   ✅ Installs .NET Host, SDK, and ASP.NET Core Runtime from AUR
-   📦 Uses AUR binary packages (dotnet-*-bin) for compatibility
-   🔄 Requires yay AUR helper for installation
-   🛠️ Configures global tools directory and PATH
-   🔧 Simplified installation without complex options

**⚠️ Note**: This feature is provided for backward compatibility. For new projects, consider using the main `dotnet` feature with official packages (`packageManager: "pacman"`).

## 🚀 Quick Start with Templates

Instead of configuring from scratch, you can use ready-to-use solutions:

- **🐳 Ready Images**: [bartventer/devcontainer-images](https://github.com/bartventer/devcontainer-images) - pre-built DevContainer images for Arch Linux
- **📋 Templates**: [zyrakq/arch-devcontainer-templates](https://github.com/zyrakq/arch-devcontainer-templates) - DevContainer templates for Arch Linux

## 📋 Example Configurations

### Basic Installation (Latest .NET from AUR)
```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet-bin:1": {}
    }
}
```

### With Version Specification
```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet-bin:1": {
            "dotnetVersion": "latest"
        }
    }
}
```

## 📋 Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `dotnetVersion` | string | `"latest"` | .NET version to install (AUR packages provide latest versions) |

**Note:** ASP.NET Core Runtime is automatically included with AUR packages and cannot be disabled.

## 🔧 What's Installed

### Core Components (AUR Binary Packages)
- **.NET Host** (`dotnet-host-bin`) - Core .NET runtime host
- **.NET Runtime** (`dotnet-runtime-bin`) - .NET runtime
- **.NET SDK** (`dotnet-sdk-bin`) - Complete .NET development kit
- **ASP.NET Core Runtime** (`aspnet-runtime-bin`) - Web application runtime (automatically included)

## 🔍 Verification

After installation, verify everything works:

```bash
# Check .NET version
dotnet --version

# List installed SDKs
dotnet --list-sdks

# List installed runtimes
dotnet --list-runtimes

# Create a new console app (test)
dotnet new console -n TestApp
cd TestApp
dotnet run
```

## ✅ Compatibility

-   **Architecture**: `linux/amd64`, `linux/arm64`
-   **Operating System**: Arch Linux
-   **Requirements**: yay AUR helper (installed via yay feature)

## 📦 Installation Order

This feature requires and installs after:
-   **`ghcr.io/zyrakq/arch-devcontainer-features/yay`** - Required for AUR package installation

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet-bin:1": {}
    }
}
```

## 🏗️ Architecture

This feature uses a stable architecture with Git submodules:

-   **Arch Linux Utilities**: Used through [bartventer/arch-devcontainer-features](https://github.com/bartventer/arch-devcontainer-features)
-   **Stable Version**: Scripts downloaded from submodule commit hash
-   **AUR Integration**: Uses yay for installing binary packages from AUR
-   **Simplified**: Minimal configuration options for basic .NET development

## 🔧 Troubleshooting

### Common Issues

**"yay command not found"**
- Ensure the yay feature is installed first
- Check the installation order in your devcontainer.json

**"dotnet command not found"**
- Restart your terminal or reload shell profile
- Check if PATH includes dotnet tools directory

**AUR package installation fails**
- Verify internet connection
- Check if yay is properly configured
- Try installing manually: `yay -S dotnet-sdk-bin`

### Getting Help

- Check the [feature documentation](https://github.com/zyrakq/arch-devcontainer-features/tree/master/src/dotnet-bin)
- Report issues on [GitHub](https://github.com/zyrakq/arch-devcontainer-features/issues)
- See [.NET documentation](https://docs.microsoft.com/en-us/dotnet/) for .NET-specific help

## 📝 Notes

-   **Legacy Feature**: Provided for backward compatibility with existing configurations
-   **AUR Packages**: Uses binary packages from AUR (dotnet-*-bin)
-   **Simplified**: Minimal options compared to the main dotnet feature
-   **Requires yay**: Must install yay feature first
-   **Latest Versions**: AUR binary packages typically provide latest .NET versions
-   **No Global Tools**: This feature focuses on basic .NET installation only

## 📋 Requirements

-   Container must be running Arch Linux
-   yay AUR helper must be installed (via yay feature)
-   Internet connection for downloading packages from AUR
-   User must have appropriate permissions for package installation

## 🔄 Migration

For new projects, consider migrating to the main dotnet feature:

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet:1": {
            "packageManager": "pacman"
        }
    }
}
```

This provides better integration with system libraries and faster installation.