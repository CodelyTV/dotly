#!/usr/bin/env bash

pacman::install() {
  sudo pacman -S --noconfirm "$@"
}
