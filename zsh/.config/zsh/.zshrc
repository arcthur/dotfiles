export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_DIR="/etc/xdg"
export XDG_DATA_DIR="/usr/local/share/:/usr/share/"
export XDG_DATA_HOME="$HOME/.local/share"

export ZGENOM_HOME="$HOME/.zgenom"

[[ -f $ZGENOM_HOME/zgenom.zsh ]] ||
    git clone --depth 1 -- https://github.com/jandamm/zgenom $ZGENOM_HOME

source $ZGENOM_HOME/zgenom.zsh

export PATH=/opt/homebrew/bin:$HOME/.local/bin:$PATH

() {
  local __file__=
  for __file__ in $ZDOTDIR/rc.d/*.zsh; do
    . $__file__
  done
}
