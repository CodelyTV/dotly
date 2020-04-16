__fzfcmd() {
  echo "fzf"
}

# ctrl+r - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail HIST_FIND_NO_DUPS 2> /dev/null

  selected=( $(fc -rl 1 |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
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
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget

# ctrl+g - Paste the selected command from history into the command line
_call_navi() {
   local navi_path=$(command -v navi)
   local buff="$BUFFER"
   zle kill-whole-line
   local cmd="$(NAVI_USE_FZF_ALL_INPUTS=true "$navi_path" --print <> /dev/tty)"
   zle -U "${buff}${cmd}"
}
zle     -N   _call_navi
bindkey '^g' _call_navi
