#!/usr/bin/env bash

red='\033[0;31m'
green='\033[0;32m'
bold_blue='\033[1m\033[34m'
gray='\e[90m'
normal='\033[0m'

_output::parse_code() {
  local -r text="${1:-}"

  with_code_parsed=$(echo "$text" | awk "{ORS=(NR+1)%2==0?\"${green}\":RS}1" RS="\`" | awk "{ORS=NR%1==0?\"${normal}\":RS}1" RS="\`" | tr -d '\n')

  echo -e "$with_code_parsed"
}

output::write() {
  local -r text="${1:-}"

  with_code_parsed=$(_output::parse_code "$text")

  echo -e "$with_code_parsed"
}
output::answer() { output::write " > $1"; }
output::error() { output::answer "${red}$1${normal}"; }
output::solution() { output::answer "${green}$1${normal}"; }
output::question() {
  with_code_parsed=$(_output::parse_code "$1")

  if [ "${DOTLY_ENV:-PROD}" == "CI" ]; then
    echo "y" | read -rp "🤔 $with_code_parsed: " "$2"
  else
    read -rp "🤔 $with_code_parsed: " "$2"
  fi
}

output::answer_is_yes() {
  if [[ "${1:-Y}" =~ ^[Yy] ]] || [ "${DOTLY_ENV:-PROD}" == "CI" ]; then
    return 0
  fi

  return 1
}

output::empty_line() { echo ''; }

output::header() {
  output::empty_line
  output::write "${bold_blue}---- $1 ----${normal}"
}
output::h1_without_margin() { output::write "${bold_blue}# $1${normal}"; }
output::h1() {
  output::empty_line
  output::h1_without_margin "$1"
}
output::h2() {
  output::empty_line
  output::write "${bold_blue}## $1${normal}"
}
output::h3() {
  output::empty_line
  output::write "${bold_blue}### $1${normal}"
}
