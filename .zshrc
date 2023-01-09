[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Fig pre block. Keep at the top of this file.

setopt prompt_subst interactive_comments

# Source Prezto.
[[ -f "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]] && source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

# Homebrew and Tools
eval "$(fnm env --use-on-cd)"  # Node management
eval "$(zoxide init zsh)"      # A smarter cd command
source $HOME/.config/fsh/F-Sy-H.plugin.zsh
export SKIM_DEFAULT_COMMAND="fd --type f || git ls-tree -r --name-only HEAD || rg --files || find ."

# Delete Git's official completions to allow Zsh's official Git completions to work.
# This is also necessary for hub's Zsh completions to work:
# https://github.com/github/hub/issues/1956
[ -f /usr/local/share/zsh/site-functions/_git ] && rm /usr/local/share/zsh/site-functions/_git

# Make VI mode as default for zsh {
# https://dougblack.io/words/zsh-vi-mode.html
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
# }

# Use Neovim as "preferred editor" {
export VISUAL=nvim
export EDITOR="$VISUAL"

# fix terminals to send ctrl-h to neovim correctly
[[ -f "~/.$TERM.ti" ]] && tic ~/.$TERM.ti
# }


# Quickly Sudo {
function sudo-command-line () {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line
}
zle -N sudo-command-line
bindkey "^b" sudo-command-line
# }

alias chromews='sudo open -a Google\ Chrome --args --disable-web-security'

# Better Version
alias git='hub'
alias cat='bat'
alias less='bat'
alias diff='delta'
alias find='fdfind'
alias top='htop'
alias ps='procs'
alias ls='exa'
alias grep='rg'
alias df='duf'
alias du='dust'
alias ping='gping'
alias man='tldr'
alias cd='z'

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
