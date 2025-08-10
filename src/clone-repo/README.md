
# Clone Repository with SSH Support (clone-repo)

Clones Git repositories with SSH and HTTPS support via postCreateCommand. Supports private repositories with SSH keys.

## Example Usage

```json
"features": {
    "ghcr.io/zyrakq/arch-devcontainer-features/clone-repo:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| repoUrl | Git repository URL to clone (SSH or HTTPS, required) | string | - |
| targetDir | Target directory for cloning (default: /workspace) | string | /workspace |
| branch | Specific branch to clone (optional) | string | - |

# 📁 Clone Repository

## 📝 Description

This feature allows you to automatically clone a Git repository into a specified directory during devcontainer creation. Supports both HTTPS and SSH URLs with proper SSH key handling. Useful for:

- 📥 Automatically getting project source code with SSH authentication
- 🏢 Setting up workspace with private repositories
- 🌿 Cloning specific branches for development
- 🔑 Handling SSH keys and agent configuration

## ❗ Important: SSH Support

This feature automatically handles SSH cloning using the built-in `postCreateCommand` lifecycle hook. No additional configuration needed in your `devcontainer.json` - the SSH-compatible cloning script is executed automatically after container creation when SSH keys and agent are available.

## 🚀 Quick Start with Templates

Instead of configuring from scratch, you can use ready-to-use solutions:

- **🐳 Ready Images**: [bartventer/devcontainer-images](https://github.com/bartventer/devcontainer-images) - pre-built DevContainer images for Arch Linux that include this feature
- **📋 Templates**: [zyrakq/arch-devcontainer-templates](https://github.com/zyrakq/arch-devcontainer-templates) - DevContainer templates for Arch Linux with this feature pre-configured

These solutions provide a faster way to get started with Arch Linux DevContainers that already include the repository cloning feature.

## � Example Configurations

### SSH Repository (Recommended for private repos)

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "git@github.com:user/private-repo.git",
            "targetDir": "/workspace/my-project",
            "branch": "main"
        }
    }
}
```

### HTTPS Repository

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "https://github.com/user/repo.git",
            "targetDir": "/workspace/my-project",
            "branch": "main"
        }
    }
}
```

### SSH with Custom Target Directory

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "git@github.com:microsoft/vscode.git",
            "targetDir": "/workspace/vscode-source"
        }
    }
}
```

### SSH with Specific Branch

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/clone-repo:1": {
            "repoUrl": "git@github.com:company/private-repo.git",
            "targetDir": "/workspace/vscode-dev",
            "branch": "development"
        }
    }
}
```

**📝 Note**: Currently only single repository per feature instance is supported. For multiple repositories, you would need to use separate feature instances with different target directories.

## ✅ Compatibility

- **Architecture**: `linux/amd64`, `linux/arm64`
- **Operating System**: Arch Linux (and other Linux distributions)
- **Requirements**: Git (installed automatically if needed)

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

## SSH Configuration

### 🛠️ How SSH Support Works

1. **During container build**: Feature installs git and creates the clone script
2. **During container startup**: `postCreateCommand` executes the clone script as the user
3. **SSH key access**: Script can access user's SSH keys mounted into the container
4. **Automatic SSH config**: Creates SSH configuration for common Git providers

### 🔑 SSH Key Requirements

For SSH cloning to work, ensure your SSH keys are available in the container:

**For VS Code Dev Containers:**

- SSH keys are automatically forwarded if SSH agent is running
- Or manually mount your SSH directory:

    ```json
    {
      "mounts": [
        "source=${localEnv:HOME}/.ssh,target=/home/vscode/.ssh,type=bind,consistency=cached"
      ]
    }
    ```

**For GitHub Codespaces:**

- SSH keys are automatically available through Codespaces SSH integration
- No additional configuration needed

**For other environments:**

- Mount your SSH keys directory into the container
- Ensure SSH agent is running and accessible

### 🆘 SSH Troubleshooting

Common SSH issues and solutions:

1. **"Permission denied (publickey)"**
    - Verify SSH keys are mounted correctly
    - Check SSH agent is running: `ssh-add -l`
    - Test SSH connection: `ssh -T git@github.com`

2. **"Host key verification failed"**
    - Feature automatically sets `StrictHostKeyChecking no` for common providers
    - For custom Git servers, add to your SSH config

3. **SSH agent not available**
    - Ensure SSH agent forwarding is enabled
    - Or start SSH agent in container: `eval "$(ssh-agent -s)"`

## 📝 Notes

- If target directory already exists and contains files, a timestamped backup is created
- Feature ensures proper file ownership for cloned files
- Git must be available in the container (usually installed in base image)
- If no repository URL is provided, feature skips cloning without errors
- Correctly handles permissions for both root and non-root users
- **SSH URLs are detected automatically** - no special configuration needed
- **HTTPS fallback suggestions** provided if SSH clone fails

## 🔧 Troubleshooting

If you encounter cloning issues:

1. **Verify Git installation**: Git should be available in the container (automatically handled)
2. **Check repository URL**: Verify URL format and accessibility
3. **SSH-specific issues**: See SSH Troubleshooting section above
4. **Permissions**: Check user has write permissions to target directory
5. **Branch existence**: Ensure specified branch exists in the repository
6. **Feature execution**: Check container logs for clone script execution during postCreateCommand

## 📋 Requirements

- Git must be installed in the container (automatically handled by feature)
- Container user must have write permissions to the target directory
- **For SSH repositories**: SSH keys must be available in the container
- **No manual postCreateCommand needed**: Feature automatically handles execution via built-in lifecycle hook

---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/zyrakq/arch-devcontainer-features/blob/main/src/clone-repo/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
