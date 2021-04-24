# Firstly Paths
#shellcheck source=/dev/null
. "$DOTFILES_PATH/shell/paths.sh"

# ZSH Ops
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FCNTL_LOCK
setopt +o nomatch
# setopt autopushd

# Start zim
#shellcheck source=/dev/null
. "$ZIM_HOME/init.zsh"

# Async mode for autocompletion
# shellcheck disable=SC2034
ZSH_AUTOSUGGEST_USE_ASYNC=true
# shellcheck disable=SC2034
ZSH_HIGHLIGHT_MAXLENGTH=300

#shellcheck source=/dev/null
[[ -f "$DOTFILES_PATH/shell/init.sh" ]] && . "$DOTFILES_PATH/shell/init.sh"

fpath=("$DOTFILES_PATH/shell/zsh/themes" "$DOTFILES_PATH/shell/zsh/autocompletions" "$DOTLY_PATH/shell/zsh/themes" "$DOTLY_PATH/shell/zsh/completions" $fpath)

autoload -Uz promptinit && promptinit
prompt ${DOTLY_THEME:-codely}

#shellcheck source=/dev/null
. "$DOTLY_PATH/shell/zsh/bindings/reverse_search.zsh"
#shellcheck source=/dev/null
. "$DOTFILES_PATH/shell/zsh/key-bindings.zsh"

# Auto Init scripts at the end
if [ -z "${DOTLY_NO_INIT_SCRIPTS:-false}" ]; then
  init_scripts_path="$DOTFILES_PATH/shell/init-scripts.enabled"
  mkdir -p "$init_scripts_path"
  find "$init_scripts_path" -mindepth 1 -maxdepth 1 -type l,f -name '*' | while read init_script; do
      [[ -e "$init_script" ]] && . "$init_script"
    done
fi
