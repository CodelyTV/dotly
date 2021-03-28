#!/usr/bin/env bash

red='\033[0;31m'
green='\033[0;32m'
bold_blue='\033[1m\033[34m'
normal='\033[0m'

platform::is_macos() {
  [[ $(uname -s) == "Darwin" ]]
}

output::write() {
  local -r text="${1:-}"
  echo -e "$text"
}
output::answer() { output::write " > $@"; }
output::error() { output::answer "${red}$@${normal}"; }
output::solution() { output::answer "${green}$@${normal}"; }
output::question() {
  if [ platform::is_macos ]; then
    output::answer "🤔 $1: ";
    read -r "$2";
  else
    read -rp "🤔 $1: " "$2"
  fi
}
output::question_default() {
  local question="$1"
  local default_value="$2"
  local var_name="$3"

  output::question "$question? [$default_value]" "$var_name"
  eval "$var_name=\"\${$var_name:-$default_value}\""
}
output::yesno() {
  local question="$1"
  local default="${2:-Y}"
  local PROMPT_REPLY values default_check

  if [[ "$default" =~ ^[Yy] ]]; then
    values="Y/n"
    default_check="Yy"
  else
    values="y/N"
    default_check="Nn"
  fi

  output::question_default "$question" "$values" "PROMPT_REPLY"
  [[ "$PROMPT_REPLY" =~ ^[$default_check] ]]
}
output::empty_line() { echo ''; }
output::header() { output::empty_line; output::write "${bold_blue}---- $1 ----${normal}"; }
output::str_to_upper() { echo $@ | tr '[:lower:]' '[:upper:]'; }
# This only joins by one char as glue
#output::join() { local IFS="$1"; shift; echo "$*"; unset IFS; }
# split is not compatible with strings that have new space
output::split() { local IFS="$1"; shift; echo "${!@[@]}"; unset IFS; }
#This can join with string as glue
output::join() {
  local glue="$1"; shift
  local counter=0
  local IFS=''
  for item in "$@"; do
    counter=$(( $counter + 1 ))
    echo -n -e "$item"
    [[ $counter -ne $# ]] && echo -n -e "$glue"
  done
}
# Usage: output::array_* "${arr1[@]}" "${arr2[@]}"
output::array_union() { echo "${@}" | tr ' ' '\n' | sort | uniq; }
output::array_disjunction() { echo "${@}" | tr ' ' '\n' | sort | uniq -u; }
output::array_difference() { echo "${@}" | tr ' ' '\n' | sort | uniq -d; }