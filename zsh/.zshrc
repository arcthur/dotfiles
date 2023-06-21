# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'yes'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'mac'

# Don't start tmux.
zstyle ':z4h:' start-tmux       no

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' strategy 'atuin_top completion'
zstyle ':z4h:autosuggestions' forward-char 'accept'
zstyle ':z4h:autosuggestions' partial-accept 'forward-char forward-word end-of-line'

# Recursively traverse directories when TAB-completing files.
#zstyle ':z4h:fzf-complete' recurse-dirs 'no'
zstyle ':z4h:fzf-complete'                                  fzf-command            my-fzf
zstyle ':z4h:(fzf-complete|fzf-dir-history|fzf-history)'    fzf-flags              --no-exact --color=hl:14,hl+:14
zstyle ':z4h:(fzf-complete|fzf-dir-history)'                fzf-bindings           'tab:repeat'
zstyle ':z4h:fzf-complete'                                  find-flags             '(' -name '.git' -o -name node_modules ')' -prune -print -o -print

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

zstyle ':completion:*:ssh:argument-1:'       tag-order hosts users
zstyle ':completion:*:scp:argument-rest:'    tag-order hosts files users
zstyle ':completion:*:(ssh|scp|rdp):*:hosts' hosts

z4h install MichaelAquilina/zsh-auto-notify || return
z4h install MichaelAquilina/zsh-you-should-use || return
z4h install marlonrichert/zsh-edit || return

z4h init || return

# Case-insensitive (all), partial-word, and then substring completion.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY
export FZF_DEFAULT_OPTS="--reverse --multi"

# Source additional local files if they exist.
z4h source ~/.env.zsh

my-fzf () {
  emulate -L zsh -o extended_glob
  local MATCH MBEGIN MEND
  fzf "${@:/(#m)--query=?*/$MATCH }"
}

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

# Autoload functions.
autoload -Uz zmv edit-command-line
zle -N edit-command-line

z4h bindkey z4h-backward-kill-word  Ctrl+Backspace
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace
z4h bindkey z4h-kill-zword          Ctrl+Alt+Delete

z4h bindkey backward-kill-line      Ctrl+U
z4h bindkey kill-line               Alt+U
z4h bindkey kill-whole-line         Alt+I

z4h bindkey z4h-forward-zword       Ctrl+Alt+Right
z4h bindkey z4h-backward-zword      Ctrl+Alt+Left

z4h bindkey z4h-cd-back             Alt+H
z4h bindkey z4h-cd-forward          Alt+L
z4h bindkey z4h-cd-up               Alt+K
z4h bindkey z4h-fzf-dir-history     Alt+J

z4h bindkey my-ctrl-z               Ctrl+Z
z4h bindkey edit-command-line       Alt+E

z4h bindkey z4h-exit                Ctrl+D

z4h bindkey undo Ctrl+/   Shift+Tab  # undo the last command line change
z4h bindkey redo Option+/            # redo the last undone command line change

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

# Commands & aliases
alias cp='cp -r --reflink=auto'
alias mkdir='mkdir -p'

[ -z "$EDITOR" ] && export EDITOR='nvim'
[ -z "$VISUAL" ] && export EDITOR="$VISUAL"

command -v curlie &> /dev/null && alias curl='curlie'
command -v bat    &> /dev/null && alias cat='bat --theme=OneHalfDark'
command -v nvim   &> /dev/null && alias vim='nvim'
command -v fd     &> /dev/null && alias fd='fd --hidden --follow' || alias fd='find . -name'
command -v rg     &> /dev/null && alias rg='rg --hidden --follow --smart-case 2>/dev/null' || alias rg='grep --color=auto --exclude-dir=.git -R'
command -v exa    &> /dev/null && alias ls='exa --group --git --group-directories-first' || alias ls='ls --color=auto --group-directories-first -h'
command -v exa    &> /dev/null && alias ll='exa -l -a -s type --group-directories-first --git' || alias ll='ls -A'
command -v exa    &> /dev/null && alias lt='exa -T -s type --git-ignore --level=2 --group-directories-first'
command -v exa    &> /dev/null && alias llt='exa -lT -s type --git-ignore --level=2 --group-directories-first'
command -v exa    &> /dev/null && alias lT='exa -T -s type --git-ignore --level=4 --group-directories-first'
command -v htop   &> /dev/null && alias top='htop'
command -v procs  &> /dev/null && alias ps='procs'
command -v duf    &> /dev/null && alias df='duf'
command -v dust   &> /dev/null && alias du='dust'
command -v gping  &> /dev/null && alias ping='gping'
command -v tldr   &> /dev/null && alias man='tldr'

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

if [ "$(command -v atuin)" ]; then
    eval "$(atuin init zsh --disable-up-arrow)"

    export ATUIN_NOBIND="true"

    fzf-atuin-history-widget() {
        local atuin_opts="--cmd-only"
        local fzf_opts=(
            --height=${FZF_TMUX_HEIGHT:-80%}
            --tac
            "-n2..,.."
            --tiebreak=index
            "--query=${LBUFFER}"
            "+m"
            "--bind=ctrl-d:reload(atuin search $atuin_opts -c $PWD),ctrl-r:reload(atuin search $atuin_opts)"
        )

        selected=$(
        eval "atuin search ${atuin_opts}" |
            fzf "${fzf_opts[@]}"
        )
        local ret=$?
        if [ -n "$selected" ]; then
            # the += lets it insert at current pos instead of replacing
            LBUFFER+="${selected}"
        fi
        zle reset-prompt
        return $ret
    }
    zle -N fzf-atuin-history-widget
    bindkey '^r' fzf-atuin-history-widget

    _zsh_autosuggest_strategy_atuin_top() {
        suggestion=$(atuin search --cmd-only --limit 1 --search-mode prefix $1)
    }
fi

# fnm
if [ "$(command -v fnm)" ]; then
    eval "$(fnm env --use-on-cd)"
fi

# pyenv
if [ "$(command -v pyenv)" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1

    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# goenv
if [ "$(command -v goenv)" ]; then
    export GOENV_ROOT="$HOME/.goenv"
    command -v pyenv >/dev/null || export PATH="$GOENV_ROOT/bin:$PATH"
    eval "$(goenv init -)"
fi

# orbstack
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# mactex
eval "$(/usr/libexec/path_helper)"
