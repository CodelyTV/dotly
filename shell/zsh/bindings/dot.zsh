dot-widget() {
  "$DOTLY_PATH/bin/dot"
}

zle -N dot-widget
bindkey '^f' dot-widget
