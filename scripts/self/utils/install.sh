#!/bin/user/env bash

install_macos_custom() {
  if ! platform::command_exists brew; then
    output::error "brew not installed, installing"
    CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1
  fi

  # Install needed packages
  export PATH="$PATH:/usr/local/bin"
  mkdir -p "$HOME/bin"

  output::answer "Installing needed gnu packages"
  brew install bash >/dev/null 2>&1
  brew install coreutils >/dev/null 2>&1
  brew install make >/dev/null 2>&1
  brew install gnu-sed >/dev/null 2>&1
  brew install findutils >/dev/null 2>&1
  brew install bat >/dev/null 2>&1
  brew install hyperfine >/dev/null 2>&1

  output::answer "Installing mas"
  brew install mas >/dev/null 2>&1
}

install_linux_custom() {
  echo
}
