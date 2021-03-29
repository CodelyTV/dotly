#!/usr/bin/env bash

str::split() {
  local -r text=$1
  local -r splitter=$2

  echo "$text" | tr "$splitter" "\n"
}

str::contains() {
  [[ $2 == *$1* ]]
}

str::to_upper() { echo "$@" | tr '[:lower:]' '[:upper:]'; }

# output::join: https://stackoverflow.com/a/17841619
str::join() { local glue="$1"; local first="$2"; shift 2; printf "%s" "$2" "${@/#/$glue}"; }