#!/usr/bin/env bash

files::check_if_path_is_older() {
  local path_to_check number_of period
  path_to_check="$1"
  number_of="${2:-0}"
  period="${3:-days}"
  [[ -e "$path_to_check" ]] && [[ $(date -r "$path_to_check" +%s) -lt $(date -d "now - $number_of $period" +%s) ]]
}

files::are_equal() {
  local file1 file2
  file1="${1:-}"
  file2="${2:-}"
  cmp --silent "$file1" "$file2"
}