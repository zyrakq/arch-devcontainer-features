# 🦀 Rust Feature Configuration Examples

This document provides practical examples of how to configure the Rust feature for different development scenarios.

## 📋 Basic Configurations

### 1. Default Setup (Recommended for most projects)

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {}
    }
}
```

**What you get:**

- Rust stable toolchain
- Clippy linter
- Rustfmt formatter
- No global crates (minimal setup)

### 2. Development Setup with Tools

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit"
        }
    }
}
```

**Use case:** Standard development setup with essential cargo tools.

## 🌐 Web Development

### 3. WebAssembly Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "additionalTargets": "wasm32-unknown-unknown,wasm32-wasi",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,wasm-pack,cargo-generate,wasm-bindgen-cli"
        }
    }
}
```

**Use case:** Building WebAssembly modules for web applications.

### 4. Full-Stack Web Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "additionalTargets": "wasm32-unknown-unknown",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-expand,trunk,wasm-pack,leptos-cli,dioxus-cli"
        }
    }
}
```

**Use case:** Modern Rust web frameworks like Leptos, Dioxus, or Yew.

## 🔧 Systems Programming

### 5. Embedded Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "rustVersion": "stable",
            "additionalTargets": "thumbv7em-none-eabihf,thumbv6m-none-eabi,riscv32imc-unknown-none-elf",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-binutils,probe-run,cargo-embed,cargo-flash"
        }
    }
}
```

**Use case:** Microcontroller and embedded systems development.

### 6. Cross-Platform Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "additionalTargets": "x86_64-pc-windows-gnu,aarch64-unknown-linux-gnu,x86_64-apple-darwin",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cross"
        }
    }
}
```

**Use case:** Building applications for multiple operating systems and architectures.

## 🚀 Advanced Development

### 7. Nightly Features Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "rustVersion": "nightly",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-expand,cargo-miri,cargo-fuzz,cargo-asm"
        }
    }
}
```

**Use case:** Experimenting with cutting-edge Rust features and compiler plugins.

### 8. Performance-Critical Applications

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-expand,cargo-asm,cargo-criterion,cargo-bench,flamegraph,perf"
        }
    }
}
```

**Use case:** High-performance applications requiring detailed profiling and optimization.

## 🔐 Security-Focused Development

### 9. Security Auditing Setup

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-deny,cargo-geiger,cargo-crev"
        }
    }
}
```

**Use case:** Projects requiring thorough security analysis and dependency auditing.

### 10. Cryptography Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-fuzz,honggfuzz,afl"
        }
    }
}
```

**Use case:** Developing cryptographic libraries with fuzzing and security testing.

## 📚 Learning and Education

### 11. Rust Learning Environment

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-expand,cargo-play,cargo-show-asm,evcxr_jupyter"
        }
    }
}
```

**Use case:** Educational environments and Rust learning with interactive tools.

### 12. Workshop/Tutorial Setup

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-generate,mdbook"
        }
    }
}
```

**Use case:** Rust workshops, tutorials, and documentation generation.

## 🎮 Game Development

### 13. Game Development with Bevy

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-generate"
        }
    }
}
```

**Use case:** Game development using the Bevy engine or other Rust game frameworks.

## 🔬 Research and Experimentation

### 14. Machine Learning Research

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-expand,evcxr_jupyter"
        }
    }
}
```

**Use case:** Machine learning research with Rust libraries like Candle or tch.

### 15. Blockchain Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "additionalTargets": "wasm32-unknown-unknown",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-expand,cargo-contract,subxt-cli"
        }
    }
}
```

**Use case:** Smart contract development for Substrate-based blockchains.

## 🔧 DevOps and Tooling

### 16. CLI Tool Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-dist,cargo-release"
        }
    }
}
```

**Use case:** Building command-line tools and utilities with proper distribution.

### 17. CI/CD Pipeline Development

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:1": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit,cargo-nextest,cargo-tarpaulin,cargo-llvm-cov"
        }
    }
}
```

**Use case:** Setting up comprehensive testing and coverage reporting for CI/CD.

## 📝 Notes

- **Global Crates**: These are installed via `cargo install` and provide additional cargo subcommands
- **Additional Targets**: Enable cross-compilation for different platforms
- **Rust Version**: Choose `stable` for production, `nightly` for experimental features

## 🔗 Useful Resources

- [Rust Book](https://doc.rust-lang.org/book/)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [Rustup Book](https://rust-lang.github.io/rustup/)
- [Awesome Rust](https://github.com/rust-unofficial/awesome-rust)
