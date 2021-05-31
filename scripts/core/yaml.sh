#!/usr/bin/env bash

yaml::to_json() {
  if [[ -t 0 ]]; then
    [[ -f "${1:-}" ]] && yq -r '.' - <"$1"
  else
    yq -r '.' </dev/stdin
  fi
}

yaml::is_valid() {
  local input
  if [[ -t 0 ]]; then
    [[ -n "${1:-}" && -f "$1" ]] && yq -e '.' "$1" &>/dev/null && ! json::is_json "$1"
  else
    input="$(</dev/stdin)"
    echo "$input" | yq -e '.' &>/dev/null && ! echo "$input" | json::is_json
  fi
}
