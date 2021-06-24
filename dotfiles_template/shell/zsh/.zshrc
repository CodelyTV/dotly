# Uncomment for debuf with `zprof`
# zmodload zsh/zprof

if [[ -f "$DOTLY_PATH/shell/init-dotly.sh" ]]
then
  . "$DOTLY_PATH/shell/init-dotly.sh"
else
  echo "\033[0;31m\033[1mDOTLY Loader could not be found, check \$DOTFILES_PATH variable\033[0m"
fi
