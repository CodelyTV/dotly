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
    output::answer "🤔 $1: ";
    read -r "$2";
  else
    read -rp " $1: " "$2"
  fi
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

  if [ platform::is_macos ]; then
    echo -n "🤔 $question [$values]: ";
    read -r "PROMPT_REPLY";
  else
    read -rp "🤔 $question [$values]: " "PROMPT_REPLY"
  fi
  PROMPT_REPLY=${PROMPT_REPLY:-$default}
  [[ "$PROMPT_REPLY" =~ ^[$default_check] ]]
}
output::empty_line() { echo ''; }
output::header() { output::empty_line; output::write "${bold_blue}---- $1 ----${normal}"; }
