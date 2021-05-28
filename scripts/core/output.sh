#!/usr/bin/env bash

red='\033[0;31m'
green='\033[0;32m'
bold_blue='\033[1m\033[34m'
gray='\e[90m'
normal='\033[0m'

output::write() {
  local -r text="${1:-}"
  echo -e "$text"
}
output::answer() { output::write " > $1"; }
output::clarification() {
  with_code_parsed=$(echo "$1" | awk "{ORS=(NR+1)%2==0?\"${green}\":RS}1" RS="\`" | awk "{ORS=NR%1==0?\"${normal}\":RS}1" RS="\`" | tr -d '\n')
  output::write "$with_code_parsed"
}
output::error() { output::answer "${red}$1${normal}"; }
output::solution() { output::answer "${green}$1${normal}"; }
output::question() {
  if [ platform::is_macos ]; then
    output::answer "🤔 $1: "
    read -r "$2"
  else
    read -rp "🤔 $1: " "$2"
  fi
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
