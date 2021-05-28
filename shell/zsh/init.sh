reverse-search() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail HIST_FIND_NO_DUPS 2> /dev/null

  selected=( $(fc -rl 1 |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" fzf) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}

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
[[ -f "$DOTFILES_PATH/shell/aliases.sh" ]] && . "$DOTFILES_PATH/shell/aliases.sh"
[[ -f "$DOTFILES_PATH/shell/functions.sh" ]] && . "$DOTFILES_PATH/shell/functions.sh"

fpath=("$DOTFILES_PATH/shell/zsh/themes" "$DOTFILES_PATH/shell/zsh/autocompletions" "$DOTLY_PATH/shell/zsh/themes" "$DOTLY_PATH/shell/zsh/completions" $fpath)

autoload -Uz promptinit && promptinit
prompt ${DOTLY_THEME:-codely}

#shellcheck source=/dev/null
. "$DOTLY_PATH/shell/zsh/bindings/dot.zsh"
#shellcheck source=/dev/null
. "$DOTLY_PATH/shell/zsh/bindings/reverse_search.zsh"
#shellcheck source=/dev/null
. "$DOTFILES_PATH/shell/zsh/key-bindings.zsh"
