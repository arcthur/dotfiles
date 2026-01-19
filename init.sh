#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Install Nix (official installer)
if [ ! -d "/nix/store" ]; then
    echo "Installing Nix..."
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
    echo "Please restart your shell and run this script again."
    exit 0
fi

# Source nix if not in PATH
if ! command -v nix &> /dev/null; then
    [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]] && \
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Install Devbox
if ! command -v devbox &> /dev/null; then
    echo "Installing Devbox..."
    curl -fsSL https://get.jetify.com/devbox | bash
fi

echo -e "${GREEN}✓${NC} Nix and Devbox are installed."

# Stow dotfiles
stow_package() {
    local pkg=$1
    if stow --dotfiles "$pkg" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $pkg"
    else
        echo -e "${RED}✗${NC} $pkg (failed)"
        return 1
    fi
}

echo ""
echo "Stowing dotfiles..."
stow_package bat
stow_package git
stow_package nvim
stow_package topgrade
stow_package tmux
stow_package zsh
stow_package fast-theme
stow_package workmux
stow_package ghostty
stow_package codex
stow_package claude

# Claude Code CLAUDE.md symlink (reuses codex config, not managed by stow)
if [ ! -e ~/.claude/CLAUDE.md ]; then
    mkdir -p ~/.claude
    ln -s ~/dotfiles/codex/.codex/AGENTS.override.md ~/.claude/CLAUDE.md
    echo -e "${GREEN}✓${NC} claude CLAUDE.md symlink"
fi

echo ""
echo -e "${GREEN}Done!${NC}"
