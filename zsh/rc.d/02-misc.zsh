# Zgenom Plugin
# ---------------
zgenom autoupdate  # every 7 days

if ! zgenom saved; then
    zgenom load arcthur/zsh-fzf
    zgenom load Aloxaf/fzf-tab
    zgenom load Freed-Wu/fzf-tab-source

    zgenom load zsh-users/zsh-autosuggestions
    zgenom load zdharma-continuum/fast-syntax-highlighting
    zgenom load marlonrichert/zsh-edit

    zgenom clean
    zgenom save
    zgenom compile $ZDOTDIR
fi

# zsh-autosuggestions
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=( forward-char forward-word end-of-line )
ZSH_AUTOSUGGEST_STRATEGY=( history completion )
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_MANUAL_REBIND='1'
ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'(*\n*|?(#c80,)|*\\#:hist:push-line:)'

# fast-syntax-highlighting
export FAST_THEME_NAME='clean'
