
# Chaotic-AUR Repository (chaotic-aur)

Installs and configures Chaotic-AUR repository for pre-built AUR packages on Arch Linux

## Example Usage

```json
"features": {
    "ghcr.io/zyrakq/arch-devcontainer-features/chaotic-aur:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| mirror | Mirror to use for Chaotic-AUR (auto = geo-mirror, cdn = CDN) | string | auto |
| installPackages | Comma-separated list of packages to install from Chaotic-AUR after setup | string | - |

# 🎨 Chaotic-AUR Repository

## 📝 Description

Chaotic-AUR is an unofficial repository for Arch Linux that provides pre-built packages from the AUR (Arch User Repository). This feature automatically:

- ✅ Checks compatibility with Arch Linux
- 🔑 Imports and configures GPG keys
- 📦 Installs chaotic-keyring and chaotic-mirrorlist
- ⚙️ Configures /etc/pacman.conf with selected mirror
- 🔄 Synchronizes package databases
- ➕ Optionally installs packages from Chaotic-AUR

**Benefits:**

- 🚀 **Fast Installation**: Pre-built packages, no compilation needed
- 💾 **Disk Space**: Saves space by avoiding build dependencies
- ⏱️ **Time Saving**: Instant installation vs. hours of compilation
- 🔒 **Security**: Official GPG-signed packages

## 🚀 Quick Start with Templates

Instead of configuring from scratch, you can use ready-to-use solutions:

- **🐳 Ready Images**: [bartventer/devcontainer-images](https://github.com/bartventer/devcontainer-images) - pre-built DevContainer images for Arch Linux that can be extended with this feature
- **📋 Templates**: [zyrakq/arch-devcontainer-templates](https://github.com/zyrakq/arch-devcontainer-templates) - DevContainer templates for Arch Linux that can be extended with this feature

These solutions provide a faster way to get started with Arch Linux DevContainers.

## 💡 Example Configurations

### Basic Setup (Auto Mirror)

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/chaotic-aur:1": {}
    }
}
```

### With Package Installation

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/chaotic-aur:1": {
            "installPackages": "visual-studio-code-bin,google-chrome,discord"
        }
    }
}
```

### Using CDN Mirror

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/chaotic-aur:1": {
            "mirror": "cdn",
            "installPackages": "spotify,slack-desktop"
        }
    }
}
```

### Combined with Other Features

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/chaotic-aur:1": {
            "installPackages": "visual-studio-code-bin"
        },
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "rustVersion": "stable"
        }
    }
}
```

## 🎛️ Options

### mirror

- **Type**: `string`
- **Values**: `"auto"`, `"cdn"`
- **Default**: `"auto"`
- **Description**: Mirror to use for Chaotic-AUR
  - `auto` - Uses geo-mirror (automatically selects closest mirror based on location)
  - `cdn` - Uses CDN (Content Delivery Network for global distribution)

### installPackages

- **Type**: `string`
- **Default**: `""`
- **Description**: Comma-separated list of packages to install from Chaotic-AUR after setup
- **Example**: `"visual-studio-code-bin,google-chrome,discord,spotify"`

## ✅ Compatibility

- **Architecture**: `linux/amd64`, `linux/arm64`
- **Operating System**: Arch Linux
- **Requirements**: pacman, curl (installed automatically if needed)

## 📦 Installation Order

This feature installs after:

- **`ghcr.io/bartventer/arch-devcontainer-features/common-utils`** - Provides base Arch Linux utilities and ensures proper installation order

## 🏗️ Architecture

This feature uses a stable architecture with Git submodules:

- **Arch Linux Utilities**: Used through [bartventer/arch-devcontainer-features](https://github.com/bartventer/arch-devcontainer-features)
- **Stable Version**: Scripts downloaded from submodule commit hash (currently pinned to specific commit)
- **Dynamic URLs**: Install script dynamically determines submodule commit and downloads from correct version
- **Reliability**: Falls back to `main` branch if specific commit is not found

### 🔄 Script Version Updates

The feature downloads utility scripts based on the current submodule commit hash. Script versions are only updated when:

1. The bartventer-features submodule is updated to a new commit/tag
2. Changes are committed to this repository
3. Features are republished to GHCR

**📝 Note**: Scripts are not automatically updated - they follow the specific commit referenced by the submodule.

## 📝 Notes

- Feature checks for existing Chaotic-AUR configuration and skips if already configured
- GPG keys are automatically imported and signed
- Repository is added to `/etc/pacman.conf` with proper configuration
- Package databases are synchronized after repository setup
- Packages are installed using `pacman -S --noconfirm` for automatic confirmation
- Mirror selection affects download speed based on geographic location

## 🔧 Troubleshooting

### Repository Already Configured

If you see "Chaotic-AUR is already configured", the feature detected an existing configuration and skipped installation. This is normal and safe.

### GPG Key Import Fails

If GPG key import fails:

1. Check internet connectivity
2. Try using a different keyserver
3. Verify firewall settings allow keyserver access

### Package Not Found

If a package is not found in Chaotic-AUR:

1. Verify package name is correct
2. Check package availability at [Chaotic-AUR packages](https://github.com/chaotic-aur/pkgbuilds)
3. Try updating package databases: `pacman -Sy`

### Mirror Connection Issues

If experiencing slow downloads or connection issues:

- Try switching between `auto` and `cdn` mirrors
- Check [Chaotic-AUR status](https://aur.chaotic.cx/) for service status
- Verify network connectivity

## 📋 Requirements

- Container must be running Arch Linux
- Root privileges for package installation
- Internet connection for downloading packages
- Sufficient disk space for packages

## 🔗 Useful Links

- [Chaotic-AUR Official Documentation](https://aur.chaotic.cx/docs)
- [Chaotic-AUR Package List](https://github.com/chaotic-aur/pkgbuilds)
- [Arch Linux Wiki - Unofficial Repositories](https://wiki.archlinux.org/title/Unofficial_user_repositories)

## 🆚 Chaotic-AUR vs Yay

| Feature | Chaotic-AUR | Yay |
|---------|-------------|-----|
| Installation Speed | ⚡ Fast (pre-built) | 🐌 Slow (compilation) |
| Disk Space | 💾 Less (no build deps) | 📦 More (build dependencies) |
| Package Availability | 📊 Limited (popular packages) | 🌐 Full AUR |
| Security | 🔒 GPG-signed | 🔒 Build from source |
| Use Case | Production, CI/CD | Development, custom builds |

**Recommendation**: Use Chaotic-AUR for popular packages and fast setup. Use Yay for packages not available in Chaotic-AUR or when you need the latest AUR packages.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zyrakq/arch-devcontainer-features/blob/main/src/chaotic-aur/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
