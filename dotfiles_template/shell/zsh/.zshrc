# Uncomment for debuf with `zprof`
# zmodload zsh/zprof

if [[ -f "$DOTLY_PATH/shell/zsh/init-dotly.sh" ]]
then
  . "$DOTLY_PATH/shell/zsh/init-dotly.sh"
else
  echo "\033[0;31m\033[1mDOTLY Could not be loaded\033[0m"
fi