rust::install() {
      log::append "Trying to install rust"

  platform::command_exists brew && brew install rust 2>&1 | log::file "Installing build-essential" && return 0 || true

      log::append "rust not in brew"

  if platform::command_exists apt; then
          log::append "build essentials"
    sudo apt install -y build-essential 2>&1 | log::file "Installing apt build-essential"
  fi

      log::append "rust from sources"

  curl https://sh.rustup.rs -sSf | sh -s -- -y 2>&1 | log::file "Installing rust from sources"

  export PATH="$HOME/.cargo/bin:$PATH"
}
