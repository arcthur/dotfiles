# =============================================================================
# 1. Z4M PRE-INIT CONFIGURATION
# =============================================================================

zstyle ':z4m:bindkey' keyboard  'mac'

# Don't start tmux automatically.
zstyle ':z4m:' start-tmux 'no'

# FZF
zstyle ':z4m:*' fzf-theme catppuccin-mocha
zstyle ':z4m:(fzf-complete|fzf-dir-history|fzf-history)'  fzf-flags     --no-exact
zstyle ':z4m:(fzf-complete|fzf-dir-history)'              fzf-bindings  'tab:repeat'
zstyle ':z4m:fzf-complete'                                find-flags    '(' -name '.git' -o -name node_modules ')' -prune -print -o -print

# Direnv
zstyle ':z4m:direnv' enable 'yes'

# SSH
zstyle ':z4m:ssh:*' enable 'no'
zstyle ':z4m:ssh:*' send-extra-files '~/.env.zsh'

# SSH/SCP completion
zstyle ':completion:*:ssh:argument-1:'       tag-order hosts users
zstyle ':completion:*:scp:argument-rest:'    tag-order hosts files users

# History search: use text before cursor as search pattern
HISTORY_SUBSTRING_SEARCH_CURSOR_AWARE=1

# Plugins
z4m install MichaelAquilina/zsh-auto-notify || return
z4m install MichaelAquilina/zsh-you-should-use || return

# CLI tools (eza, bat, zoxide auto-configured)
z4m install eza bat fd rg zoxide || return

z4m init || return

# Syntax highlighting theme (Catppuccin Mocha)
(( $+functions[fast-theme] )) && fast-theme -q ~/.config/fast-theme/catppuccin-mocha.ini

# =============================================================================
# 2. SHELL OPTIONS
# =============================================================================

# Completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

# Directory
setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent pushd_minus

# Globbing
setopt extended_glob

# History
setopt hist_verify hist_reduce_blanks hist_fcntl_lock

# macOS
setopt combining_chars

# I/O
setopt interactive_comments no_flow_control

# Completion behavior
setopt complete_in_word always_to_end

# Jobs
setopt no_hup long_list_jobs

# Word definition for navigation
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

autoload -Uz edit-command-line
zle -N edit-command-line

# =============================================================================
# 3. NIX
# =============================================================================

# Nix (must be before PATH setup)
[[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]] && \
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# =============================================================================
# 4. PATH
# =============================================================================

typeset -U path fpath
path=(
  # GNU utilities (override BSD versions)
  ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/coreutils/libexec/gnubin(N)
  ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/findutils/libexec/gnubin(N)
  ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/gnu-sed/libexec/gnubin(N)
  ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/gnu-tar/libexec/gnubin(N)
  ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/grep/libexec/gnubin(N)
  ${HOMEBREW_PREFIX:-/opt/homebrew}/opt/gawk/libexec/gnubin(N)
  # Homebrew
  ${HOMEBREW_PREFIX:-/opt/homebrew}/bin(N)
  ${HOMEBREW_PREFIX:-/opt/homebrew}/sbin(N)
  # User
  $HOME/bin(N)
  $HOME/.moon/bin(N)
  $path
)

# =============================================================================
# 5. ENVIRONMENT
# =============================================================================

export EDITOR=${EDITOR:-nvim}
export VISUAL=${VISUAL:-$EDITOR}

export FZF_DEFAULT_OPTS="--reverse --multi \
--bind=ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down"

# =============================================================================
# 6. FUNCTIONS
# =============================================================================

# Clear screen with prompt at bottom (no blank lines in scrollback)
clear-screen-bottom() {
  echoti clear .                # Clear viewport
  echoti cup $((LINES-1)) 0     # Move cursor to bottom row
  zle reset-prompt              # Redraw prompt
}
zle -N clear-screen-bottom

# Ctrl+Z: toggle foreground/background
my-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N my-ctrl-z

# Git worktree helpers (optional). Uncomment to enable:
ga() {
  [[ -z "$1" ]] && { echo "Usage: ga <branch>"; return 1; }
  local branch=$1 base=${PWD:t} path=../${base}-${branch}
  git worktree add -b "$branch" "$path" && cd "$path"
  (( $+commands[mise] )) && mise trust "$path"
}

