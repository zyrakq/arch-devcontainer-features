## 📝 Description

This feature installs .NET SDK, runtime, and development tools via yay for Arch Linux DevContainers. Automatically:

-   ✅ Installs .NET Host, SDK, and optionally ASP.NET Core Runtime
-   🔧 Configures global tools directory and PATH
-   🌍 Optionally installs Entity Framework CLI, Code Generator, and custom tools
-   🛡️ Handles proper permissions and user management

## 🚀 Quick Start with Templates

Instead of configuring from scratch, you can use ready-to-use solutions:

- **🐳 Ready Images**: [bartventer/devcontainer-images](https://github.com/bartventer/devcontainer-images) - pre-built DevContainer images for Arch Linux that include this feature
- **📋 Templates**: [zyrakq/arch-devcontainer-templates](https://github.com/zyrakq/arch-devcontainer-templates) - DevContainer templates for Arch Linux with this feature pre-configured

These solutions provide a faster way to get started with Arch Linux DevContainers that already include the .NET feature.

## 📋 Example Configurations

### Basic Installation (Latest .NET)
```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet:1": {}
    }
}
```

### Advanced Configuration
```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet:1": {
            "dotnetVersion": "8.0",
            "installAspNetRuntime": true,
            "installEntityFramework": true,
            "installAspNetCodeGenerator": true,
            "installDevCerts": true,
            "installGlobalTools": "dotnet-outdated-global,dotnet-format"
        }
    }
}
```

### Web Development Setup
```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet:1": {
            "dotnetVersion": "8.0",
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
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet:1": {
            "dotnetVersion": "8.0",
            "installEntityFramework": true,
            "installGlobalTools": "dotnet-outdated-global"
        }
    }
}
```

### Console Applications (Minimal)
```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet:1": {
            "installAspNetRuntime": false
        }
    }
}
```

### Specific Version
```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet:1": {
            "dotnetVersion": "7.0"
        }
    }
}
```

## 📋 Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `dotnetVersion` | string | `"latest"` | .NET version to install (latest, 8.0, 7.0, 6.0) |
| `installAspNetRuntime` | boolean | `true` | Install ASP.NET Core Runtime |
| `installEntityFramework` | boolean | `false` | Install Entity Framework Core CLI (dotnet-ef) |
| `installAspNetCodeGenerator` | boolean | `false` | Install ASP.NET Core Code Generator |
| `installDevCerts` | boolean | `false` | Install development certificates tool |
| `installGlobalTools` | string | `""` | Comma-separated list of additional global tools to install |

## 🔧 What's Installed

### Core Components
- **.NET Host** (`dotnet-host-bin`) - Core .NET runtime host
- **.NET SDK** (`dotnet-sdk-bin`) - Complete .NET development kit
- **ASP.NET Core Runtime** (`aspnet-runtime-bin`) - Web application runtime (optional)

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

## 🔍 Verification

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
-   **Requirements**: yay AUR helper

## 📦 Installation Order

This feature installs after:
-   **`ghcr.io/zyrakq/arch-devcontainer-features/yay`** - Required for AUR package installation

Make sure to include the yay feature in your configuration:

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet:1": {}
    }
}
```

## 🏗️ Architecture

This feature uses a stable architecture with Git submodules:

-   **Arch Linux Utilities**: Used through [bartventer/arch-devcontainer-features](https://github.com/bartventer/arch-devcontainer-features)
-   **Stable Version**: Scripts downloaded from submodule commit hash (currently pinned to specific commit)
-   **Dynamic URLs**: Install script dynamically determines submodule commit and downloads from correct version
-   **Reliability**: Falls back to `main` branch if specific commit is not found

### 🔄 Script Version Updates

The feature downloads utility scripts based on the current submodule commit hash. Script versions are only updated when:
1.  The bartventer-features submodule is updated to a new commit/tag
2.  Changes are committed to this repository
3.  Features are republished to GHCR

**📝 Note**: Scripts are not automatically updated - they follow the specific commit referenced by the submodule.

## 🔧 Troubleshooting

### Common Issues

**"yay command not found"**
- Ensure the yay feature is installed first
- Check the installation order in your devcontainer.json

**"dotnet command not found"**
- Restart your terminal or reload shell profile
- Check if PATH includes dotnet tools directory

**Global tool installation fails**
- Verify internet connection
- Check if the tool name is correct
- Try installing manually: `dotnet tool install --global <tool-name>`

**Permission errors**
- The feature automatically handles permissions
- Global tools are installed in user directory (`~/.dotnet/tools`)

### Getting Help

- Check the [feature documentation](https://github.com/zyrakq/arch-devcontainer-features/tree/master/src/dotnet)
- Report issues on [GitHub](https://github.com/zyrakq/arch-devcontainer-features/issues)
- See [.NET documentation](https://docs.microsoft.com/en-us/dotnet/) for .NET-specific help

## 📝 Notes

-   Feature checks for existing .NET installation and configures accordingly
-   Global tools are installed in user directory to avoid sudo requirements
-   Automatically configures bash and zsh for dotnet tools PATH
-   Correctly handles permissions for both root and non-root users
-   Uses yay for fast binary package installation from AUR

## 📋 Requirements

-   Container must be running Arch Linux
-   yay AUR helper must be installed (via yay feature)
-   Internet connection for downloading packages from AUR
-   User must have appropriate permissions for package installation