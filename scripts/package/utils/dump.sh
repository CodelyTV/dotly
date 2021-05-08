#!/bin/user/env bash

package::exists_dump_current_machine_file() {
  local FILES_PATH="$(realpath -sm $1)"

  ls -1 -d "$FILES_PATH"/* 2>/dev/null | grep -v ".lock.json$" | grep "$(hostname -s)"
}

package::preview() {
  local filename="$1"
  local FILES_PATH="$(realpath -sm $2)"

  if [ "$filename" == "No import" ]; then
    echo "No import any file for this package manager"
    return
  fi

  { [[ -f "$FILES_PATH/$filename" ]] && cat "$FILES_PATH/$filename"; } || "Could not find the file '$FILES_PATH/$filename'"
}

package::which_file() {
  local FILES_PATH header var_name answer files
  FILES_PATH="$(realpath -sm "$1")"
  header="$2"
  var_name="$3"

  files="$(ls -1 "$FILES_PATH/" 2>/dev/null | grep -v ".lock.json$" | sort -u | tr '\n' ',' && echo 'No import')"

  if [[ -d "$FILES_PATH" ]]; then
    answer="$(echo $files | tr ',' '\n' | fzf -0 --filepath-word -d ',' --prompt "$(hostname -s) > " --header "$header" --preview "[[ -f $FILES_PATH/{} ]] && cat $FILES_PATH/{} || echo No import a file for this package manager")"
    [[ -f "$FILES_PATH/$answer" ]] && answer="$FILES_PATH/$answer" || answer=""
  fi
  eval "$var_name=$answer"
}

package::brew_dump() {
  HOMEBREW_DUMP_FILE_PATH="${1:-$HOMEBREW_DUMP_FILE_PATH}"

  if platform::command_exists brew; then
    mkdir -p "$(dirname "$HOMEBREW_DUMP_FILE_PATH")"

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

package::apt_dump() {
  APT_DUMP_FILE_PATH="${1:-$APT_DUMP_FILE_PATH}"

  if platform::command_exists apt; then
    mkdir -p "$(dirname "$APT_DUMP_FILE_PATH")"

    output::write "🚀 Starting APT dump to '$APT_DUMP_FILE_PATH'"
    apt-mark showmanual >"$APT_DUMP_FILE_PATH"

    return 0
  fi

  return 1
}

package::apt_import() {
  APT_DUMP_FILE_PATH="${1:-$APT_DUMP_FILE_PATH}"

  if [ -f "$APT_DUMP_FILE_PATH" ] && platform::command_exists apt; then
    output::write "🚀 Importing APT from '$HOMEBREW_DUMP_FILE_PATH'"
    xargs sudo apt-get install -y <"$APT_DUMP_FILE_PATH"
  fi
}

package::snap_dump() {
  SNAP_DUMP_FILE_PATH="${1:-$SNAP_DUMP_FILE_PATH}"

  if platform::command_exists snap; then
    mkdir -p "$(dirname "$SNAP_DUMP_FILE_PATH")"

    output::write "🚀 Starting APT dump to '$SNAP_DUMP_FILE_PATH'"
    snap list | tail -n +2 | awk '{ print $1 }' >"$SNAP_DUMP_FILE_PATH"

    return 0
  fi

  return 1
}

package::snap_import() {
  SNAP_DUMP_FILE_PATH="${1:-$SNAP_DUMP_FILE_PATH}"

  if [ -f "$SNAP_DUMP_FILE_PATH" ] && platform::command_exists snap; then
    output::write "🚀 Importing SNAP from '$HOMEBREW_DUMP_FILE_PATH'"
    xargs -I_ sudo snap install "_" <"$SNAP_DUMP_FILE_PATH"
  fi
}

package::python_dump() {
  PYTHON_DUMP_FILE_PATH="${1:-$PYTHON_DUMP_FILE_PATH}"

  if platform::command_exists python; then
    mkdir -p "$(dirname "$PYTHON_DUMP_FILE_PATH")"
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
    xargs -I_ npm install -g "_" < "$NPM_DUMP_FILE_PATH"
  fi

  return 1
}

package::volta_dump() {
  VOLTA_DUMP_FILE_PATH="${1:-$VOLTA_DUMP_FILE_PATH}"

  if platform::command_exists volta; then
    mkdir -p "$(dirname "$VOLTA_DUMP_FILE_PATH")"
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
