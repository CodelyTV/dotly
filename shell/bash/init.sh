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
  echo "${path[*]}"
)
export PATH

# Aliases
[[ -f "$DOTFILES_PATH/shell/aliases.sh" ]] && . "$DOTFILES_PATH/shell/aliases.sh"

# Functions
[[ -f "$DOTFILES_PATH/shell/functions.sh" ]] && . "$DOTFILES_PATH/shell/functions.sh"

themes_paths=(
  "$DOTFILES_PATH/shell/bash/themes"
  "$DOTLY_PATH/shell/bash/themes"
)

# bash completion
export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
if [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]; then
    . "/usr/local/etc/profile.d/bash_completion.sh"
fi

# brew Bash completion
if type brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    . "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      [[ -r "$COMPLETION" ]] && . "$COMPLETION"
    done
  fi
fi

for THEME_PATH in ${themes_paths[@]}; do
  THEME_PATH="${THEME_PATH}/${DOTLY_THEME:-codely}.sh"
  [ -f "$THEME_PATH" ] && . "$THEME_PATH" && break
done

for bash_file in "$DOTLY_PATH"/shell/bash/completions/_*; do
  . "$bash_file"
done

if [ -n "$(ls -A "$DOTFILES_PATH/shell/bash/completions/")" ]; then
  for bash_file in "$DOTFILES_PATH"/shell/bash/completions/_*; do
    . "$bash_file"
  done
fi
