export DOTFILES_PATH="XXX_DOTFILES_PATH_XXX"

if [[ -d "$DOTFILES_PATH/modules/sloth" ]]; then
  export DOTLY_PATH="$DOTFILES_PATH/modules/sloth"
elif [[ -d "$DOTFILES_PATH/modules/dotly" ]]; then
  export DOTLY_PATH="$DOTFILES_PATH/modules/dotly"
fi
export SLOTH_PATH="$DOTLY_PATH"

if [[ -f "${SLOTH_PATH:-$DOTLY_PATH}/shell/init-sloth.sh" ]]
then
  #shellcheck disable=SC1091
  . "${SLOTH_PATH:-$DOTLY_PATH}/shell/init-sloth.sh"
else
  echo "\033[0;31m\033[1mDOTLY Loader could not be found, check \$DOTFILES_PATH variable\033[0m"
fi
