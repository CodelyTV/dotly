#!/bin/user/env bash

install_macos_custom() {
  if ! platform::command_exists brew; then
    output::error "brew not installed, installing"
    CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 | log::file "Installing brew"
  fi

  if platform::is_macos_arm; then
    export PATH="$PATH:/opt/homebrew/opt:/usr/local/bin"
  else
    export PATH="$PATH:/usr/local/bin"
  fi

  mkdir -p "$HOME/bin"

  output::answer "Installing needed gnu packages"
  brew list bash || brew install bash | log::file "Installing brew bash"
  brew list zsh || brew install zsh | log::file "Installing brew zsh"
  brew list coreutils || brew install coreutils | log::file "Installing brew coreutils"
  brew list make || brew install make | log::file "Installing brew make"
  brew list gnu-sed || brew install gnu-sed | log::file "Installing brew gnu-sed"
  brew list findutils || brew install findutils | log::file "Installing brew findutils"
  brew list bat || brew install bat | log::file "Installing brew bat"
  brew list hyperfine || brew install hyperfine | log::file "Installing brew hyperfine"

  if ! platform::is_macos_arm; then
    output::answer "Installing mas"
    brew list mas || brew install mas | log::file "Installing mas"
  fi
}

install_linux_custom() {
  echo
}
