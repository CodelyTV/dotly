#!/usr/bin/env bash

json::to_yaml() {
  if [[ -t 0 ]]; then
    [[ -f "${1:-}" ]] && yq e -P - <"$1"
  else
    yq e -P - </dev/stdin
  fi
}
