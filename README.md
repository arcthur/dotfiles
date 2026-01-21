# dotfiles

Configuration files for macOS development environment.

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

If Nix is newly installed, restart your shell and re-run `./init.sh` to complete setup.

## What init.sh Does

**Phase 1: System Prerequisites**
- Xcode CLI tools (with 10-min timeout)
- Homebrew (with analytics disabled)

**Phase 2: Package Managers & Frameworks**
- `brew bundle` (installs all packages from Brewfile)
- Nix (official installer)
- Devbox
- zsh4monkey (zsh framework)
- TPM (Tmux Plugin Manager)

**Phase 3: Stow Dotfiles**
- bat, git, nvim, topgrade, tmux, zsh
- fast-theme, workmux, ghostty
- codex, claude, sketchybar, aerospace

**Phase 4: Post-install Setup**
- Neovim plugins (`Lazy sync`)

**Phase 5: Special Symlinks**
- `~/.claude/CLAUDE.md` → codex config (cross-directory mapping)

## Packages

### Stow Packages

| Package | Description |
|---------|-------------|
| `bat` | Cat with syntax highlighting |
| `git` | Git config + delta + SSH signing |
| `nvim` | Neovim with lazy.nvim |
| `topgrade` | System upgrade tool |
| `tmux` | Terminal multiplexer |
| `zsh` | Shell config with zsh4monkey |
| `fast-theme` | Zsh theme |
| `workmux` | Tmux workspace tool |
| `ghostty` | Terminal emulator |
| `codex` | OpenAI Codex config |
| `claude` | Claude Code skills |
| `sketchybar` | macOS status bar |
| `aerospace` | macOS tiling window manager |

### Brewfile

```bash
# Install all packages
brew bundle

# Check what would be installed
brew bundle check
```

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

```bash
/nix/nix-installer uninstall
```

### Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```
