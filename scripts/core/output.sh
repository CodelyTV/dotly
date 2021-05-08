#!/usr/bin/env bash

red='\033[0;31m'
green='\033[0;32m'
bold_blue='\033[1m\033[34m'
normal='\033[0m'

output::write() {
  local -r text="${1:-}"
  echo -e "$text"
}
output::answer() { output::write " > $1"; }
output::error() { output::answer "${red}$1${normal}"; }
output::solution() { output::answer "${green}$1${normal}"; }
output::question() {
  if [ platform::is_macos ]; then
    echo -n " > 🤔 $1: ";
    read -r "$2";
  else
    read -rp "🤔 $1: " "$2"
  fi
}
output::question_default() {
  local question default_value var_name
  question="$1"
  default_value="$2"
  var_name="$3"

  output::question "$question? [$default_value]" "$var_name"
  eval "$var_name=\"\${$var_name:-$default_value}\""
}
output::yesno() {
  local question default PROMPT_REPLY values
  question="$1"
  default="${2:-Y}"

  if [[ "$default" =~ ^[Yy] ]]; then
    values="Y/n"
  else
    values="y/N"
  fi

  output::question "$question? [$values]" "PROMPT_REPLY"
  [[ "${PROMPT_REPLY:-$default}" =~ ^[Yy] ]]
}
output::empty_line() { echo ''; }
output::header() { output::empty_line; output::write "${bold_blue}---- $1 ----${normal}"; }
