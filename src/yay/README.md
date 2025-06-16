
# Yay AUR Helper (yay)

Installs yay AUR helper for Arch Linux

## Example Usage

```json
"features": {
    "ghcr.io/zeritiq/arch-devcontainer-features/yay:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| installPackages | Comma-separated list of AUR packages to install after yay setup (optional) | string | - |

## 📝 Description

Yay is an AUR helper written in Go that allows easy installation of packages from the AUR. This feature automatically:

-   ✅ Checks compatibility with Arch Linux
-   📦 Installs necessary dependencies (base-devel, git)
-   📥 Clones and builds yay from AUR
-   ➕ Optionally installs additional AUR packages

## 💡 Example Configurations

### With Additional AUR Packages
```json
{
    "features": {
        "ghcr.io/zeritiq/arch-devcontainer-features/yay:1": {
            "installPackages": "visual-studio-code-bin,discord,google-chrome"
        }
    }
}
```

## ✅ Compatibility

-   **Architecture**: `linux/amd64`, `linux/arm64`
-   **Operating System**: Arch Linux
-   **Requirements**: base-devel, git (installed automatically if needed)

## 📦 Installation Order

This feature installs after:
-   **`ghcr.io/bartventer/arch-devcontainer-features/common-utils`** - Provides base Arch Linux utilities and ensures proper installation order

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

## 📝 Notes

-   Feature checks for existing yay installation and skips if already installed
-   Installation occurs in a temporary directory that is cleaned up after completion
-   Additional packages use `--noconfirm` flag for automatic confirmation
-   Correctly handles permissions for both root and non-root users

## 🔧 Troubleshooting

If you encounter installation issues:

1.  Ensure the container is based on Arch Linux
2.  Check package availability in AUR
3.  Verify user has permissions to install packages
4.  Check installation logs for specific errors

## 📋 Requirements

-   Container must be running Arch Linux
-   User must have appropriate permissions for package installation
-   Internet connection for downloading packages from AUR


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zeritiq/arch-devcontainer-features/blob/main/src/yay/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
