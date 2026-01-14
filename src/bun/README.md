
# Bun Runtime (bun)

Installs Bun - fast all-in-one JavaScript runtime and toolkit for Arch Linux

## Example Usage

```json
"features": {
    "ghcr.io/zyrakq/arch-devcontainer-features/bun:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Bun version to install (latest, canary, or specific version like 1.0.21) - only works with official install method | string | latest |
| installMethod | Installation method: pacman (default), yay, or official script | string | pacman |
| strictInstall | If true, fail on unavailable method. If false, fallback to next available method | boolean | false |
| globalPackages | Comma-separated list of packages to install globally via bun | string | - |
| installNodeCompat | Install Node.js compatibility shims (node, npm, npx commands pointing to bun) | boolean | false |

# 🚀 Bun Runtime Feature Development Notes

## 📝 Implementation Details

### 🏗️ Architecture Decisions

1. **Three Installation Methods**
    - **📦 pacman**: Default, uses official Arch packages, fast and reliable.
    - **🎯 yay**: Uses AUR package `bun-bin`, requires yay feature.
    - **🔄 official**: Uses official Bun installation script, most flexible for versions.

2. **🔀 Fallback Logic**
    - **Strict Mode (strictInstall=true)**: Installation fails if selected method is unavailable.
    - **Non-Strict Mode (strictInstall=false)**: Automatically falls back to next available method.
    - **Fallback Chain**: yay → pacman → official (or pacman → yay → official, depending on initial choice).

3. **🧑‍💻 User Detection**
    - Uses same pattern as `node` and `yay` features for user detection.
    - Supports automatic user detection with fallbacks.
    - Handles root user scenarios appropriately.

4. **🔧 Version Management**
    - **Bun**: Version can be specified (`latest`, `canary`, or `1.0.21`).
    - Version specification only works with `official` installation method.
    - `pacman` and `yay` install whatever version is in repositories.

5. **🌐 Global Packages**
    - Packages installed via `bun add -g`.
    - Works with all installation methods.
    - PATH automatically configured for global binaries.

6. **🔗 Node.js Compatibility**
    - Optional symlinks: `node`, `npm`, `npx` → `bun`.
    - Allows using Bun as drop-in replacement for Node.js.
    - Useful for projects expecting Node.js commands.

### ✨ Key Features

- **Installation Flexibility**: Three methods with automatic fallback support.
- **Version Control**: Specific version installation via official method.
- **Package Manager Built-in**: Bun includes npm-compatible package manager.
- **🐚 Shell Integration**: Automatically configures bash and zsh.
- **🌍 Global Packages**: Optional installation of global packages.
- **🛡️ Fallback Handling**: Smart fallback to available installation methods.
- **⚡ Performance**: Bun is significantly faster than Node.js for many operations.

### 🔒 Security Considerations

- Official script installation only for non-root users (security best practice).
- Proper permission handling for user directories.
- Verification of Bun installation before proceeding.
- Safe fallback handling with error checking.

## 🚀 Quick Start with Templates

Instead of configuring from scratch, you can use ready-to-use solutions:

- **🐳 Ready Images**: [bartventer/devcontainer-images](https://github.com/bartventer/devcontainer-images) - pre-built DevContainer images for Arch Linux
- **📋 Templates**: [zyrakq/arch-devcontainer-templates](https://github.com/zyrakq/arch-devcontainer-templates) - DevContainer templates for Arch Linux

These solutions provide a faster way to get started with Arch Linux DevContainers.

## 💡 Example Configurations

### Basic Installation (pacman)

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/bun:1": {}
    }
}
```

### Install via AUR (yay)

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/bun:1": {
            "installMethod": "yay"
        }
    }
}
```

### Install Specific Version via Official Script

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/bun:1": {
            "installMethod": "official",
            "version": "1.0.21"
        }
    }
}
```

### Install with Global Packages

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/bun:1": {
            "globalPackages": "typescript,esbuild,prettier"
        }
    }
}
```

### Node.js Compatibility Mode

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/bun:1": {
            "installNodeCompat": true
        }
    }
}
```

### Strict Installation (no fallback)

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/bun:1": {
            "installMethod": "yay",
            "strictInstall": true
        }
    }
}
```

### Advanced Configuration

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {},
        "ghcr.io/zyrakq/arch-devcontainer-features/bun:1": {
            "installMethod": "official",
            "version": "canary",
            "globalPackages": "typescript,@biomejs/biome",
            "installNodeCompat": true,
            "strictInstall": false
        }
    }
}
```

## 🧪 Testing Strategy

### Test Scenarios

1. **Basic Installation** (`test.sh`)
    - Default pacman installation.
    - Verify Bun is available and working.

2. **Global Packages** (`test_with_packages.sh`)
    - Install with global packages.
    - Verify packages are installed and accessible.

3. **Yay Installation** (`test_yay_install.sh`)
    - Install via yay method with bun-bin.
    - Verify yay dependency is satisfied.

4. **Official Installation** (`test_official_install.sh`)
    - Install via official script.
    - Verify version specification works.

5. **Fallback Behavior** (`test_fallback.sh`)
    - Test fallback from unavailable method.
    - Verify non-strict mode works correctly.

6. **Node.js Compatibility** (`test_node_compat.sh`)
    - Verify node, npm, npx symlinks.
    - Test that they point to bun.

7. **Specific Version** (`test_specific_version.sh`)
    - Install specific Bun version.
    - Verify correct version installed.

### 🔬 Test Coverage

