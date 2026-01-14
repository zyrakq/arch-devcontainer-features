# Arch Linux DevContainer Features

A collection of DevContainer features for Arch Linux, providing stable and reliable development container experiences.

## 🚀 Available Features

### 📦 [Yay AUR Helper](src/yay/README.md)

Installs yay - a popular AUR helper for easy installation of packages from the Arch User Repository.

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {
            "installPackages": "visual-studio-code-bin,discord"
        }
    }
}
```

### 🎨 [Chaotic-AUR Repository](src/chaotic-aur/README.md)

Configures Chaotic-AUR repository for fast installation of pre-built AUR packages without compilation.

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/chaotic-aur:1": {
            "mirror": "auto",
            "installPackages": "visual-studio-code-bin,discord"
        }
    }
}
```

### 📁 [Clone Repository](src/clone-repo/README.md)

Automatically clones a Git repository into your devcontainer workspace during container creation.

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/user/repo.git",
            "targetDir": "/workspace/project"
        }
    }
}
```

### 🟢 [Node.js and npm](src/node/README.md)

Installs Node.js and npm with sudo-free configuration for Arch Linux DevContainers.

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/node:1": {
            "nodeVersion": "lts",
            "globalPackages": "typescript,nodemon"
        }
    }
}
```

### 🚀 [Bun Runtime](src/bun/README.md)

Installs Bun - fast all-in-one JavaScript runtime and toolkit for Arch Linux with smart fallback installation methods.

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/bun:1": {
            "installMethod": "pacman",
            "globalPackages": "typescript,esbuild"
        }
    }
}
```

### 🦀 [Rust and Cargo (Pre-compiled)](src/rust/README.md)

Installs Rust programming language and Cargo package manager from pre-compiled packages for fast installation (10-60 seconds). Includes clippy, rustfmt, rust-src, and rust-analyzer.

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust:2": {
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit"
        }
    }
}
```

**Use this when:** You need stable Rust with fast installation for standard development.

**Note:** clippy and rustfmt are always included and cannot be disabled.

### 🦀 [Rust and Cargo (Rustup)](src/rust-bin/README.md)

Installs Rust programming language, Cargo package manager, and development tools via rustup for Arch Linux. Provides beta/nightly toolchains and additional compilation targets.

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/rust-bin:1": {
            "rustVersion": "stable",
            "rustupProfile": "minimal",
            "additionalTargets": "wasm32-unknown-unknown",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit"
        }
    }
}
```

**Use this when:** You need beta/nightly toolchains, multiple toolchain management, or additional compilation targets.

### 🟣 [.NET SDK and Runtime](src/dotnet/README.md)

Installs .NET SDK, runtime, and development tools from official Arch Linux packages.

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet:1": {
            "dotnetVersion": "8.0",
            "installEntityFramework": true,
            "installGlobalTools": "dotnet-format"
        }
    }
}
```

### 🟣 [.NET SDK and Runtime (AUR)](src/dotnet-bin/README.md)

Legacy feature that installs .NET SDK and runtime from AUR packages. ASP.NET Core Runtime is included automatically.

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

## 🏗️ Architecture

### Stable Dependency on bartventer/arch-devcontainer-features

This project uses a Git submodules architecture for stability:

```sh
arch-devcontainer-features/
├── src/                     # Our features
│   ├── yay/
│   ├── chaotic-aur/
│   ├── clone-repo/
│   ├── node/
│   ├── bun/
│   ├── rust/               # Rust and Cargo feature (pre-compiled)
│   ├── rust-bin/           # Rust and Cargo feature (rustup)
│   ├── dotnet/
│   └── dotnet-bin/
└── vendor/                  # Dependencies
    └── bartventer-features/ # Git submodule v1.24.5
        └── scripts/
            └── archlinux_util_setup.sh
```

### Architecture Benefits

