# 🦀 Rust Feature Configuration Examples (Pre-compiled)

This document provides practical examples of how to configure the Rust feature (pre-compiled pacman packages) for different development scenarios.

## 📋 Basic Configurations

### 1. Default Setup (Recommended for most projects)

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {}
    }
}
```

**What you get:**

- Rust stable toolchain (includes clippy and rustfmt)
- Rust source code (rust-src)
- Rust-analyzer LSP server
- Fast installation (~30 seconds)

### 2. Minimal Setup

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

**Use case:** Bare minimum Rust installation (rustc, cargo, clippy, rustfmt only).

**Note:** clippy and rustfmt are always included with the rust package and cannot be disabled.

### 3. Development Setup with Tools

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit"
        }
    }
}
```

**Use case:** Standard development setup with essential cargo tools.

## 🌐 Web Development

### 4. WebAssembly Development with Cross

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "wasm-pack,cargo-generate,cross"
        }
    }
}
```

**Use case:** Building WebAssembly modules using `wasm-pack` and `cross` for compilation.

**Note:** For native wasm targets, consider also using `rust-bin` feature.

### 5. Full-Stack Web Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "cargo-watch,cargo-edit,trunk,leptos-cli,dioxus-cli"
        }
    }
}
```

**Use case:** Modern Rust web frameworks like Leptos, Dioxus, or Yew.

## 🔧 Systems Programming

### 6. CLI Tool Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-dist,cargo-release"
        }
    }
}
```

**Use case:** Building command-line tools with proper distribution.

### 7. Cross-Compilation Setup

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "cross,cargo-watch,cargo-edit"
        }
    }
}
```

**Use case:** Cross-compiling for multiple platforms using `cross`.

**Example usage:**

```bash
cross build --target aarch64-unknown-linux-gnu
cross build --target x86_64-pc-windows-gnu
```

## 🚀 Advanced Development

### 8. Performance-Critical Applications

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "cargo-watch,cargo-criterion,cargo-bench,flamegraph"
        }
    }
}
```

**Use case:** High-performance applications requiring detailed profiling.

### 9. Security-Focused Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "cargo-audit,cargo-deny,cargo-geiger,cargo-crev"
        }
    }
}
```

**Use case:** Projects requiring thorough security analysis.

## 📚 Learning and Education

### 10. Rust Learning Environment

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-expand"
        }
    }
}
```

**Use case:** Educational environments and Rust learning.

## 🔧 DevOps and CI/CD

### 11. CI/CD Pipeline Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "cargo-nextest,cargo-tarpaulin,cargo-llvm-cov"
        }
    }
}
```

**Use case:** Setting up comprehensive testing and coverage reporting.

## 🔄 Alternative: Nightly and Additional Targets

### 12. Nightly Rust with Cross-Compilation

If you need nightly Rust or additional compilation targets, use the `rust-bin` feature instead:

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust-bin:1": {
            "rustVersion": "nightly",
            "installClippy": true,
            "installRustfmt": true,
            "additionalTargets": "wasm32-unknown-unknown,aarch64-unknown-linux-gnu"
        }
    }
}
```

**Use case:** Nightly toolchain with WebAssembly and cross-compilation support.

**Benefits:**

- Nightly Rust for experimental features
- Additional compilation targets via rustup
- Full toolchain management flexibility
- Includes clippy, rustfmt, rust-src, and rust-analyzer

**Note:** The `rust` and `rust-bin` features should NOT be used together. Choose one based on your needs.

## 📝 Notes

- **Global Crates**: Installed via `cargo install` into `~/.cargo/bin`
- **Installation Speed**: ~30-60 seconds for base, additional time for crates
- **Version**: Stable only (for beta/nightly use `rust-bin`)
- **Cross-compilation**: Use `cross` crate or combine with `rust-bin`

## 🔗 Useful Resources

- [Rust Book](https://doc.rust-lang.org/book/)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [Awesome Rust](https://github.com/rust-unofficial/awesome-rust)
- [Cross Documentation](https://github.com/cross-rs/cross)
