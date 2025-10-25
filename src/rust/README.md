
# Rust and Cargo (rust)

Installs Rust, Cargo, and development tools via rustup for Arch Linux

## Example Usage

```json
"features": {
    "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| rustVersion | Rust toolchain version to install | string | stable |
| additionalTargets | Comma-separated list of additional compilation targets (e.g., 'wasm32-unknown-unknown,x86_64-pc-windows-gnu') | string | - |
| installClippy | Install clippy linter | boolean | true |
| installRustfmt | Install rustfmt code formatter | boolean | true |
| globalCrates | Comma-separated list of crates to install globally via cargo install | string | - |

# 🦀 Rust

## 📝 Description

This feature installs Rust programming language, Cargo package manager, and essential development tools via rustup on Arch Linux. It provides a complete Rust development environment with configurable toolchains, components, and additional tools.

## 🚀 Quick Start

### Basic Installation (Stable Rust)

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {}
    }
}
```

### Complete Development Setup

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "rustVersion": "stable",
            "installClippy": true,
            "installRustfmt": true,
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit",
            "additionalTargets": "wasm32-unknown-unknown"
        }
    }
}
```

## 🔧 Example Configurations

### Nightly Rust with WebAssembly Support

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "rustVersion": "nightly",
            "additionalTargets": "wasm32-unknown-unknown,wasm32-wasi",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,wasm-pack,cargo-generate"
        }
    }
}
```

### Cross-compilation Setup

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "rustVersion": "stable",
            "additionalTargets": "x86_64-pc-windows-gnu,aarch64-unknown-linux-gnu",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cross"
        }
    }
}
```

### Minimal Installation

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "rustVersion": "stable",
            "installClippy": false,
            "installRustfmt": false,
            "globalCrates": ""
        }
    }
}
```

### Development with Popular Crates

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "rustVersion": "stable",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-expand"
        }
    }
}
```

## ⚙️ Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `rustVersion` | string | `"stable"` | Rust toolchain version (`stable`, `beta`, `nightly`) |
| `additionalTargets` | string | `""` | Comma-separated list of compilation targets |
| `installClippy` | boolean | `true` | Install clippy linter |
| `installRustfmt` | boolean | `true` | Install rustfmt code formatter |
| `globalCrates` | string | `""` | Comma-separated list of crates to install globally |

### 🎯 Popular Global Crates

- **`cargo-watch`** - [`cargo-watch`](https://github.com/watchexec/cargo-watch) - Automatically re-run cargo commands on file changes
- **`cargo-edit`** - [`cargo-edit`](https://github.com/killercup/cargo-edit) - Add, remove, and upgrade dependencies
- **`cargo-audit`** - [`cargo-audit`](https://github.com/RustSec/rustsec/tree/main/cargo-audit) - Security vulnerability scanner
- **`cargo-expand`** - [`cargo-expand`](https://github.com/dtolnay/cargo-expand) - Show macro-expanded code
- **`cross`** - [`cross`](https://github.com/cross-rs/cross) - Zero-setup cross compilation

### 🎯 Popular Additional Targets

- **`wasm32-unknown-unknown`** - WebAssembly target
- **`wasm32-wasi`** - WebAssembly System Interface
- **`x86_64-pc-windows-gnu`** - Windows 64-bit
- **`aarch64-unknown-linux-gnu`** - ARM64 Linux
- **`x86_64-apple-darwin`** - macOS 64-bit

## 🏗️ Architecture

### 📦 Installation Method

1. **rustup via pacman** - Install rustup package manager through Arch Linux package manager
2. **Toolchain management** - Use rustup to install and manage Rust toolchains
3. **Component installation** - Add clippy, rustfmt, and other components via rustup
4. **Cargo tools** - Install additional tools via `cargo install`

### 🔧 Environment Setup

- **CARGO_HOME** - Set to `~/.cargo`
- **RUSTUP_HOME** - Set to `~/.rustup`
- **PATH** - Add `~/.cargo/bin` for cargo-installed tools
- **Shell integration** - Configure bash and zsh profiles

### 🛡️ Security Features

- **User-specific installation** - All tools installed in user directory
- **No sudo required** - After initial setup, no elevated privileges needed
- **Vulnerability scanning** - cargo-audit for dependency security checks

## ✅ Compatibility

### 🐧 System Requirements

- **OS**: Arch Linux
- **Architecture**: x86_64, aarch64
- **Dependencies**: curl, git (for some cargo tools)

### 🔗 DevContainer Integration

- Works with any DevContainer base image running Arch Linux
- Compatible with VS Code DevContainers
- Supports multi-stage builds and feature composition

## 🧪 Testing

### 📋 Test Scenarios

- **Basic installation** - Default stable Rust setup
- **Nightly toolchain** - Beta and nightly versions
- **Additional targets** - Cross-compilation support
- **Cargo tools** - All supported cargo utilities
- **Global crates** - User-specified crate installation

### 🔍 Verification Steps

1. Rust compiler availability (`rustc --version`)
2. Cargo package manager (`cargo --version`)
3. Rustup toolchain manager (`rustup --version`)
4. Component availability (clippy, rustfmt)
5. Additional targets installation
6. Cargo tools functionality
7. Environment variable configuration

## 🚨 Troubleshooting

### 🔧 Common Issues

**Installation fails with permission errors:**

- Ensure the feature runs with appropriate user permissions
- Check that rustup is properly initialized for the target user

**Cargo tools not found in PATH:**

- Verify that `~/.cargo/bin` is in PATH
- Source shell profile or restart terminal

**Cross-compilation targets missing:**

- Check target name spelling in `additionalTargets`
- Verify target is supported by current Rust version

**Global crates installation fails:**

- Ensure network connectivity for crate downloads
- Check for conflicting system packages

### 🔍 Debug Commands

```bash
# Check Rust installation
rustc --version
cargo --version
rustup --version

# List installed toolchains
rustup toolchain list

# List installed targets
rustup target list --installed

# List installed components
rustup component list --installed

# Check cargo tools
ls ~/.cargo/bin/

# Verify environment
echo $CARGO_HOME
echo $RUSTUP_HOME
echo $PATH | grep cargo
```

## 📚 Additional Resources

- **📖 Official Documentation**: [Rust Book](https://doc.rust-lang.org/book/)
- **🛠️ Cargo Guide**: [Cargo Book](https://doc.rust-lang.org/cargo/)
- **🔧 Rustup Documentation**: [Rustup Book](https://rust-lang.github.io/rustup/)
- **🦀 Community**: [Rust Users Forum](https://users.rust-lang.org/)

## 🔄 Maintenance

### 📅 Regular Updates

- Monitor Rust release schedule for new stable versions
- Update cargo tool versions as needed
- Review and update popular crate recommendations

### 🧪 Testing Updates

- Test with new Rust versions before updating defaults
- Verify compatibility with latest DevContainer specifications
- Validate cross-compilation targets with new releases


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zyrakq/arch-devcontainer-features/blob/main/src/rust/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