- ✅ **Stability**: Dependency version pinned to v1.24.5
- ✅ **Reliability**: Works without external service dependencies
- ✅ **Controlled updates**: Updates only after testing
- ✅ **Offline capability**: All necessary scripts available locally

## 🚀 Quick Start

### 🎯 Ready-to-use Solutions

For quick start, you can use:

- **🐳 Ready Images**: [bartventer/devcontainer-images](https://github.com/bartventer/devcontainer-images) - ready-to-use DevContainer images for Arch Linux that can be extended with these features
- **📋 Templates**: [zyrakq/arch-devcontainer-templates](https://github.com/zyrakq/arch-devcontainer-templates) - DevContainer templates for Arch Linux that can be extended with these features

### 📄 Creating devcontainer.json

```json
{
    "name": "Arch Linux DevContainer",
    "image": "ghcr.io/bartventer/devcontainer-images/base-archlinux:latest",
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/yay:1": {
            "installPackages": "git,vim,curl"
        },
        "ghcr.io/zyrakq/arch-devcontainer-features/node:1": {
            "nodeVersion": "lts",
            "globalPackages": "typescript,nodemon"
        },
        "ghcr.io/zyrakq/arch-devcontainer-features/rust-bin:1": {
            "rustVersion": "stable",
            "globalCrates": "cargo-watch,cargo-edit,cargo-audit"
        },
        "ghcr.io/zyrakq/arch-devcontainer-features/dotnet:1": {
            "dotnetVersion": "8.0",
            "installEntityFramework": true
        },
        "ghcr.io/zyrakq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/your-org/your-project.git",
            "targetDir": "/workspace"
        }
    },
    "postCreateCommand": "node --version && npm --version && rustc --version && cargo --version && dotnet --version && echo 'DevContainer ready!'"
}
```

## 🔧 Development

### Feature Dependencies

All features in this repository install after `ghcr.io/bartventer/arch-devcontainer-features/common-utils` to ensure proper installation order and use scripts from the vendored `bartventer-features` submodule.

**Important Notes:**

- Features dynamically download scripts based on the current submodule commit hash
- Script versions are only updated when the submodule is updated to a new commit/tag
- Features will fallback to `main` branch if submodule commit is not found

### Updating Dependencies (Submodule)

```bash
# Check current submodule version
git submodule status

# Check available versions
cd vendor/bartventer-features
git fetch --tags
git tag --sort=-version:refname | head -10

# Update to new version (recommended: use tags)
git checkout v1.25.0
cd ../..
git add vendor/bartventer-features
git commit -m "Update bartventer-features to v1.25.0"

# Verify the commit hash that will be used
git ls-tree HEAD vendor/bartventer-features
```

### Script URL Generation

Features automatically generate URLs using the submodule commit hash:

```bash
# Current submodule commit
COMMIT=$(git ls-tree HEAD vendor/bartventer-features | awk '{print $3}')

# Generated URL
URL="https://raw.githubusercontent.com/bartventer/arch-devcontainer-features/${COMMIT}/scripts/archlinux_util_setup.sh"
```

### Project Structure

```sh
├── .devcontainer/           # DevContainer configuration for development
├── src/                     # DevContainer features
│   ├── yay/                # Yay AUR helper feature
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   └── README.md
│   ├── chaotic-aur/        # Chaotic-AUR repository feature
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   ├── NOTES.md
│   │   └── README.md
│   ├── clone-repo/         # Clone repository feature
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   └── README.md
│   ├── node/               # Node.js and npm feature
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   ├── NOTES.md
│   │   └── README.md
│   ├── bun/                # Bun runtime feature
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   ├── NOTES.md
│   │   └── README.md
│   ├── rust/               # Rust and Cargo feature (pre-compiled)
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   ├── NOTES.md
│   │   ├── examples.md
│   │   └── README.md
│   ├── rust-bin/           # Rust and Cargo feature (rustup)
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   ├── NOTES.md
│   │   ├── examples.md
│   │   └── README.md
│   ├── dotnet/             # .NET SDK and runtime feature (official packages)
│   │   ├── devcontainer-feature.json
│   │   ├── install.sh
│   │   ├── NOTES.md
│   │   └── README.md
│   └── dotnet-bin/         # .NET SDK and runtime feature (AUR packages)
│       ├── devcontainer-feature.json
│       ├── install.sh
│       └── NOTES.md
├── vendor/                 # Git submodule dependencies
│   └── bartventer-features/
├── test/                   # Feature tests
└── README.md              # This file
```

## 📋 Compatibility

### Supported Architectures

- `linux/amd64`
- `linux/arm64`

### Supported Systems

- **Primary**: Arch Linux
- **Secondary**: Other Linux distributions (for clone-repo)

### Requirements

- Docker or Podman
- Visual Studio Code with Dev Containers extension
- Git (for cloning features)

## 🔄 CI/CD

### GitHub Actions

The project includes automated processes:

- **Testing**: Automated tests for all features
- **Publishing**: Publication to GitHub Container Registry
- **Versioning**: Semantic versioning
- **Documentation**: Automatic documentation updates

### Publication

Features are automatically published to:

- `ghcr.io/zyrakq/arch-devcontainer-features/yay`
- `ghcr.io/zyrakq/arch-devcontainer-features/chaotic-aur`
- `ghcr.io/zyrakq/arch-devcontainer-features/clone-repo`
- `ghcr.io/zyrakq/arch-devcontainer-features/node`
- `ghcr.io/zyrakq/arch-devcontainer-features/bun`
- `ghcr.io/zyrakq/arch-devcontainer-features/rust`
- `ghcr.io/zyrakq/arch-devcontainer-features/rust-bin`
- `ghcr.io/zyrakq/arch-devcontainer-features/dotnet`
- `ghcr.io/zyrakq/arch-devcontainer-features/dotnet-bin`

## 📖 Documentation

- [Yay AUR Helper](src/yay/README.md) - Detailed yay feature documentation
- [Chaotic-AUR Repository](src/chaotic-aur/README.md) - Chaotic-AUR feature documentation
- [Clone Repository](src/clone-repo/README.md) - Clone-repo feature documentation
- [Node.js and npm](src/node/README.md) - Node.js feature documentation
- [Bun Runtime](src/bun/README.md) - Bun runtime feature documentation
- [Rust and Cargo (pre-compiled)](src/rust/README.md) - Rust feature documentation (pre-compiled packages)
- [Rust and Cargo (rustup)](src/rust-bin/README.md) - Rust feature documentation (rustup)
- [.NET SDK and Runtime](src/dotnet/README.md) - .NET feature documentation (official packages)
- [.NET SDK and Runtime (AUR)](src/dotnet-bin/README.md) - .NET feature documentation (AUR packages)
- [DevContainers Specification](https://containers.dev/implementors/features/) - Official specification

## 🤝 Contributing

1. **Fork** the repository
2. Create a **feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. Open a **Pull Request**

### Development Guidelines

- All features should work on Arch Linux
- Add tests for new features
- Update documentation
- Follow existing code style
- Use semantic versioning

## 📄 License

This project is dual-licensed under:

- [Apache License 2.0](LICENSE-APACHE)
- [MIT License](LICENSE-MIT)

## 🙏 Acknowledgments

This project uses code from:

- [bartventer/arch-devcontainer-features](https://github.com/bartventer/arch-devcontainer-features) - Arch Linux utilities
- [devcontainers/features](https://github.com/devcontainers/features) - Templates and examples

Thanks to the authors for their contributions to the DevContainers ecosystem!

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/zyrakq/arch-devcontainer-features/issues)
- **Discussions**: [GitHub Discussions](https://github.com/zyrakq/arch-devcontainer-features/discussions)
- **Documentation**: [DevContainers.dev](https://containers.dev/)

---

⭐ If this project was helpful, please give it a star!
