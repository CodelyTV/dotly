#!/bin/user/env bash

HOMEBREW_DUMP_FILE_PATH="$DOTFILES_PATH/os/mac/brew/Brewfile"
PYTHON_DUMP_FILE_PATH="$DOTFILES_PATH/langs/python/requirements.txt"
NPM_DUMP_FILE_PATH="$DOTFILES_PATH/langs/js/global_modules.txt"

package::brew_dump() {
  mkdir -p "$DOTFILES_PATH/os/mac/brew"

  brew bundle dump --file="$HOMEBREW_DUMP_FILE_PATH" --force
}

package::brew_import() {
  if [ -f "$HOMEBREW_DUMP_FILE_PATH" ]; then
    brew bundle install --file="$HOMEBREW_DUMP_FILE_PATH"
  fi
}

package::python_dump() {
  mkdir -p "$DOTFILES_PATH/langs/python"

  pip3 freeze >"$PYTHON_DUMP_FILE_PATH"
}

package::python_import() {
  if [ -f "$PYTHON_DUMP_FILE_PATH" ]; then
    pip3 install -r "$PYTHON_DUMP_FILE_PATH"
  fi
}

package::npm_dump() {
  mkdir -p "$DOTFILES_PATH/langs/js"

  ls -1 /usr/local/lib/node_modules | grep -v npm >"$NPM_DUMP_FILE_PATH"
}

package::npm_import() {
  if [ -f "$NPM_DUMP_FILE_PATH" ]; then
    xargs -I_ npm install -g "_" <"$NPM_DUMP_FILE_PATH"
  fi
}
