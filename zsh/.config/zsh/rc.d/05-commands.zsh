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
    export BAT_THEME='OneHalfDark'
    alias cat='bat'
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

# mcfly
if [ "$(command -v mcfly)" ]; then
    export MCFLY_KEY_SCHEME=vim
    export MCFLY_FUZZY=3
    export MCFLY_RESULTS=100
fi

# starship
if [ "$(command -v starship)" ]; then
    eval "$(starship init zsh)"
fi

# fnm
if [ "$(command -v fnm)" ]; then
    eval "$(fnm env --use-on-cd)"
fi

# pyenv
if [ "$(command -v pyenv)" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# goenv
if [ "$(command -v goenv)" ]; then
    export GOENV_ROOT="$HOME/.goenv"
    command -v pyenv >/dev/null || export PATH="$GOENV_ROOT/bin:$PATH"
    eval "$(goenv init -)"
fi

# orbstack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
