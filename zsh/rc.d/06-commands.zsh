# Commands
# ---------------
alias chromews='sudo open -a Google\ Chrome --args --disable-web-security'

# neovim
if [ "$(command -v nvim)" ]; then
    export VISUAL=nvim
    export EDITOR="$VISUAL"
    alias vim='nvim'
fi

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

