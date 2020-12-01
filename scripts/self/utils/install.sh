#!/bin/user/env bash

install_macos_custom() {
  # Install brew if not installed
  if ! [ -x "$(command -v brew)" ]; then
    CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Install needed packages
  export PATH="$PATH:/usr/local/bin"
  mkdir -p "$HOME/bin"

  brew install bash
  brew install coreutils
  brew install make
  brew install gnu-sed
  brew install findutils
  brew install bat
  brew install hyperfine
}

install_linux_custom() {
  echo
}
