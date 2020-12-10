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
  brew list bash || brew install bash >/dev/null
  brew list coreutils || brew install coreutils >/dev/null
  brew list make || brew install make >/dev/null
  brew list gnu-sed || brew install gnu-sed >/dev/null
  brew list findutils || brew install findutils >/dev/null
  brew list bat || brew install bat >/dev/null
  brew list hyperfine || brew install hyperfine >/dev/null

  output::answer "Installing mas"
  brew list mas || brew install mas >/dev/null
}

install_linux_custom() {
  echo
}
