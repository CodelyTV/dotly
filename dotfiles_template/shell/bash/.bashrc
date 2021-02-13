export DOTFILES_PATH="XXX_DOTFILES_PATH_XXX"
export DOTLY_PATH="$DOTFILES_PATH/modules/dotly"
export DOTLY_THEME="codely"

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

source "$DOTFILES_PATH/shell/paths.sh"

PATH=$(
  IFS=":"
  echo "${path[*]}"
)
export PATH

source "$DOTFILES_PATH/shell/init.sh"

themes_paths=(
  "$DOTFILES_PATH/shell/bash/themes"
  "$DOTLY_PATH/shell/bash/themes"
)

for THEME_PATH in ${themes_paths[@]}; do
  THEME_PATH="${THEME_PATH}/$DOTLY_THEME.sh"
  [ -f "$THEME_PATH" ] && source "$THEME_PATH" && break
done

for bash_file in "$DOTLY_PATH"/shell/bash/completions/*; do
  source "$bash_file"
done

if [ -n "$(ls -A "$DOTFILES_PATH/shell/bash/completions/")" ]; then
  for bash_file in "$DOTFILES_PATH"/shell/bash/completions/*; do
    source "$bash_file"
  done
fi
