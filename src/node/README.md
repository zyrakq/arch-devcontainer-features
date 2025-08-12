
# Node.js, npm, Yarn, and pnpm (node)

Installs Node.js, npm, and optionally Yarn and pnpm, with sudo-free configuration for Arch Linux

## Example Usage

```json
"features": {
    "ghcr.io/zyrakq/arch-devcontainer-features/node:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| nodeVersion | Node.js version to install (lts, latest, or specific version) | string | lts |
| installMethod | Installation method: pacman or nvm | string | pacman |
| nvmVersion | nvm version to install (e.g., 'v0.39.1' or 'latest') | string | latest |
| installYarn | Install Yarn package manager | boolean | false |
| installPnpm | Install pnpm package manager | boolean | false |
| globalPackages | Comma-separated list of npm packages to install globally | string | - |
| configureNpmPrefix | Configure npm to install global packages without sudo | boolean | true |

# 🟢 Node.js Feature Development Notes

## 📝 Implementation Details

### 🏗️ Architecture Decisions

1. **Two Installation Methods**
    - **📦 pacman**: Default, uses official Arch packages, fast and reliable.
    - **🔄 nvm**: For specific versions, more flexible but slower.

2. **🔐 Sudo-free npm Configuration**
    - Creates `~/.npm-global` directory for global packages.
    - Configures npm prefix to avoid sudo requirements.
    - Automatically adds to PATH in shell profiles.

3. **🧑‍💻 User Detection**
    - Uses same pattern as `yay` feature for user detection.
    - Supports automatic user detection with fallbacks.
    - Handles root user scenarios appropriately.

4. **🔧 Version Management**
    - **nvm**: Version can be specified (`latest` or `v0.39.1`).
    - **Node.js**: Version can be specified (`lts`, `latest`, or `18.17.0`).

5. **📦 Optional Package Managers**
    - **Yarn**: Can be installed via `installYarn` option.
    - **pnpm**: Can be installed via `installPnpm` option.

### ✨ Key Features

- **Version Flexibility**: Supports LTS, latest, or specific versions for Node.js and nvm.
- **Package Manager Choice**: Optional installation of Yarn and pnpm.
- **🐚 Shell Integration**: Automatically configures bash and zsh.
- **🌍 Global Packages**: Optional installation of global npm packages.
- **🛡️ Fallback Handling**: nvm installation falls back to pacman for root.

### 🔒 Security Considerations

- npm prefix configuration eliminates need for sudo on global installs.
- nvm installation only for non-root users (security best practice).
- Proper permission handling for user directories.

## 🚀 Quick Start with Templates

Instead of configuring from scratch, you can use ready-to-use solutions:

- **🐳 Ready Images**: [bartventer/devcontainer-images](https://github.com/bartventer/devcontainer-images) - pre-built DevContainer images for Arch Linux that include this feature
- **📋 Templates**: [zyrakq/arch-devcontainer-templates](https://github.com/zyrakq/arch-devcontainer-templates) - DevContainer templates for Arch Linux with this feature pre-configured

These solutions provide a faster way to get started with Arch Linux DevContainers that already include the Node.js and npm feature.

## � Example Configurations

### Basic Installation (LTS version)

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/node:1": {}
    }
}
```

### Install Specific Version via NVM

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/node:1": {
            "installMethod": "nvm",
            "nodeVersion": "18.17.0",
            "nvmVersion": "v0.39.1"
        }
    }
}
```

### Install with Yarn, pnpm, and Global Packages

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/node:1": {
            "installYarn": true,
            "installPnpm": true,
            "globalPackages": "typescript,nodemon"
        }
    }
}
```

