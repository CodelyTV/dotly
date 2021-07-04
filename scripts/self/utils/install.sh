#!/bin/user/env bash

install_macos_custom() {
  if ! platform::command_exists brew; then
    output::error "brew not installed, installing"

    if [ "$DOTLY_ENV" == "CI" ]; then
      export CI=1
    fi

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if platform::is_macos_arm; then
    export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
  else
    export PATH="$PATH:/usr/local/bin"
  fi

  mkdir -p "$HOME/bin"

  output::answer "Installing needed gnu packages"
  brew cleanup -s | log::file "Brew executing cleanup"
  brew cleanup --prune-prefix | log::file "Brew removeing dead symlinks"
  brew update | log::file "Brew update"
  brew list bash || brew install bash | log::file "Installing brew bash"
  brew list zsh || brew install zsh | log::file "Installing brew zsh"
  brew list coreutils || brew install coreutils | log::file "Installing brew coreutils"
  brew list findutils || brew install findutils | log::file "Installing brew findutils"
  brew list gnu-sed || brew install gnu-sed | log::file "Installing brew gnu-sed"
  brew list gawk || brew install gawk | log::file "Installing brew gawk"
  brew list grep || brew install grep | log::file "Installing brew grep"
  brew list make || brew install make | log::file "Installing brew make"
  brew list bat || brew install bat | log::file "Installing brew bat"
  brew list hyperfine || brew install hyperfine | log::file "Installing brew hyperfine"

  output::answer "Installing mas"
  brew list mas || brew install mas | log::file "Installing mas"
}

install_linux_custom() {
  echo
}
