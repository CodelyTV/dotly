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

PATH=$(
  IFS=":"
  echo "${path[*]:-}"
)
export PATH

themes_paths=(
  "$DOTFILES_PATH/shell/bash/themes"
  "$DOTLY_PATH/shell/bash/themes"
)

# bash completion
export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
if [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]; then
  #shellcheck source=/dev/null
  . "/usr/local/etc/profile.d/bash_completion.sh"
fi

# brew Bash completion
if type brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    #shellcheck source=/dev/null
    . "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      #shellcheck source=/dev/null
      [[ -r "$COMPLETION" ]] && . "$COMPLETION"
    done
  fi
fi
unset COMPLETION

#shellcheck disable=SC2068
for THEME_PATH in ${themes_paths[@]}; do
  THEME_PATH="${THEME_PATH}/${DOTLY_THEME:-codely}.sh"
  #shellcheck source=/dev/null
  [ -f "$THEME_PATH" ] && . "$THEME_PATH" && break
done
unset THEME_PATH

find {"$DOTLY_PATH","$DOTFILES_PATH"}"/shell/bash/completions/" -name "_*" -print0 -exec echo {} \; 2>/dev/null | xargs -I _ echo _ | while read -r completion; do
  #shellcheck source=/dev/null
  . "$completion" || echo -e "\033[0;31mBASH completion '$completion' could not be loaded\033[0m"
done
unset completion
