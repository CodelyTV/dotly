#!/usr/bin/env bash

debug::out() {
  echo "$@"
}

debug::log() {
  [[ ! -z "$DEBUG" ]] && debug::out "$@"
}

debug::logg() {
  DEBUG_LEVEL=${DEBUG_LEVEL:-1}
  [[ $DEBUG_LEVEL -gt 1 ]] && debug::log $@
}

debug::log_exec() {
  debug::log "Executing: ${@[@]}"
  eval "${@[@]}"
}

debug::set_variable () {
  local var_name="$1"
  shift
  local values=$@
  eval "$var_name=${values[@]}"

  debug::logg "Set varible '$var_name' to '${values[@]}'"
} 