#!/usr/bin/env bash

source "$DOTLY_PATH/scripts/core/_main.sh"


_dot() {
  local suggestions=""

  case ${#COMP_WORDS[@]} in
    3)
        suggestions="$(dot::list_context_scripts ${COMP_WORDS[1]})"
        ;;

    *)
        #echo "First"
        suggestions=$(compgen -W "$(dot::list_contexts | tr '\n' ' ')")
        ;;
  esac


  COMPREPLY=($(compgen -W "$suggestions" "${COMP_WORDS[$COMP_CWORD]}"))
}

complete -F _dot dot