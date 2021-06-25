PROMPT_COMMAND="codely_theme"

MIDDLE_CHARACTER="◂"
GREEN_COLOR="32"
RED_COLOR="31"

prompt_dotly_autoupdate() {
  if [ -f "$DOTFILES_PATH/.sloth_update_available" ] &&\
     { 
        [ "$(echo "$DOTLY_AUTO_UPDATE_MODE" | tr '[:upper:]' '[:lower:]')" != "minor" ] ||\
        {
          [ "$(echo "$DOTLY_AUTO_UPDATE_MODE" | tr '[:upper:]' '[:lower:]')" == "minor" ] &&\
          [ ! -f "$DOTFILES_PATH/.sloth_update_available_is_major" ]
        }
     }
  then
    print -n "📥  | "
  fi
}

codely_theme() {
  LAST_CODE="$?"
  current_dir=$(dot core short_pwd)
  STATUS_COLOR=$GREEN_COLOR

  if [ $LAST_CODE -ne 0 ]; then
    STATUS_COLOR=$RED_COLOR
    MIDDLE_CHARACTER="▪"
  fi

  if [ -z "$CODELY_THEME_MINIMAL" ]; then
    export PS1="\$(prompt_dotly_autoupdate)\[\e[${STATUS_COLOR}m\]{\[\e[m\]${MIDDLE_CHARACTER}\[\e[${STATUS_COLOR}m\]}\[\e[m\] \[\e[33m\]${current_dir}\[\e[m\] "
  else
    export PS1="\$(prompt_dotly_autoupdate)\[\e[${STATUS_COLOR}m\]{\[\e[m\]${MIDDLE_CHARACTER}\[\e[${STATUS_COLOR}m\]}\[\e[m\] "
  fi
}
