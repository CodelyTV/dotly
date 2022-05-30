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
  brew list bash || brew install bash | log::file "Installing brew bash"
  brew list zsh || brew install zsh | log::file "Installing brew zsh"
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

backup_files() {
  backup_dir="$HOME/.pre_dotly_backup"
  mkdir -p "$backup_dir"

  for file_path in "$@"; do
    if [ -f "$file_path" ]; then
      filename="$(basename -- $file_path)"

      cp "$file_path" "$backup_dir/$filename"

      log::append "$backup_dir/$filename backed up"
    fi
  done
}
