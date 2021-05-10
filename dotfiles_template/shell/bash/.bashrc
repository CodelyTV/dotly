export DOTFILES_PATH="XXX_DOTFILES_PATH_XXX"
export DOTLY_PATH="$DOTFILES_PATH/modules/dotly"
export DOTLY_THEME="codely"

if [[ -f "$DOTLY_PATH/shell/bash/init-dotly.sh" ]]
then
  . "$DOTLY_PATH/shell/bash/init-dotly.sh"
else
  echo "\033[0;31m\033[1mDOTLY Could not be loaded\033[0m"
fi
