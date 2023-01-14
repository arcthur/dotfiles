# Generate theme colors for Git & Zsh.
znap source marlonrichert/zcolors
znap eval zcolors zcolors

# Prompt
znap eval starship 'starship init zsh --print-full-init'
znap prompt

# Edit
znap source marlonrichert/zsh-edit
zstyle ':edit:*' word-chars '*?\'

# History
znap source marlonrichert/zsh-hist

# Fzf
znap source arcthur/zsh-fzf

# Auto suggestions
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=( forward-char forward-word end-of-line )
ZSH_AUTOSUGGEST_STRATEGY=( history completion )
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'(*\n*|?(#c80,)|*\\#:hist:push-line:)'
znap source zsh-users/zsh-autosuggestions

# Syntax highlighting
znap source zdharma-continuum/fast-syntax-highlighting

# Histotry search
znap source zdharma-continuum/history-search-multi-word
znap source zsh-users/zsh-history-substring-search

# Lazy Load
znap function _pyenv pyenv 'eval "$(pyenv init - --no-rehash)"'
compctl -K _pyenv pyenv

znap function _python_argcomplete pipx 'eval "$(register-python-argcomplete pipx)"'
complete -o nospace -o default -o bashdefault -F _python_argcomplete pipx

znap function _fnm fnm 'eval "$(fnm env --use-on-cd)"'
compctl -K _fnm fnm
