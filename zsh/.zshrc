export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_DIR="/etc/xdg"
export XDG_DATA_DIR="/usr/local/share/:/usr/share/"

export ZDOTDIR=$XDG_CONFIG_HOME/zsh

() {
  local __file__=
  for __file__ in $ZDOTDIR/rc.d/*.zsh; do
    . $__file__
  done
}
