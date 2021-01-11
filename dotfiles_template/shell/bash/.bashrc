export DOTFILES_PATH="XXX_DOTFILES_PATH_XXX"
export DOTLY_PATH="$DOTFILES_PATH/modules/dotly"

source "$DOTFILES_PATH/shell/init.sh"

PATH=$(
  IFS=":"
  echo "${path[*]}"
)
export PATH

themes_paths=(
    "$DOTFILES_PATH/shell/$MYSHELL/themes"
    "$DOTFILES_PATH/shell/themes"
    "$DOTLY_PATH/shell/$MYSHELL/themes"
)

SHELL_THEME=${SHELL_THEME:-codelytv}

for theme_path in ${themes_paths[@]}; do
  theme_path="${theme_path}/$SHELL_THEME.sh"
  [ -f "$theme_path" ] && source "$theme_path" && break
done

[ -f "$DOTLY_PATH/shell/bash/themes/${SHELL_THEME:-codelytv}.sh" ] && source "$DOTLY_PATH/shell/bash/themes/${$SHELL_THEME:-codelytv}.sh"

for bash_file in "$DOTLY_PATH"/shell/bash/completions/*.sh; do
  source $bash_file
done