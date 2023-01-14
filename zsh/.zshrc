export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_DIR="/etc/xdg"
export XDG_DATA_DIR="/usr/local/share/:/usr/share/"
export XDG_DATA_HOME="$HOME/.local/share"

export ZSNAP_HOME="$HOME/.znap"

[[ -f $ZSNAP_HOME/zsh-snap/znap.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git $ZSNAP_HOME/zsh-snap

source $ZSNAP_HOME/zsh-snap/znap.zsh

() {
  local __file__=
  for __file__ in $ZDOTDIR/rc.d/*.zsh; do
    . $__file__
  done
}