gd() {
  read -q "?Remove worktree and branch? [y/N] " || { echo; return 0; }
  echo
  local wt=${PWD:t} root=${wt%-*} branch=${wt#*-}
  [[ $root == $wt ]] && { echo "Not in a worktree"; return 1; }
  cd ../$root && git worktree remove $wt --force && git branch -D $branch
}

# =============================================================================
# 7. KEY BINDINGS
# =============================================================================

# Word
z4m bindkey z4m-backward-kill-word  Alt+Backspace
z4m bindkey z4m-backward-kill-zword Ctrl+Alt+W
z4m bindkey z4m-kill-zword          Ctrl+Alt+D

# Line
z4m bindkey backward-kill-line      Ctrl+U
z4m bindkey kill-line               Alt+U
z4m bindkey kill-whole-line         Alt+I

# Navigation
z4m bindkey z4m-forward-zword       Ctrl+Alt+Right
z4m bindkey z4m-backward-zword      Ctrl+Alt+Left
z4m bindkey z4m-cd-back             Alt+H
z4m bindkey z4m-cd-forward          Alt+L
z4m bindkey z4m-cd-up               Alt+K
z4m bindkey z4m-fzf-dir-history     Alt+J

# Misc
z4m bindkey my-ctrl-z               Ctrl+Z
z4m bindkey edit-command-line       Alt+E
z4m bindkey z4m-exit                Ctrl+D
z4m bindkey undo                    Ctrl+/ Shift+Tab
z4m bindkey redo                    Alt+/
z4m bindkey run-help                Ctrl+Alt+H

bindkey '^[^L' clear-screen-bottom  # Ctrl+Alt+L

# =============================================================================
# 8. ALIASES
# =============================================================================

# Core (safe defaults)
alias mkdir='mkdir -p'
alias cp='cp -i'
alias mv='mv -i'
alias f='open -a Finder ./'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Directory stack
alias d='dirs -v'
for i in {1..9}; do alias "$i"="cd -$i"; done; unset i

# Modern CLI
(( $+commands[curlie] )) && alias curl='curlie'
(( $+commands[nvim] ))   && alias vim='nvim'
(( $+commands[btm] ))    && alias top='btm'
(( $+commands[procs] ))  && alias ps='procs'
(( $+commands[gping] ))  && alias ping='gping'
(( $+commands[tldr] ))   && alias tl='tldr'

# fd/rg flags
(( $+commands[fd] )) && alias fd='fd --one-file-system --hidden --follow'
(( $+commands[rg] )) && alias rg='rg --hidden --follow --smart-case'

# disk utils
(( $+commands[duf] ))  && alias df='duf'  || alias df='df -h'
(( $+commands[dust] )) && alias du='dust' || alias du='du -csh'

# AI agents
(( $+commands[claude] )) && alias cc='claude'
(( $+commands[claude] )) && alias ccd='claude --dangerously-skip-permissions'
(( $+commands[codex] )) && alias cx='codex'
(( $+commands[codex] )) && alias cxn='codex --sandbox workspace-write --ask-for-approval never'

# Suffix aliases
alias -s {md,markdown,rst,toml,json,yaml,yml}=code
alias -s {avi,mkv,mov,mp3,mp4,webm}=iina

# =============================================================================
# 9. TOOL INTEGRATIONS
# =============================================================================

_zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$_zsh_cache" ]] || mkdir -p "$_zsh_cache"

# Helper: cache eval output, regenerate if binary is newer
_cached_eval() {
  local cmd=$1 name=$2 init_cmd=$3
  local cache="$_zsh_cache/$name.zsh"
  local bin_path=${commands[$cmd]}
  [[ -z $bin_path ]] && return 1
  if [[ ! -f $cache || $bin_path -nt $cache ]]; then
    ${(z)init_cmd} >| $cache 2>/dev/null || return 1
  fi
  source $cache
}

# bat (theme configured in ~/.config/bat/config)
(( $+commands[bat] )) && export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# zoxide (z4m handles alias, add fzf opts)
if (( $+commands[zoxide] )); then
  export _ZO_FZF_OPTS="--prompt='dir > ' --ansi --info=inline --layout=reverse --height=80% \
    --preview='command -v eza >/dev/null && eza -l --icons {} || ls -l {}' \
    --color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'"
  alias cdi='zi'
fi

# atuin
if (( $+commands[atuin] )); then
  _cached_eval atuin atuin "atuin init zsh --disable-up-arrow"
  bindkey '^r' _atuin_search_widget
fi

# mise (replaces fnm/pyenv/goenv)
if (( $+commands[mise] )); then
  _cached_eval mise mise "mise activate zsh"
fi

unset _zsh_cache

# orbstack
[[ -f ~/.orbstack/shell/init.zsh ]] && source ~/.orbstack/shell/init.zsh

# =============================================================================
# 10. LOCAL CONFIG
# =============================================================================

z4m source ~/.env.zsh
