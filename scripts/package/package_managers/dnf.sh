#!/usr/bin/env bash

dnf::install() {
  sudo dnf -y install "$@"
}

dnf::is_installed() {
  local package
  if [[ $# -gt 1 ]]; then
    for package in "$@"; do
      if ! rpm -qa | grep -qw "$package"; then
        return 1
      fi
    done
    
    return 0
  else
    [[ -n "${1:-}" ]] && rpm -qa | grep -qw "${1:-}"
  fi
}
