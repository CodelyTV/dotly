export DOTFILES_PATH="XXX_DOTFILES_PATH_XXX"
export DOTLY_PATH="$DOTFILES_PATH/modules/dotly"

source "$DOTFILES_PATH/shell/init.sh"

PATH=$(
  IFS=":"
  echo "${path[*]}"
)
export PATH

themes_paths=(
    "$DOTFILES_PATH/shell/bash/themes"
    "$DOTLY_PATH/shell/bash/themes"
)

SHELL_THEME=${SHELL_THEME:-codelytv}

for THEME_PATH in ${themes_paths[@]}; do
  THEME_PATH="${THEME_PATH}/$SHELL_THEME.sh"
  [ -f "$THEME_PATH" ] && source "$THEME_PATH" && break
done

for bash_file in "$DOTFILES_PATH"/shell/bash/completions/*.sh; do
  source "$bash_file"
done