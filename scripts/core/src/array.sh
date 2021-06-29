#!/usr/bin/env bash

# Usage: array::* "${arr1[@]}" "${arr2[@]}"
array::union() { echo "${@}" | tr ' ' '\n' | sort | uniq; }
array::disjunction() { echo "${@}" | tr ' ' '\n' | sort | uniq -u; }
array::difference() { echo "${@}" | tr ' ' '\n' | sort | uniq -d; }
array::exists_value() {
  local value array_value
  value="${1:-}"
  shift

  for array_value in "$@"; do
    [[ "$array_value" == "$value" ]] && return 0
  done

  return 1
}
