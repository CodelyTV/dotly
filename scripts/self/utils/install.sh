#!/bin/user/env bash

install_macos_custom() {
  if ! platform::command_exists brew; then
    output::error "brew not installed, installing"
    CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | log::file "Installing brew"
  fi

  # Install needed packages
  # @todo Check if it's inslled on an m1 machine and use the `/opt/homebrew/opt` path
  export PATH="$PATH:/usr/local/bin"
  mkdir -p "$HOME/bin"

  output::answer "Installing needed gnu packages"
  brew list bash || brew install bash | log::file "Installing brew bash"
  brew list coreutils || brew install coreutils | log::file "Installing brew coreutils"
  brew list make || brew install make | log::file "Installing brew make"
  brew list gnu-sed || brew install gnu-sed | log::file "Installing brew gnu-sed"
  brew list findutils || brew install findutils | log::file "Installing brew findutils"
  brew list bat || brew install bat | log::file "Installing brew bat"
  brew list hyperfine || brew install hyperfine | log::file "Installing brew hyperfine"

  output::answer "Installing mas"
  brew list mas || brew install mas | log::file "Installing mas"
}

install_linux_custom() {
  echo
}
