#!/usr/bin/env bash

files::check_if_path_is_older() {
  local path number_of period
  path="$1"
  number_of="${2:-0}"
  period="${3:-days}"
  [[ -e "$path" ]] && [[ $(date -r "$1" +%s) -lt $(date -d "now - $number_of $period" +%s) ]]
}