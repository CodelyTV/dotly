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
    echo -n " > 🤔 $1: ";
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

  output::question "$question? [$values]" "PROMPT_REPLY"
  [[ "${PROMPT_REPLY:-$default}" =~ ^[$default_check] ]]
}
output::empty_line() { echo ''; }
output::header() { output::empty_line; output::write "${bold_blue}---- $1 ----${normal}"; }
