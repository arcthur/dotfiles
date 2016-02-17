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
export PATH=/usr/local/bin:/usr/bin:/usr/local/share/npm/bin:$PATH:$HOME/bin:$GOPATH/bin:/usr/texbin/

# work
alias mvn-install='mvn clean install -Dmaven.test.skip=true'
alias mvn-eclipse='mvn eclipse:clean eclipse:eclipse'

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

# alias
# List direcory contents
alias ll='ls++ -alGh'
alias ls='ls++ -Gh'
alias sl=ls++ # often screw this up
alias vim='DYLD_FORCE_FLAT_NAMESPACE=1 vim'
alias ping=prettyping.sh
