#!/usr/bin/env bash

files::check_if_path_is_older() {
  local path_to_check number_of period
  path_to_check="$1"
  number_of="${2:-0}"
  period="${3:-days}"
  [[ -e "$path_to_check" ]] && [[ $(date -r "$path_to_check" +%s) -lt $(date -d "now - $number_of $period" +%s) ]]
}

files::backup_if_file_exists() {
  local file_path bk_suffix bk_file_path
  file_path="$(eval realpath -q -m "${1:-}")"
  bk_suffix="${2:-$(date +%s)}"
  bk_file_path="$file_path.${bk_suffix}"

  if [[ -n "$file_path" ]] &&\
    { [[ -f "$file_path" ]] || [[ -d "$file_path" ]]; }
  then
    eval mv "$file_path" "$bk_file_path" && echo "$bk_file_path" && return 1
  fi

  return 0
}
