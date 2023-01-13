#!/usr/bin/env bash

# fzf config file
# include some custom command about fzf

RED="$(tput setaf 1 2>/dev/null || printf '')"
GREEN="$(tput setaf 2 2>/dev/null || printf '')"

FD_EXCLUDE="{.git,.idea,.nvm,.vscode,.vscode-server,.cache,.sass-cache,node_modules,build}"

export FZF_DEFAULT_COMMAND="fd -H --exclude=${FD_EXCLUDE}"
export FZF_DEFAULT_OPTS=" \
    --height 80% \
    --layout=reverse \
    --border \
    --preview \
        'ls -l {}' \
    --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
    --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
    --color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 \
    --color=gutter:#303446"

error() {
    printf '%s\n' "${RED}x $*${NO_COLOR}" >&2
}

usage() {
    printf '%s\n' "${GREEN}$*${NO_COLOR}"
}

example() {
    printf '%s\n' "${GREEN}$*${NO_COLOR}"
}

has() {
    command -v "$1" 1>/dev/null 2>&1
}

# rg and fzf
fzf_rg() {
    #RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"
    RG_BIN="rg"
    RG_PATH="${*:-}"
    RG_OPTION="--column --line-number --no-heading --color=always --smart-case"
    INITIAL_QUERY=""

    FZF_DEFAULT_COMMAND="$RG_BIN $(printf %q "$INITIAL_QUERY") ${RG_PATH} ${RG_OPTION}" \
    fzf --ansi \
        --disabled \
        --bind "change:reload:$RG_BIN {q} ${RG_PATH} ${RG_OPTION} || true" \
        --prompt 'rg > ' \
        --delimiter : \
        --preview "bat --style=numbers --color=always -r {2}: --theme=Nord {1} \
            --highlight-line {2}"
}

# fd and fzf
fzf_fd() {
    if [ $# -gt 0 ]; then
        error "param format error. no need param."
        usage "usage: fzf.d"
        return 1
    fi

    FD_PREFIX="fd ${*:-} -H --exclude=${FD_EXCLUDE}"
    INITIAL_QUERY=""

    FZF_DEFAULT_COMMAND="${FD_PREFIX} $(printf %q "${INITIAL_QUERY}")" \
    fzf --prompt 'fd > ' \
        --ansi \
        --query "${INITIAL_QUERY}" \
        --preview "bat --style=numbers --color=always --theme=Nord {}" \
    || return 0
}

# cd the selected directory
fzf_dir() {
    if [ $# -gt 0 ]; then
        error "param format error. no need param."
        usage "usage: fzf.d"
        return 1
    fi

    FD_PREFIX="fd . ${HOME} -H --type d --exclude=${FD_EXCLUDE}"
    INITIAL_QUERY=""

    FZF_DEFAULT_COMMAND="${FD_PREFIX} $(printf %q "${INITIAL_QUERY}")" \
    dir=$(fzf --prompt 'dir > ' \
        --ansi \
        --query "${INITIAL_QUERY}" \
        --header 'Press Enter To Switch This Directory' \
        --preview "exa -G --color always --icons -a -s type {}") \
    && cd ${dir} \
    || return 0
}

# edit the selected file
fzf_file() {
    if [ $# -gt 0 ]; then
        error "param format error. no need param."
        usage "usage: fzf.f"
        return 1
    fi

    FD_PREFIX="fd ${*:-} -H --type f --exclude=${FD_EXCLUDE}"
    INITIAL_QUERY=""
    EDIT="cat"
    if has nvim; then
        EDIT="nvim"
    elif has vim; then
        EDIT="vim"
    elif has vi; then
        EDIT="vi"
    fi

    file=$(FZF_DEFAULT_COMMAND="${FD_PREFIX} $(printf %q "${INITIAL_QUERY}")" \
    fzf --prompt 'file > ' \
        --ansi \
        --query "${INITIAL_QUERY}" \
        --header 'Press Enter To Edit This File' \
        --preview "bat --style=numbers --color=always --theme=Nord {}") \
    && $EDIT $file \
    || return 0
}

alias fzf.rg="fzf_rg ${*:-}"
alias fzf.fd="fzf_fd ${*:-}"
alias fzf.d="fzf_dir ${*:-}"
alias fzf.f="fzf_file ${*:-}"
