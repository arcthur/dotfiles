#!/usr/bin/env bash

set -euo pipefail

# Fail with context on error (use printf directly, err() not yet defined)
trap 'printf "[✗] Failed at line %d: %s\n" "$LINENO" "$BASH_COMMAND" >&2; exit 1' ERR

# macOS only
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "[✗] This script supports macOS only." >&2
    exit 1
fi

# ==============================================================================
# Configuration
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/.backup/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false
FORCE=false
NEEDS_SHELL_RESTART=false

STOW_PACKAGES=(
    bat
    git
    nvim
    homebrew
    topgrade
    tmux
    zsh
    fast-theme
    ghostty
    codex
    claude
    sketchybar
    aerospace
)

# ==============================================================================
# Output Functions
# ==============================================================================

# Only use colors if stdout is a TTY
if [[ -t 1 ]]; then
    COLOR_RESET=$(tput sgr0 2>/dev/null || echo '')
    COLOR_BLUE=$(tput setaf 4 2>/dev/null || echo '')
    COLOR_GREEN=$(tput setaf 2 2>/dev/null || echo '')
    COLOR_YELLOW=$(tput setaf 3 2>/dev/null || echo '')
    COLOR_RED=$(tput setaf 1 2>/dev/null || echo '')
else
    COLOR_RESET='' COLOR_BLUE='' COLOR_GREEN='' COLOR_YELLOW='' COLOR_RED=''
fi

info()    { printf "%s[*]%s %s\n" "$COLOR_BLUE" "$COLOR_RESET" "$1"; }
success() { printf "%s[✓]%s %s\n" "$COLOR_GREEN" "$COLOR_RESET" "$1"; }
warn()    { printf "%s[!]%s %s\n" "$COLOR_YELLOW" "$COLOR_RESET" "$1"; }
err()     { printf "%s[✗]%s %s\n" "$COLOR_RED" "$COLOR_RESET" "$1" >&2; }

# ==============================================================================
# Utilities
# ==============================================================================

