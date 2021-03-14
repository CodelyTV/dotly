#!/bin/user/env bash

source "$DOTLY_PATH/scripts/core/platform.sh"


package::exists_dump_current_machine_file() {
  local FILES_PATH="$(realpath -sm $1)"

  ls -1 -d "$FILES_PATH"/* 2>/dev/null | grep -v ".lock.json$" | grep "$(hostname -s)"
}

package::which_file() {
  local FILES_PATH="$(realpath -sm $1)"
  local header="$2"
  local var_name="$3"
  local answer=""

  [[ -d "$FILES_PATH" ]] && answer="$FILES_PATH/$(ls -1 "$FILES_PATH/" 2>/dev/null | grep -v ".lock.json$" | sort -u | fzf -0 --filepath-word --prompt "$(hostname -s) > " --header "$header" --preview "cat $FILES_PATH/{}")"
  eval "$var_name=$answer"
}

package::brew_dump() {
  HOMEBREW_DUMP_FILE_PATH="${1:-$HOMEBREW_DUMP_FILE_PATH}"

  if platform::command_exists brew; then
    mkdir -p "$(dirname $HOMEBREW_DUMP_FILE_PATH)"

    output::write "🚀 Starting Brew dump to '$HOMEBREW_DUMP_FILE_PATH'"

    brew bundle dump --file="$HOMEBREW_DUMP_FILE_PATH" --force
    brew bundle --file="$HOMEBREW_DUMP_FILE_PATH" --force cleanup

    return 0
  fi

  return 1
}

package::brew_import() {
  HOMEBREW_DUMP_FILE_PATH="${1:-$HOMEBREW_DUMP_FILE_PATH}"

  if [ -f "$HOMEBREW_DUMP_FILE_PATH" ] && platform::command_exists brew; then
    output::write "🚀 Importing brew from '$HOMEBREW_DUMP_FILE_PATH'"
    brew bundle install --file="$HOMEBREW_DUMP_FILE_PATH"

    return 0
  fi

  return 1
}

package::python_dump() {
  PYTHON_DUMP_FILE_PATH="${1:-$PYTHON_DUMP_FILE_PATH}"

  if platform::command_exists python; then
    mkdir -p "$(dirname $PYTHON_DUMP_FILE_PATH)"
    output::write "🚀 Starting Python dump to '$PYTHON_DUMP_FILE_PATH'"
    pip3 freeze >"$PYTHON_DUMP_FILE_PATH"

    return 0
  fi

  return 1
}

package::python_import() {
  PYTHON_DUMP_FILE_PATH="${1:-$PYTHON_DUMP_FILE_PATH}"

  if [ -f "$PYTHON_DUMP_FILE_PATH" ] && platform::command_exists python; then
    output::write "🚀 Importing Python packages from '$PYTHON_DUMP_FILE_PATH'"
    pip3 install -r "$PYTHON_DUMP_FILE_PATH"

    return 0
  fi

  return 1
}

package::npm_dump() {
  NPM_DUMP_FILE_PATH="${1:-$NPM_DUMP_FILE_PATH}"

  if platform::command_exists npm; then
    mkdir -p "$(dirname $NPM_DUMP_FILE_PATH)"
    output::write "🚀 Starting NPM dump to '$PYTHON_DUMP_FILE_PATH'"
    ls -1 /usr/local/lib/node_modules | grep -v npm >"$NPM_DUMP_FILE_PATH"

    return 0
  fi

  return 1
}

package::npm_import() {
  NPM_DUMP_FILE_PATH="${1:-$NPM_DUMP_FILE_PATH}"

  if [ -f "$NPM_DUMP_FILE_PATH" ] && platform::command_exists npm; then
    output::write "🚀 Importing NPM packages from '$NPM_DUMP_FILE_PATH'"
    xargs -I_ npm install -g "_" <"$NPM_DUMP_FILE_PATH"
  fi

  return 1
}

package::volta_dump() {
  VOLTA_DUMP_FILE_PATH="${1:-$VOLTA_DUMP_FILE_PATH}"

  if platform::command_exists volta; then
    mkdir -p "$(dirname $VOLTA_DUMP_FILE_PATH)"
    output::write "🚀 Starting VOLTA packages from '$VOLTA_DUMP_FILE_PATH'"
    volta list all --format plain | awk '{print $2}' >"$VOLTA_DUMP_FILE_PATH"

    return 0
  fi

  return 1
}

package::volta_import() {
  VOLTA_DUMP_FILE_PATH="${1:-$VOLTA_DUMP_FILE_PATH}"

  if [ -f "$VOLTA_DUMP_FILE_PATH" ] && platform::command_exists volta; then
    output::write "🚀 Importing VOLTA packages from '$VOLTA_DUMP_FILE_PATH'"
    xargs -I_ volta install "_" <"$VOLTA_DUMP_FILE_PATH"

    return 0
  fi

  return 1
}
