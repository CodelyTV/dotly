#!/usr/bin/env bash

pacman::install() {
  if platform::command_exists yay; then
    sudo yay -S --noconfirm "$@"
  else
    sudo pacman -S --noconfirm "$@"
  fi
}

pacman::is_installed() {
  pacman -Qs "$@" | grep -q 'local'
}
