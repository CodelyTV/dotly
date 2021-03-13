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
    read -rp "🤔 $1: " "$2"
  fi
}
output::question_default() {
  local default_answer="$2"
  local user_value=""

  if [ platform::is_macos ]; then
    echo -n "🤔 $1 [$2]: ";
    read -r "$3";
  else
    read -rp "🤔 $1 [$2]: " "$3"
  fi
  eval "$3=\"\${$3:-$2}\""
}
output::empty_line() { echo ''; }
output::header() { output::empty_line; output::write "${bold_blue}---- $1 ----${normal}"; }
