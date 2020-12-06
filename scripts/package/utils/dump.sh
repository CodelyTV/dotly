#!/bin/user/env bash

HOMEBREW_DUMP_FILE_PATH="$DOTFILES_PATH/os/mac/brew/Brewfile"
PYTHON_DUMP_FILE_PATH="$DOTFILES_PATH/langs/python/requirements.txt"
NPM_DUMP_FILE_PATH="$DOTFILES_PATH/langs/js/global_modules.txt"

package::dump_brew() {
  mkdir -p "$DOTFILES_PATH/os/mac/brew"

  brew bundle dump --file="$HOMEBREW_DUMP_FILE_PATH" --force
}

package::dump_python() {
  mkdir -p "$DOTFILES_PATH/langs/python"

  pip freeze >"$PYTHON_DUMP_FILE_PATH"
}

package::dump_npm() {
  mkdir -p "$DOTFILES_PATH/langs/js"

  ls -1 /usr/local/lib/node_modules | grep -v npm >"$NPM_DUMP_FILE_PATH"
}
