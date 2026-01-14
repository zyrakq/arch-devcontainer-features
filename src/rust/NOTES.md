# 🦀 Rust (Pre-compiled)

## 📝 Description

This feature installs Rust programming language and Cargo package manager from **pre-compiled packages** in the official Arch Linux repositories. This provides a fast installation (10-60 seconds) with the stable Rust toolchain.

## 🤔 When to Use This Feature

Use the **`rust`** feature (this one) when you need:

- ✅ **Fast installation** - Pre-compiled binaries install in 10-60 seconds
- ✅ **Stable Rust** - Production-ready stable toolchain
- ✅ **Standard development** - Most Rust projects work with stable
- ✅ **IDE integration** - Includes rust-analyzer and rust-src
- ✅ **CI/CD environments** - Where build time matters

Use **`rust-bin`** instead when you need:

- 🔧 Beta or Nightly toolchains
- 🔧 Multiple toolchain management via rustup
- 🔧 Additional compilation targets (wasm, windows, etc.)
- 🔧 Specific Rust versions

## 🚀 Quick Start

### Basic Installation (Recommended)

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {}
    }
}
```

This installs Rust stable with **clippy**, **rustfmt** (always included), **rust-src**, and **rust-analyzer**.

### Minimal Installation

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "installRustSrc": false,
            "installRustAnalyzer": false
        }
    }
}
```

Minimal setup includes rustc, cargo, clippy, and rustfmt only (without IDE components).

### With Global Crates

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit"
        }
    }
}
```

## ⚙️ Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `installRustSrc` | boolean | `true` | Install Rust source code (for IDE support) |
| `installRustAnalyzer` | boolean | `true` | Install rust-analyzer LSP server |
| `globalCrates` | string | `""` | Comma-separated list of crates to install globally |

**Note:** `clippy` and `rustfmt` are always installed as part of the `rust` package and cannot be disabled.

### 🎯 Popular Global Crates

- **`cargo-watch`** - Automatically re-run cargo commands on file changes
- **`cargo-edit`** - Add, remove, and upgrade dependencies
- **`cargo-audit`** - Security vulnerability scanner
- **`cargo-expand`** - Show macro-expanded code
- **`cross`** - Zero-setup cross compilation

## 🏗️ Architecture

### 📦 Installation Method

1. **pacman packages** - Install from official Arch repositories
   - `rust` - Rust compiler, cargo, clippy, and rustfmt (all-in-one package)
   - `rust-src` - Rust source code (optional, for IDE support)
   - `rust-analyzer` - LSP server (optional, for IDE integration)

2. **cargo install** - Install additional tools via cargo

### ⚡ Performance

- **Installation time**: 10-60 seconds (vs 10-60+ minutes with rustup)
- **Download size**: ~200MB pre-compiled binaries
- **Disk usage**: ~1-1.5GB (vs ~2GB with rustup)

### 🔧 Limitations

- Only **stable** Rust version available
- No built-in support for **additional targets**
  - Use `cross` crate for cross-compilation
  - Or install `rust-bin` feature alongside for rustup targets
- No **beta/nightly** toolchains
- Version controlled by Arch repositories (usually 1-2 weeks behind latest stable)

## 🔄 Cross-Compilation

For cross-compilation, use the `cross` crate:

```bash
cargo install cross
cross build --target aarch64-unknown-linux-gnu
```

Alternatively, use the `rust-bin` feature for more flexibility with additional targets:

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust-bin:1": {
            "rustVersion": "stable",
            "installClippy": true,
            "installRustfmt": true,
            "additionalTargets": "wasm32-unknown-unknown,aarch64-unknown-linux-gnu"
        }
    }
}
```

The `rust-bin` feature provides rustup-based installation with support for multiple targets and toolchains.

## ✅ Compatibility

### 🐧 System Requirements

- **OS**: Arch Linux
- **Architecture**: x86_64, aarch64
- **Dependencies**: None (base-devel recommended for some crates)

### 🔗 DevContainer Integration

- Works with any DevContainer base image running Arch Linux
- Compatible with VS Code DevContainers
- Supports multi-stage builds and feature composition

## 🧪 Testing

### 📋 Test Scenarios

- **Basic installation** - Default stable Rust setup
- **Minimal installation** - Without IDE components
- **Global crates** - User-specified crate installation
- **Full setup** - All components enabled

### 🔍 Verification Steps

1. Rust compiler availability (`rustc --version`)
2. Cargo package manager (`cargo --version`)
3. Component availability (clippy, rustfmt, rust-analyzer)
4. Cargo tools functionality
5. Environment variable configuration

## 🚨 Troubleshooting

### 🔧 Common Issues

**Rust version is not the latest:**

- Arch repositories update weekly, usually 1-2 weeks behind
- For absolute latest, use `rust-bin` feature with rustup

**Need beta/nightly Rust:**

- Use `rust-bin` feature which provides rustup
- This feature only provides stable from pacman

**Cross-compilation targets missing:**

- Use `cross` crate: `cargo install cross`
- Or use `rust-bin` feature which provides rustup with target management

**Cargo tools not found in PATH:**

- Verify that `~/.cargo/bin` is in PATH
- Source shell profile or restart terminal

### 🔍 Debug Commands

```bash
# Check Rust installation
rustc --version
cargo --version

# Check components
cargo clippy --version
rustfmt --version
rust-analyzer --version

# Check cargo tools
ls ~/.cargo/bin/

# Verify environment
echo $PATH | grep cargo
```

## 📚 Additional Resources

- **📖 Official Documentation**: [Rust Book](https://doc.rust-lang.org/book/)
- **🛠️ Cargo Guide**: [Cargo Book](https://doc.rust-lang.org/cargo/)
- **🦀 Community**: [Rust Users Forum](https://users.rust-lang.org/)
- **📦 Arch Package**: [rust](https://archlinux.org/packages/extra/x86_64/rust/)

## 🔄 Maintenance

### 📅 Regular Updates

- Monitor Rust release schedule
- Arch packages typically updated within 1-2 weeks of stable release
- Update global crate versions as needed

### 🧪 Testing Updates

- Test with new Rust versions before updating defaults
- Verify compatibility with latest DevContainer specifications
- Validate package availability in Arch repositories
