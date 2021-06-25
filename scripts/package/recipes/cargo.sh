cargo::install() {
  platform::command_exists brew && brew install rust 2>&1 | log::file "Installing build-essential" && return 0 || true

  if platform::command_exists apt; then
    sudo apt install -y build-essential 2>&1 | log::file "Installing apt build-essential"
  fi

  curl https://sh.rustup.rs -sSf | sh -s -- -y 2>&1 | log::file "Installing rust from sources"

  export PATH="$HOME/.cargo/bin:$PATH"
  #shellcheck disable=SC1091
  . "$HOME/.cargo/env"
}

cargo::is_installed() {
  platform::command_exists cargo
}
