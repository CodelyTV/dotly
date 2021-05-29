#!/usr/bin/env bash

brew::install() {
  # Some aliases
  case "$1" in
  "docpars") package="denisidoro/tools/docpars" ;;
  *) package="$1" ;;
  esac

  brew install "$package"
}

brew::is_installed() {
  brew list "$@" &>/dev/null
}
