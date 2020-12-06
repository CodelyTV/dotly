export DOTFILES_PATH="XXX_DOTFILES_PATH_XXX"
export DOTLY_PATH="$DOTFILES_PATH/modules/dotly"

source "$DOTFILES_PATH/shell/init.sh"

PATH=$(
  IFS=":"
  echo "${path[*]}"
)
export PATH

source "$DOTLY_PATH/shell/bash/themes/codely.sh"
