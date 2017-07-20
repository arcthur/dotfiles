#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

export GOPATH=$HOME/gocode
export NODE_PATH=/usr/local/lib/node_modules/jsctags/:$NODE_PATH
export PATH=/usr/local/bin:/usr/bin:/usr/local/share/npm/bin:$HOME/.rbenv:$PATH:$HOME/bin:$GOPATH/bin:/Library/TeX/texbin

# work
function sudo-command-line () {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line
}
zle -N sudo-command-line
bindkey "\e" sudo-command-line # bindkey : [Esc]

_matcher_complete() {
  integer i=1
  (git ls-files 2>/dev/null || find .) | /usr/local/bin/matcher -l20 ${words[CURRENT]} | while read line; do
    compadd -U -2 -V $i -- "$line"
    i=$((i+1))
  done
  compstate[insert]=menu
}

zle -C matcher-complete complete-word _generic
zstyle ':completion:matcher-complete:*' completer _matcher_complete
zstyle ':completion:matcher-complete:*' menu-select

# Directories
zstyle ':completion:*:default' list-colors ''

unsetopt CORRECT                      # Disable autocorrect guesses. Happens when typing a wrong
                                      # command that may look like an existing one.

expand-or-complete-with-dots() {      # This bunch of code displays red dots when autocompleting
  echo -n "\e[31m......\e[0m"         # a command with the tab key, "Oh-my-zsh"-style.
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# Color LS
colorflag="-G"
alias ls="command ls ${colorflag}"
alias l="ls -lF ${colorflag}" # all files, in long format
alias ll="ls -laF ${colorflag}" # all files inc dotfiles, in long format
alias lsd='ls -lF ${colorflag} | grep "^d"' # only directories

#node
alias node='node --harmony'

alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias chrome-debug='sudo open -a Google\ Chrome --args --disable-web-security --user-data-dir'

# mvim
alias mvim='gvim --remote-tab';

[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh # This loads NVM
export NVM_NODEJS_ORG_MIRROR=http://npm.taobao.org/mirrors/node

# jsut
export PATH=~/.just-installs/bin:$PATH

ulimit -S -n 2048

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
