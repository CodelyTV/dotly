PROMPT_COMMAND="codely_theme"

MIDDLE_CHARACTER="◂"
GREEN_COLOR="32"
RED_COLOR="31"

prompt_dotly_update() {
  if [ -f "$DOTFILES_PATH/.dotly_update_available" ]; then
    UPDATE_MESSAGE="📥  | "
  fi
}

codely_theme() {
  LAST_CODE="$?"
  current_dir=$(dot core short_pwd)
  STATUS_COLOR=$GREEN_COLOR
  UPDATE_MESSAGE=""

  if [ $LAST_CODE -ne 0 ]; then
    STATUS_COLOR=$RED_COLOR
  fi



  export PS1="\$(prompt_dotly_update)\[\e[${STATUS_COLOR}m\]{\[\e[m\]${MIDDLE_CHARACTER}\[\e[${STATUS_COLOR}m\]}\[\e[m\] \[\e[33m\]${current_dir}\[\e[m\] "
}
