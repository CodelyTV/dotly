#!/bin/user/env bash

args::total_is() {
  total_expected="${1}"
  arguments="${@:2}"

  total_arguments=0
  for argument in ${arguments[*]}; do
    total_arguments=$((total_arguments + 1))
  done

  [[ $total_arguments -eq $total_expected ]]
}

args::has_no_args() {
  args::total_is 0 "$@"
}
