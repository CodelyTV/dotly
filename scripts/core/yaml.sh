#!/usr/bin/env bash

yaml::to_json() {
  if [[ -t 0 ]]; then
    [[ -f "${1:-}" ]] && yq -j e '.' - <"$1"
  else
    yq -j e '.' - </dev/stdin
  fi
}

yq() {
  local yq_bin
  yq_bin="$(which yq)"
  if [[ -f "$yq_bin" ]]; then
    "$yq_bin" "$@"
    return $?
  fi

  if platform::command_exists docker; then
    docker run --rm -i -v "${PWD}":/workdir mikefarah/yq "$@"
    return $?
  fi
}