### Latest Version without npm Prefix Configuration

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/node:1": {
            "nodeVersion": "latest",
            "configureNpmPrefix": false
        }
    }
}
```

## 🧪 Testing Strategy

### сценарии тестирования

1. **Basic Installation** (`test.sh`)
    - Default pacman installation.
    - Verify Node.js and npm are available.
    - Check npm prefix configuration.

2. **Global Packages** (`test_with_packages.sh`)
    - Install with global packages.
    - Verify packages are installed and accessible.
    - Test sudo-free installation.

3. **NVM Installation** (`test_nvm_install.sh`)
    - Install via nvm method.
    - Test specific version installation.
    - Verify shell integration.

4. **Yarn/pnpm Installation** (`test_yarn_pnpm.sh`)
    - Install with Yarn and pnpm options.
    - Verify `yarn` and `pnpm` commands are available.

### 🔬 Test Coverage

- Installation methods (pacman, nvm).
- Version specifications (lts, latest, specific).
- Global package installation.
- npm prefix configuration.
- Yarn and pnpm installation.
- Shell profile integration.
- User permission handling.

## 🔗 Dependencies

### 外部依赖

- **bartventer/arch-devcontainer-features**: Provides `archlinux_util.sh`.
- **curl**: Required for nvm installation.
- **git**: May be required by some npm packages.

### 软件包依赖

- **nodejs**: Core Node.js runtime.
- **npm**: Node package manager.
- **base-devel**: May be needed for native module compilation.

## ⚙️ Configuration Files Modified

### 🐚 Shell Profiles

- `~/.bashrc`: Adds PATH and environment variables.
- `~/.zshrc`: Adds PATH and environment variables.

### 📦 npm Configuration

- `~/.npmrc`: Sets prefix configuration.
- `~/.npm-global/`: Global package directory.

## 🌍 Environment Variables Set

- `NPM_CONFIG_PREFIX`: Points to `~/.npm-global`.
- `PATH`: Includes `~/.npm-global/bin`.
- `NVM_DIR`: nvm directory (when using nvm).

## ⚠️ Known Limitations

1. **Root User**: nvm installation not recommended for root.
2. **Shell Reload**: May require shell reload for PATH changes.
3. **Package Compilation**: Some packages may need build tools.

## 🚀 Future Enhancements

### 📈 Potential Improvements

1. **Build Tools**: Optional installation of common build dependencies.
2. **Version Switching**: Better integration with version managers.
3. **Cache Management**: Add options for cleaning npm/yarn/pnpm cache.

### 版本管理

- Consider adding support for multiple Node.js versions.
- Integration with other version managers (fnm, volta).
- Better handling of version conflicts.

## 🔧 Maintenance Notes

### 🔄 Regular Updates

- Monitor nvm version updates.
- Check for new Node.js LTS releases.
- Update documentation examples.

### ✅ Compatibility

- Test with new Arch Linux package updates.
- Verify compatibility with DevContainer spec changes.
- Monitor npm security advisories.

## 🆘 Troubleshooting Common Issues

### 🔌 Installation Issues

1. **Network Problems**: nvm installation requires internet access.
2. **Permission Errors**: Ensure proper user detection.
3. **Path Issues**: Shell profile modifications may need reload.

### 🏃 Runtime Issues

1. **Command Not Found**: Check PATH configuration.
2. **Permission Denied**: Verify npm prefix setup.
3. **Version Conflicts**: Multiple Node.js installations.

## 🏆 Code Quality

### 📜 Shell Script Best Practices

- Use `set -e` for error handling.
- Proper quoting of variables.
- `shellcheck` compliance.
- Error message formatting.

### 🧪 Testing Best Practices

- Test all configuration options.
- Verify cleanup after installation.
- Test error conditions.
- Cross-platform compatibility.

## 📚 Documentation

### 🧑‍💻 User Documentation

- Clear usage examples.
- Troubleshooting guide.
- Configuration options.
- Best practices.

### 🛠️ Developer Documentation

- Implementation details.
- Testing procedures.
- Maintenance guidelines.
- Architecture decisions.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zyrakq/arch-devcontainer-features/blob/main/src/node/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
