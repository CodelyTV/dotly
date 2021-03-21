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
  local question="$1"
  local default_value="$2"
  local var_name="$3"

  if [ platform::is_macos ]; then
    echo -n "🤔 $question [$default_value]: ";
    read -r "$var_name";
  else
    read -rp "🤔 $question [$default_value]: " "$var_name"
  fi
  eval "$var_name=\"\${$var_name:-$default_value}\""
}
output::empty_line() { echo ''; }
output::header() { output::empty_line; output::write "${bold_blue}---- $1 ----${normal}"; }
