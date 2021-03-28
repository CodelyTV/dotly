export DOTFILES_PATH="XXX_DOTFILES_PATH_XXX"
export DOTLY_PATH="$DOTFILES_PATH/modules/dotly"
export DOTLY_THEME="codely"

[[ -f "$DOTLY_PATH/shell/bash/init-dotly.sh" ]] && "$DOTLY_PATH/shell/bash/init-dotly.sh" || echo "\033[0;31m\033[1mDOTLY Could not be loaded\033[0m"