- Installation methods (pacman, yay, official).
- Version specifications (latest, canary, specific).
- Global package installation.
- Fallback logic (strict and non-strict modes).
- Node.js compatibility shims.
- Shell profile integration.
- User permission handling.

## 🔗 Dependencies

### External Dependencies

- **bartventer/arch-devcontainer-features**: Provides `archlinux_util.sh`.
- **curl**: Required for official installation method.
- **unzip**: Required for official installation method.
- **yay**: Required for yay installation method.

### Package Dependencies

- **bun**: Core Bun runtime (pacman).
- **bun-bin**: Binary package from AUR (yay).

## ⚙️ Configuration Files Modified

### 🐚 Shell Profiles

- `~/.bashrc`: Adds PATH and BUN_INSTALL environment variable.
- `~/.zshrc`: Adds PATH and BUN_INSTALL environment variable.

### 📦 Bun Configuration

- `~/.bun/`: Bun installation directory (official method).
- `~/.bun/bin/`: Global binaries location.

## 🌍 Environment Variables Set

- `BUN_INSTALL`: Points to `~/.bun` (official method only).
- `PATH`: Includes `~/.bun/bin` (official method only).

## ⚠️ Known Limitations

1. **Version Specification**: Only works with `official` installation method.
2. **Pacman/Yay Versions**: Install whatever version is in repositories, may not be latest.
3. **Shell Reload**: May require shell reload for PATH changes (official method).
4. **Node.js Compatibility**: Symlinks may not be 100% compatible with all Node.js features.

## 🚀 Future Enhancements

### 📈 Potential Improvements

1. **Version Manager**: Integration with bun's built-in version manager.
2. **Build Tools**: Optional installation of common build dependencies.
3. **Performance Monitoring**: Add benchmarking utilities.
4. **Plugin System**: Support for Bun plugins and extensions.

### Release Management

- Monitor Bun version updates.
- Track Arch package updates.
- Update documentation examples.
- Test with new Bun features.

## 🔧 Maintenance Notes

### 🔄 Regular Updates

- Monitor Bun releases and changelog.
- Check for Arch package updates.
- Verify AUR package (bun-bin) is maintained.
- Update documentation examples.

### ✅ Compatibility

- Test with new Arch Linux package updates.
- Verify compatibility with DevContainer spec changes.
- Monitor Bun breaking changes.
- Test Node.js compatibility with new Bun versions.

## 🆘 Troubleshooting Common Issues

### 🔌 Installation Issues

1. **Method Not Available**: Check strictInstall setting, verify fallback chain.
2. **Yay Not Found**: Ensure yay feature is installed first or use different method.
3. **Network Problems**: Official installation requires internet access.
4. **Permission Errors**: Ensure proper user detection and permissions.
5. **Path Issues**: Shell profile modifications may need reload.

### 🏃 Runtime Issues

1. **Command Not Found**: Check PATH configuration, reload shell.
2. **Global Package Errors**: Verify Bun installation, check permissions.
3. **Node.js Compatibility**: Not all Node.js features are supported, check Bun docs.
4. **Version Mismatch**: Remember that version only applies to official method.

### 🛠️ Debugging Tips

- Check installation method used: `bun --version`
- Verify PATH: `echo $PATH | grep bun`
- Check global packages: `bun pm ls -g`
- Test Bun functionality: `bun --help`
- Verify symlinks: `ls -la $(which node)` (if installNodeCompat=true)

## 🏆 Code Quality

### 📜 Shell Script Best Practices

- Use `set -e` for error handling.
- Proper quoting of variables.
- `shellcheck` compliance.
- Error message formatting.
- Verification after installation.
- Smart fallback logic.

### 🧪 Testing Best Practices

- Test all configuration options.
- Verify cleanup after installation.
- Test error conditions.
- Test fallback scenarios.
- Cross-platform compatibility.
- Positive assertion tests (following .clinerules).

## 📚 Documentation

### 🧑‍💻 User Documentation

- Clear usage examples for all installation methods.
- Troubleshooting guide for common issues.
- Configuration options with descriptions.
- Best practices for Node.js compatibility.
- Performance considerations.

### 🛠️ Developer Documentation

- Implementation details and architecture.
- Testing procedures and scenarios.
- Maintenance guidelines.
- Fallback logic explanation.
- Architecture decisions and rationale.

## 🔄 Comparison with Node.js Feature

| Aspect | Node.js Feature | Bun Feature |
|--------|----------------|-------------|
| **Package Manager** | npm (separate) | Built-in |
| **Installation Methods** | pacman, nvm | pacman, yay, official |
| **Fallback Logic** | None | Smart fallback chain |
| **Global Packages** | npm install -g | bun add -g |
| **Runtime** | Node.js only | Runtime + bundler + test runner |
| **Performance** | Standard | Significantly faster |
| **Node.js Compat** | Native | Via symlinks (optional) |

## 📊 Performance Notes

### Why Bun?

- **Faster startup**: Up to 4x faster than Node.js
- **Built-in bundler**: No need for webpack/esbuild/rollup
- **Built-in test runner**: No need for Jest/Vitest
- **Faster package installation**: Significantly faster than npm/yarn/pnpm
- **TypeScript support**: Native TypeScript execution without transpiling
- **JSX support**: Built-in JSX/TSX transformation

### Use Cases

- **Development**: Fast iteration, instant module resolution
- **Testing**: Built-in test runner with watch mode
- **Bundling**: Single-file executables, web bundling
- **Scripts**: Replace shell scripts with TypeScript/JavaScript
- **APIs**: Fast HTTP server with built-in fetch


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zyrakq/arch-devcontainer-features/blob/main/src/bun/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
