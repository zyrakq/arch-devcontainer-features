# 📦 Pacman Mirror Configuration

## 📝 Description

This feature configures the pacman mirrorlist for faster package downloads on Arch Linux and Arch Linux ARM systems. It provides multiple modes for obtaining mirror lists and automatically detects the system architecture to use appropriate mirrors.

## 🎯 Key Features

- ✅ Automatic architecture detection (x86_64 vs ARM)
- 🔄 Multiple mirrorlist sources (builtin, URL, reflector, official)
- 🌍 Country and protocol filtering support
- 💾 Creates backup of existing mirrorlist
- ⚡ Optimized for devcontainer first-run scenarios

## 🚀 Quick Start with Templates

Instead of configuring from scratch, you can use ready-to-use solutions:

- **🐳 Ready Images**: [bartventer/devcontainer-images](https://github.com/bartventer/devcontainer-images) - pre-built DevContainer images for Arch Linux that include this feature
- **📋 Templates**: [zyrakq/arch-devcontainer-templates](https://github.com/zyrakq/arch-devcontainer-templates) - DevContainer templates for Arch Linux with this feature pre-configured

## 💻 Example Configurations

### Builtin Mode (Default)

Uses embedded mirrorlist with pre-selected high-performance mirrors:

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/pacman-mirror:1": {}
    }
}
```

### URL Mode

Download mirrorlist from a custom URL:

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/pacman-mirror:1": {
            "mode": "url",
            "mirrorlistUrl": "https://example.com/mirrorlist"
        }
    }
}
```

### Reflector Mode

Automatically select the best mirrors using reflector:

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/pacman-mirror:1": {
            "mode": "reflector",
            "country": "DE,FR,US",
            "protocol": "https",
            "mirrorCount": "10"
        }
    }
}
```

### Official Mode

Use official Arch Linux mirrorlist generator:

```json
{
    "features": {
        "ghcr.io/zyrakq/arch-devcontainer-features/pacman-mirror:1": {
            "mode": "official",
            "country": "DE,AT",
            "protocol": "https"
        }
    }
}
```

## ⚙️ Options

| Option | Type | Default | Description |
| -------- | ------ | --------- | ------------- |
| `mode` | string | `builtin` | Mirrorlist source mode: `builtin`, `url`, `reflector`, `official` |
| `mirrorlistUrl` | string | `` | Custom URL to download mirrorlist from (used when mode=url or as fallback for mode=reflector) |
| `country` | string | `` | Comma-separated country codes for mirror filtering (e.g., `DE,FR,US`) - for reflector/official modes |
| `protocol` | string | `https` | Protocol filter: empty, `http`, or `https` - for reflector/official modes |
| `mirrorCount` | string | `10` | Number of fastest mirrors to include - for reflector mode |
| `uncommentServers` | boolean | `true` | Uncomment `#Server` lines after downloading mirrorlist - for url and official modes |

## 🏗️ Architecture Support

### x86_64 (Arch Linux)

Default builtin mirrors are optimized for speed with the following format:

```text
Server = https://mirror.example.com/$repo/os/$arch
```

### aarch64/armv7l (Arch Linux ARM)

Uses Arch Linux ARM mirrors with a different URL structure:

```text
Server = http://mirror.archlinuxarm.org/$arch/$repo
```

**Note**: Reflector and official modes are only available for x86_64 Arch Linux. ARM systems fall back to builtin mode.

## 📦 Installation Order

This feature is designed to run early in the devcontainer lifecycle:

- No `installsAfter` dependencies - runs first
- Requires network access to download mirrors
- Creates backup at `/etc/pacman.d/mirrorlist.backup`

## 🔄 Mirror Selection Modes

### Builtin

Uses pre-configured lists of high-performance mirrors:

- 11 mirrors for x86_64 (all HTTPS)
- 12 mirrors for ARM (HTTP, as HTTPS not widely available)

### URL

Downloads a complete mirrorlist from a custom URL. Useful for:

- Corporate environments with internal mirrors
- Mirroring services you control
- Specific regional mirror configurations

### Reflector

Uses the `reflector` package to:

1. First installs a base mirrorlist (builtin or from URL)
2. Installs reflector package
3. Runs reflector with configured filters
4. Generates an optimized mirrorlist sorted by speed

### Official

Queries the archlinux.org mirrorlist API:

- Filters by country and protocol
- Downloads and uncomments the best mirrors
- Only available for x86_64

## 📝 Notes

- Feature requires root privileges to modify `/etc/pacman.d/mirrorlist`
- Original mirrorlist is backed up to `.backup` before modification
- Works on both x86_64 and ARM architectures
- Minimum dependencies: only requires curl or wget
- Reflector mode will fail if pacman cannot be updated (no network)

## 🔧 Troubleshooting

### Mirror Connection Errors

1. Verify network connectivity
2. Try a different mode (e.g., builtin instead of reflector)
3. Check if mirrors are accessible: `curl -I <mirror-url>`

### Reflector Installation Fails

Reflector requires a working mirrorlist to install. If reflector mode fails:

- Ensure `mirrorlistUrl` is provided as fallback
- Or use builtin mode first, then manually install reflector

### ARM System Issues

- Arch Linux ARM uses different mirror format (`$arch/$repo` vs `$repo/os/$arch`)
- Official and reflector modes are not supported on ARM
- Builtin mode automatically selects ARM mirrors

### Slow Package Downloads

1. Try reflector mode with country filter for your region
2. Use protocol filter to prefer HTTPS mirrors
3. Increase mirrorCount for more failover options

## 📋 Requirements

- Container must be running Arch Linux or Arch Linux ARM
- Root user access required
- Network connectivity for downloading mirrors
- curl or wget for URL-based modes
- pacman for reflector mode installation
