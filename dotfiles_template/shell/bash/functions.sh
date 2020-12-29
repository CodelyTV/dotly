__right_prompt() {
  RIGHT_PROMPT=""
  [[ -n $RPS1 ]] && RIGHT_PROMPT=$RPS1 || RIGHT_PROMPT=$RPROMPT
  if [[ -n $RIGHT_PROMPT ]]; then
    n=$(($COLUMNS-${#RIGHT_PROMPT}))
    printf "%${n}s$RIGHT_PROMPT\\r"
  fi
}