backup_or_remove() {
    local src="$1"

    # Only backup files under $HOME
    if [[ "$src" != "$HOME/"* ]]; then
        warn "Skip backup (not under HOME): $src"
        return 0
    fi

    local relative="${src#$HOME/}"
    local dest="$BACKUP_DIR/$relative"

    if [[ "$DRY_RUN" == true ]]; then
        if [[ -L "$src" ]]; then
            info "[dry-run] Would remove symlink: $src"
        elif [[ -e "$src" ]]; then
            info "[dry-run] Would backup: $src -> $dest"
        fi
        return 0
    fi

    if [[ -L "$src" ]]; then
        rm -f "$src"
    elif [[ -e "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        # Remove existing dest if it's a non-empty directory (mv can't overwrite)
        if [[ -d "$dest" ]]; then
            rm -rf "$dest"
        fi
        mv -f "$src" "$dest"
        info "Backed up: $src"
    fi
}

resolve_path() {
    local target="$1"
    local resolved=""

    if command -v realpath &>/dev/null; then
        resolved=$(realpath "$target" 2>/dev/null || true)
    elif command -v perl &>/dev/null; then
        resolved=$(perl -MCwd=realpath -e 'print realpath($ARGV[0])' "$target" 2>/dev/null || true)
    elif command -v python3 &>/dev/null; then
        resolved=$(python3 - <<'PY' "$target" 2>/dev/null || true
import os, sys
print(os.path.realpath(sys.argv[1]))
PY
)
    fi

    if [[ -z "$resolved" ]]; then
        printf '%s\n' "$target"
    else
        printf '%s\n' "$resolved"
    fi
}

preprocess_conflicts() {
    local pkg="$1"
    local pkg_dir="$SCRIPT_DIR/$pkg"

    # Scan files and symlinks, exclude junk
    while IFS= read -r -d '' file; do
        local relative="${file#$pkg_dir/}"
        # Handle stow --dotfiles: dot- prefix maps to .
        relative="${relative//dot-/.}"
        local target="$HOME/$relative"

        if [[ "$target" != "$HOME/"* ]]; then
            err "Unsafe target outside HOME detected: $target"
            exit 1
        fi

        if [[ -e "$target" || -L "$target" ]]; then
            # Skip if target resolves to our dotfiles repo (already stowed correctly)
            local real_path
            real_path=$(resolve_path "$target")
            if [[ "$real_path" == "$SCRIPT_DIR"/* ]]; then
                continue
            fi
            backup_or_remove "$target"
        fi
    done < <(find "$pkg_dir" \( -type f -o -type l -o -type d \) \
        ! -name '.DS_Store' ! -name '*.swp' ! -name '*~' -print0)
}

# Returns valid packages via stdout, one per line
get_valid_packages() {
    for pkg in "${STOW_PACKAGES[@]}"; do
        if [[ -d "$SCRIPT_DIR/$pkg" ]]; then
            printf '%s\n' "$pkg"
        else
            warn "Package directory not found: $pkg"
        fi
    done
}

# ==============================================================================
# Install Functions
# ==============================================================================

install_xcode_cli() {
    if xcode-select -p &>/dev/null; then
        success "Xcode CLI tools already installed"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would install Xcode CLI tools"
        return 0
    fi

    info "Installing Xcode CLI tools..."
    xcode-select --install

    # Wait for installation with timeout (10 min max)
    local timeout=600
    local elapsed=0
    while ! xcode-select -p &>/dev/null; do
        if [[ $elapsed -ge $timeout ]]; then
            err "Xcode CLI tools installation timed out. Please install manually and re-run."
            exit 1
        fi
        sleep 5
        elapsed=$((elapsed + 5))
    done
    success "Xcode CLI tools installed"
}

install_homebrew() {
    if command -v brew &>/dev/null; then
        success "Homebrew already installed"
        if [[ "$DRY_RUN" == false ]]; then
            # Ensure analytics is off
            brew analytics off &>/dev/null || true
        fi
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would install Homebrew"
        return 0
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    brew analytics off
    success "Homebrew installed (analytics disabled)"
}

install_brew_packages() {
    # Ensure stow is installed (required for dotfiles)
    if ! command -v stow &>/dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            info "[dry-run] Would install stow"
        else
            info "Installing stow..."
            brew install stow
        fi
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would run brew bundle"
        return 0
    fi

    local brewfile="$SCRIPT_DIR/homebrew/.config/homebrew/Brewfile"
    if [[ ! -f "$brewfile" ]]; then
        warn "Brewfile not found: $brewfile"
        return 0
    fi

    info "Installing Brewfile packages..."
    if brew bundle --file="$brewfile"; then
        success "Brew packages installed"
    else
        warn "Some brew packages failed to install"
    fi
}

install_nix() {
    if [[ -d "/nix/store" ]]; then
        success "Nix already installed"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would install Nix"
        return 0
    fi

    info "Installing Nix..."
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)

    # Try to source nix for this session
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        # shellcheck source=/dev/null
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        success "Nix installed and sourced"
    else
        NEEDS_SHELL_RESTART=true
        warn "Nix installed (shell restart required for full functionality)"
    fi
}

install_devbox() {
    # Source nix if not in PATH
    if ! command -v nix &>/dev/null; then
        if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
            # shellcheck source=/dev/null
            source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
    fi

    if command -v devbox &>/dev/null; then
        success "Devbox already installed"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would install Devbox"
        return 0
    fi

    info "Installing Devbox..."
    curl -fsSL https://get.jetify.com/devbox | bash
    success "Devbox installed"
}

install_zsh4monkey() {
    local z4m_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh4monkey"

    if [[ -f "$z4m_cache/z4m.zsh" ]]; then
        success "zsh4monkey already installed"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would install zsh4monkey"
        return 0
    fi

    info "Installing zsh4monkey..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/arcthur/zsh4monkey/main/install)"
    success "zsh4monkey installed"
}

install_tpm() {
    local tpm_path="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm"

    if [[ -d "$tpm_path" ]]; then
        success "TPM (Tmux Plugin Manager) already installed"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would install TPM"
        return 0
    fi

    info "Installing TPM (Tmux Plugin Manager)..."
    mkdir -p "$(dirname "$tpm_path")"
    git clone https://github.com/tmux-plugins/tpm "$tpm_path"
    success "TPM installed (run prefix+I in tmux to install plugins)"
}

install_claude_code() {
    if command -v claude &>/dev/null; then
        success "Claude Code already installed"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would install Claude Code"
        return 0
    fi

    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    success "Claude Code installed"
}

install_sketchybar_deps() {
    local sbarlua_path="$HOME/.local/share/sketchybar_lua"
    local providers_path="$HOME/.config/sketchybar/helpers/event_providers"

    # Install SbarLua (Lua API for SketchyBar)
    if [[ -f "$sbarlua_path/sketchybar.so" ]]; then
        success "SbarLua already installed"
    elif [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would install SbarLua"
    else
        info "Installing SbarLua..."
        rm -rf /tmp/SbarLua
        if git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && \
           (cd /tmp/SbarLua && make install) && rm -rf /tmp/SbarLua; then
            success "SbarLua installed"
        else
            warn "SbarLua installation failed"
            rm -rf /tmp/SbarLua
        fi
    fi

    # Compile C event providers (cpu/memory/network/battery)
    if [[ -d "$providers_path" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            info "[dry-run] Would compile sketchybar event providers"
        else
            info "Compiling sketchybar event providers..."
            if (cd "$providers_path" && make all 2>/dev/null); then
                success "Sketchybar event providers compiled"
            else
                warn "Sketchybar event providers compilation failed"
            fi
        fi
    fi
}

setup_sleepwatcher_hooks() {
    # sleepwatcher triggers scripts on sleep/wake events
    # Used to refresh sketchybar weather after wake (network needs time to recover)
    local wakeup_script="$HOME/.wakeup"
    local sleep_script="$HOME/.sleep"

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would create sleepwatcher hooks (~/.wakeup, ~/.sleep)"
        return 0
    fi

    # Create .wakeup script - triggers sketchybar refresh after wake
    cat > "$wakeup_script" << 'EOF'
#!/bin/bash
# Wait for network to recover after wake
sleep 3
/opt/homebrew/bin/sketchybar --trigger system_woke
EOF
    chmod +x "$wakeup_script"

    # Create .sleep script - placeholder for future use
    cat > "$sleep_script" << 'EOF'
#!/bin/bash
EOF
    chmod +x "$sleep_script"

    success "Sleepwatcher hooks created"
}

start_services() {
    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would start sketchybar, sleepwatcher, aerospace"
        return 0
    fi

    # Start sketchybar as brew service
    if command -v sketchybar &>/dev/null; then
        info "Starting sketchybar..."
        brew services start sketchybar 2>/dev/null || brew services restart sketchybar
        success "sketchybar started"
    fi

    # Start sleepwatcher as brew service
    if command -v sleepwatcher &>/dev/null; then
        info "Starting sleepwatcher..."
        brew services start sleepwatcher 2>/dev/null || brew services restart sleepwatcher
        success "sleepwatcher started"
    fi

    # Start or reload aerospace
    if command -v aerospace &>/dev/null; then
        if pgrep -x AeroSpace &>/dev/null; then
            info "Reloading aerospace..."
            aerospace reload-config
            success "aerospace reloaded"
        else
            info "Starting aerospace..."
            open -a AeroSpace
            success "aerospace started"
        fi
    fi
}

# ==============================================================================
# Stow Functions
# ==============================================================================

stow_packages() {
    local packages=()
    while IFS= read -r pkg; do
        packages+=("$pkg")
    done < <(get_valid_packages)

    info "Stowing ${#packages[@]} packages..."

    for pkg in "${packages[@]}"; do
        preprocess_conflicts "$pkg"

        if [[ "$DRY_RUN" == true ]]; then
            info "[dry-run] Would stow: $pkg"
            continue
        fi

        local stow_err
        if stow_err=$(stow --dotfiles -t "$HOME" "$pkg" 2>&1); then
            success "$pkg"
        else
            if [[ "$FORCE" == true ]]; then
                stow --dotfiles -t "$HOME" --override='.*' "$pkg" && success "$pkg (forced)" || err "$pkg"
            else
                err "$pkg: $stow_err"
            fi
        fi
    done
}

# ==============================================================================
# Post-install Setup
# ==============================================================================

sync_nvim_plugins() {
    if ! command -v nvim &>/dev/null; then
        warn "Neovim not found, skipping plugin sync"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would sync Neovim plugins"
        return 0
    fi

    info "Syncing Neovim plugins..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null && success "Neovim plugins synced" || warn "Neovim plugin sync failed"
}

# ==============================================================================
# Special Symlinks
# ==============================================================================

# Links codex config to claude's CLAUDE.md - cross-directory mapping that stow cannot handle
# (stow maps codex/.codex/* -> ~/.codex/*, but we need ~/.codex/... -> ~/.claude/CLAUDE.md)
setup_claude_symlink() {
    local src="$SCRIPT_DIR/codex/.codex/AGENTS.override.md"
    local dest="$HOME/.claude/CLAUDE.md"

    if [[ ! -f "$src" ]]; then
        warn "Claude source file not found: $src"
        return 0
    fi

    if [[ -L "$dest" ]]; then
        local current_target
        current_target=$(readlink "$dest")
        if [[ "$(resolve_path "$current_target")" == "$(resolve_path "$src")" ]]; then
            success "Claude CLAUDE.md symlink (already correct)"
            return 0
        fi
        [[ "$DRY_RUN" != true ]] && rm -f "$dest"
    elif [[ -e "$dest" ]]; then
        backup_or_remove "$dest"
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[dry-run] Would create symlink: $dest -> $src"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    success "Claude CLAUDE.md symlink"
}

# ==============================================================================
# CLI Parsing
# ==============================================================================

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Initialize dotfiles: install Nix, Devbox, and stow configurations.

Options:
    -n, --dry-run    Show what would be done without making changes
    -f, --force      Force stow even if conflicts exist
    -h, --help       Show this help message

Packages managed:
    ${STOW_PACKAGES[*]}
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--dry-run)
                DRY_RUN=true
                ;;
            -f|--force)
                FORCE=true
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                err "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    parse_args "$@"

    cd "$SCRIPT_DIR"

    [[ "$DRY_RUN" == true ]] && info "=== Dry Run Mode ==="

    info "=== Dotfiles Init ==="

    # Phase 1: System prerequisites
    install_xcode_cli
    install_homebrew

    # Phase 2: Package managers & frameworks
    install_brew_packages
    install_nix
    install_devbox
    install_zsh4monkey
    install_tpm
    install_claude_code

    # Phase 3: Stow dotfiles
    stow_packages

    # Phase 4: Post-install setup
    sync_nvim_plugins
    install_sketchybar_deps
    setup_sleepwatcher_hooks

    # Phase 5: Special symlinks
    setup_claude_symlink

    # Phase 6: Start services
    start_services

    echo ""
    success "=== Done ==="

    if [[ "$DRY_RUN" == true ]]; then
        info "Re-run without --dry-run to apply changes"
    elif [[ "$NEEDS_SHELL_RESTART" == true ]]; then
        warn "Please restart your shell and re-run to complete setup"
    fi
}

main "$@"
