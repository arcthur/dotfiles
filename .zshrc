[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Fig pre block. Keep at the top of this file.

# Path
# ---------------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_DIR="/etc/xdg"
export XDG_DATA_DIR="/usr/local/share/:/usr/share/"

export ZSNAP_HOME="$HOME/.znap"

# Zsh-Snap
# ---------------
[[ -f $ZSNAP_HOME/zsh-snap/znap.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git $ZSNAP_HOME/zsh-snap

source $ZSNAP_HOME/zsh-snap/znap.zsh

# Prompt
znap eval starship 'starship init zsh --print-full-init'
znap prompt

# Load plugins
znap source marlonrichert/zsh-edit

znap source arcthur/zsh-fzf

ZSH_AUTOSUGGEST_STRATEGY=( history completion )
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
znap source zsh-users/zsh-autosuggestions

znap source sorin-ionescu/prezto modules/{environment,history,completion,directory}
zstyle ':prezto:module:history' histfile "${ZDOTDIR:-$HOME}/.zsh_history"
zstyle ':prezto:module:history' histsize 10000
zstyle ':prezto:module:history' savehist 10000

znap source zdharma-continuum/fast-syntax-highlighting
znap source zdharma-continuum/history-search-multi-word
znap source zsh-users/zsh-history-substring-search

# Lazy Load
znap function _pyenv pyenv 'eval "$(pyenv init - --no-rehash)"'
compctl -K _pyenv pyenv

znap function _python_argcomplete pipx 'eval "$(register-python-argcomplete pipx)"'
complete -o nospace -o default -o bashdefault -F _python_argcomplete pipx

znap function _fnm fnm 'eval "$(fnm env --use-on-cd)"'
compctl -K _fnm fnm
# }

# Editor
# ---------------
# Make VI mode as default for zsh
bindkey -v

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
    zle reset-prompt
}

# Register the widget to zle
zle -N zle-line-init
zle -N zle-keymap-select

# Persist normal non-vi behaviour
# Reference to key & values:
bindkey "^p" up-history
bindkey '^n' down-history
bindkey '^w' backward-kill-word
bindkey '^e' end-of-line
bindkey '^a' beginning-of-line
bindkey "^y" yank

# Make mode change lag go away
export KEYTIMEOUT=1

# Use Neovim as "preferred editor"
export VISUAL=nvim
export EDITOR="$VISUAL"

# Chrome
# ---------------
alias chromews='sudo open -a Google\ Chrome --args --disable-web-security'

# Better Version Tools
# ---------------
# fd
if [ "$(command -v fd)" ]; then
    unalias -m 'find'
    alias find='fd'
fi

# ripgrep
if [ "$(command -v rg)" ]; then
    unalias -m 'grep'
    alias grep='rg -S'
    alias rg='rg -S'
fi

# exa
if [ "$(command -v exa)" ]; then
    unalias -m 'ls'
    alias ls='exa -l -s type'
    alias ll='exa -l -a -s type --group-directories-first --git'
    alias lt='exa -T -s type --git-ignore --level=2 --group-directories-first'
    alias llt='exa -lT -s type --git-ignore --level=2 --group-directories-first'
    alias lT='exa -T -s type --git-ignore --level=4 --group-directories-first'
fi

# bat
if [ "$(command -v bat)" ]; then
    unalias -m 'cat'
    alias cat='bat --theme="Nord"'
    alias bat='bat --theme="Nord"'
fi

# htop
if [ "$(command -v htop)" ]; then
    unalias -m 'top'
    alias top='htop'
fi

# procs
if [ "$(command -v procs)" ]; then
    unalias -m 'ps'
    alias ps='procs'
fi

# duf
if [ "$(command -v duf)" ]; then
    unalias -m 'df'
    alias df='duf'
fi

# dust
if [ "$(command -v dust)" ]; then
    unalias -m 'du'
    alias du='dust'
fi

# gping
if [ "$(command -v gping)" ]; then
    unalias -m 'ping'
    alias ping='gping'
fi

# tldr
if [ "$(command -v tldr)" ]; then
    unalias -m 'man'
    alias man='tldr'
fi

# zoxide
if [ "$(command -v zoxide)" ]; then
    eval "$(zoxide init zsh)"
    export _ZO_FZF_OPTS="--prompt 'dir >' \
        --ansi \
        --info=inline \
        --layout=reverse \
        --height=80% \
        --preview='exa -l -s type' \
        --color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'"
    alias cd='z'
    alias fzf-dir='zi'
fi

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
