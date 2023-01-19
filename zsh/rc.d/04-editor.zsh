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
bindkey ' '  magic-space  # [Space] Do history expansion

# Trim trailing newline from pasted text
bracketed-paste() {
    zle .$WIDGET && LBUFFER=${LBUFFER%$'\n'}
}
zle -N bracketed-paste

# Make mode change lag go away
export KEYTIMEOUT=1

