# dotfiles

Opinionated dotfiles for a macOS development workstation.

> **Note:** This script supports macOS only.

## Quick Start

```bash
# Preview what will be done
./init.sh --dry-run

# Run installation
./init.sh

# Force stow even if conflicts exist
./init.sh --force
```

## What init.sh Does

**Phase 1: System Prerequisites**
- Xcode CLI tools (with 10-min timeout)
- Homebrew (with analytics disabled)

**Phase 2: Package Managers & Frameworks**
- `brew bundle` (installs packages from the default Brewfile location)
- Devbox
- zsh4monkey (zsh framework)
- TPM (Tmux Plugin Manager)
- Claude Code (native installer)

**Phase 3: Stow Dotfiles**
- homebrew, bat, git, nvim, topgrade, tmux, zsh
- ghostty, codex, aerospace, paneru

**Phase 4: Post-install Setup**
- Neovim plugins (`Lazy sync`)
- Paneru service (AeroSpace is started manually)

**Phase 5: Special Symlinks**
- `~/.claude/CLAUDE.md` → codex config (cross-directory mapping)

## Packages

### Stow Packages

| Package | Description |
|---------|-------------|
| `bat` | Cat with syntax highlighting |
| `git` | Git config + delta + SSH signing |
| `nvim` | Neovim with lazy.nvim |
| `homebrew` | Brewfile config (bundle packages) |
| `topgrade` | System upgrade tool |
| `tmux` | Terminal multiplexer |
| `zsh` | Shell config with zsh4monkey |
| `ghostty` | Terminal emulator |
| `codex` | Shared engineering instructions (`AGENTS.md`, also linked as Claude `CLAUDE.md`) |
| `aerospace` | macOS tiling window manager |
| `paneru` | macOS scrolling tiling window manager (default) |

## Manual Setup

### RIME (Chinese Input)

```bash
# Install rime-ice
bash rime-install iDvel/rime-ice:others/recipes/full

# Add to default.custom.yaml:
# patch:
#   schema_list:
#     - schema: wubi_pinyin
```

### Git SSH Signing

```bash
# 1. Add SSH key to agent
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# 2. Grant gh CLI permissions
gh auth refresh -h github.com -s admin:public_key
gh auth refresh -h github.com -s admin:ssh_signing_key

# 3. Add SSH key to GitHub
gh ssh-key add ~/.ssh/id_ed25519.pub --title "MacBook" --type authentication
gh ssh-key add ~/.ssh/id_ed25519.pub --title "MacBook Signing" --type signing

# 4. Create allowed_signers file
mkdir -p ~/.config/git
echo "your@email.com $(cat ~/.ssh/id_ed25519.pub)" > ~/.config/git/allowed_signers

# 5. Test
ssh -T git@github.com
git log --show-signature -1
```

## XDG Base Directories

This setup follows XDG Base Directory specification:

```
XDG_CONFIG_HOME  ~/.config      # Configuration files
XDG_CACHE_HOME   ~/.cache       # Non-essential cached data
XDG_DATA_HOME    ~/.local/share # Application data (e.g., TPM plugins)
```

## Uninstall

### Nix

The bootstrap no longer installs Nix. For existing installations, follow the [official macOS uninstall instructions](https://nix.dev/manual/nix/stable/installation/uninstall#macos); `/nix/nix-installer uninstall` applies only to installations that provide that separate installer.

### Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```
