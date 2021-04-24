if [[ "$(ps -p $$ -ocomm=)" =~ (bash$) ]]; then
  __right_prompt() {
    RIGHT_PROMPT=""
    [[ -n $RPS1 ]] && RIGHT_PROMPT=$RPS1 || RIGHT_PROMPT=$RPROMPT
    if [[ -n $RIGHT_PROMPT ]]; then
      n=$(($COLUMNS - ${#RIGHT_PROMPT}))
      printf "%${n}s$RIGHT_PROMPT\\r"
    fi
  }
  export PROMPT_COMMAND="__right_prompt"
fi

. "$DOTFILES_PATH/shell/paths.sh"

PATH=$(
  IFS=":"
  echo "${path[*]}"
)
export PATH

[[ -f "$DOTFILES_PATH/shell/init.sh" ]] && . "$DOTFILES_PATH/shell/init.sh"

themes_paths=(
  "$DOTFILES_PATH/shell/bash/themes"
  "$DOTLY_PATH/shell/bash/themes"
)

for THEME_PATH in ${themes_paths[@]}; do
  THEME_PATH="${THEME_PATH}/$DOTLY_THEME.sh"
  [ -f "$THEME_PATH" ] && source "$THEME_PATH" && break
done

for bash_file in "$DOTLY_PATH"/shell/bash/completions/_*; do
  . "$bash_file"
done

if [ -n "$(ls -A "$DOTFILES_PATH/shell/bash/completions/")" ]; then
  for bash_file in "$DOTFILES_PATH"/shell/bash/completions/_*; do
    . "$bash_file"
  done
fi

# Auto Init scripts at the end
if [ -z "${DOTLY_NO_INIT_SCRIPTS:-false}" ]; then
  init_scripts_path="$DOTFILES_PATH/shell/init-scripts.enabled"
  mkdir -p "$init_scripts_path"
  find "$init_scripts_path" -mindepth 1 -maxdepth 1 -type l,f -name '*' | while read init_script; do
      [[ -e "$init_script" ]] && . "$init_script"
    done
fi
