[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Fig pre block. Keep at the top of this file.

# Homebrew and Tools
eval "$(zoxide init zsh)"      # A smarter cd command
export SKIM_DEFAULT_COMMAND="fd --type f || git ls-tree -r --name-only HEAD || rg --files || find ."

# zsh-snap {
[[ -f ~/.znap/zsh-snap/znap.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/.znap/zsh-snap

source ~/.znap/zsh-snap/znap.zsh

# Prompt
znap eval starship 'starship init zsh --print-full-init'
znap prompt

# Load plugins
#znap source marlonrichert/zsh-autocomplete
znap source marlonrichert/zsh-edit

ZSH_AUTOSUGGEST_STRATEGY=( history completion )
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
znap source zsh-users/zsh-autosuggestions

znap source sorin-ionescu/prezto modules/{environment,history,completion,directory}
zstyle ':prezto:module:history' histfile "${ZDOTDIR:-$HOME}/.zsh_history"
zstyle ':prezto:module:history' histsize 10000
zstyle ':prezto:module:history' savehist 10000

znap eval trapd00r/LS_COLORS "$( whence -a dircolors gdircolors ) -b LS_COLORS"

znap source marlonrichert/zcolors
znap eval   marlonrichert/zcolors "zcolors ${(q)LS_COLORS}"

znap source zdharma-continuum/history-search-multi-word
znap source zdharma-continuum/fast-syntax-highlighting

# Lazy Load
znap function _pyenv pyenv 'eval "$( pyenv init - --no-rehash )"'
compctl -K _pyenv pyenv

znap function _python_argcomplete pipx 'eval "$( register-python-argcomplete pipx  )"'
complete -o nospace -o default -o bashdefault -F _python_argcomplete pipx

znap function _fnm fnm 'eval "$(fnm env --use-on-cd)"'
compctl -K _fnm fnm
# }

# Make VI mode as default for zsh {
# https://dougblack.io/words/zsh-vi-mode.html
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
alias cat='bat'
alias less='bat'
alias find='fdfind'
alias top='htop'
alias ps='procs'
alias grep='rg'
alias df='duf'
alias du='dust'
alias ping='gping'
alias man='tldr'
alias cd='z'

alias ls='exa'
alias l='exa -l --all --group-directories-first --git'
alias ll='exa -l --all --all --group-directories-first --git'
alias lt='exa -T --git-ignore --level=2 --group-directories-first'
alias llt='exa -lT --git-ignore --level=2 --group-directories-first'
alias lT='exa -T --git-ignore --level=4 --group-directories-first'

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
