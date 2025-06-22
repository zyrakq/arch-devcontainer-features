## 📝 Description

This feature installs .NET SDK and runtime from AUR packages for Arch Linux DevContainers. This is a legacy/compatibility feature that provides .NET through AUR binary packages. Automatically:

-   ✅ Installs .NET Host, SDK, and ASP.NET Core Runtime from AUR
-   📦 Uses AUR binary packages (dotnet-*-bin) for compatibility
-   🔄 Requires yay AUR helper for installation
-   🛠️ Configures global tools directory and PATH
-   🌍 Optionally installs Entity Framework CLI, Code Generator, and custom tools

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

### Advanced Configuration with Global Tools
```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet-bin:1": {
            "installEntityFramework": true,
            "installAspNetCodeGenerator": true,
            "installDevCerts": true,
            "installGlobalTools": "dotnet-format"
        }
    }
}
```

### Web Development Setup
```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet-bin:1": {
            "installEntityFramework": true,
            "installAspNetCodeGenerator": true,
            "installDevCerts": true
        }
    }
}
```

### API Development
```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet-bin:1": {
            "installEntityFramework": true,
            "installGlobalTools": "dotnet-format"
        }
    }
}
```

## 📋 Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `dotnetVersion` | string | `"latest"` | .NET version to install (AUR packages provide latest versions) |
| `installEntityFramework` | boolean | `false` | Install Entity Framework Core CLI (dotnet-ef) |
| `installAspNetCodeGenerator` | boolean | `false` | Install ASP.NET Core Code Generator |
| `installDevCerts` | boolean | `false` | Install development certificates tool |
| `installGlobalTools` | string | `""` | Comma-separated list of additional global tools to install |

**Note:** ASP.NET Core Runtime is automatically included with AUR packages and cannot be disabled.

## 🔧 What's Installed

### Core Components (AUR Binary Packages)
- **.NET Host** (`dotnet-host-bin`) - Core .NET runtime host
- **.NET Runtime** (`dotnet-runtime-bin`) - .NET runtime
- **.NET SDK** (`dotnet-sdk-bin`) - Complete .NET development kit
- **ASP.NET Core Runtime** (`aspnet-runtime-bin`) - Web application runtime (automatically included)

### Global Tools (Optional)
- **Entity Framework Core CLI** (`dotnet-ef`) - Database migrations and scaffolding
- **ASP.NET Core Code Generator** (`dotnet-aspnet-codegenerator`) - Code scaffolding for MVC/API
- **Development Certificates** (`dotnet-dev-certs`) - HTTPS development certificates
- **Custom Tools** - Any additional tools specified in `installGlobalTools`

## 🛠️ Global Tools

After installation, you can install additional global tools:

```bash
# Install Entity Framework CLI
dotnet tool install --global dotnet-ef

# Install code formatting tool
dotnet tool install --global dotnet-format

# List installed tools
dotnet tool list --global

# Update all tools
dotnet tool update --global dotnet-ef
```

## � Verification

After installation, verify everything works:

```bash
# Check .NET version
dotnet --version

# List installed SDKs
dotnet --list-sdks

# List installed runtimes
dotnet --list-runtimes

# Check global tools
dotnet tool list --global

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

**Global tool installation fails**
- Verify internet connection
- Check if the tool name is correct
- Try installing manually: `dotnet tool install --global <tool-name>`

**Permission errors**
- The feature automatically handles permissions
- Global tools are installed in user directory (`~/.dotnet/tools`)

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
-   **Global Tools Support**: Supports installation of Entity Framework CLI, ASP.NET Code Generator, and custom tools

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