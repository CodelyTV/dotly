#!/bin/user/env bash

apt_title='@ APT'
brew_title='🍺 Brew'
pip_title='🐍 pip'
npm_title='🌈 npm'
volta_title='⚡︎⚔️ volta'
snap_title='Snap'
cargo_title='📦 cargo'

package::clarification() {
  output::clarification "${1:-} could not be updated. Use \`dot self debug\` to view more details."
}

package::exists_dump_current_machine_file() {
  local FILES_PATH
  FILES_PATH="$(realpath -sm "$1")"

  ls -1 -d "$FILES_PATH"/* 2>/dev/null | grep -v ".lock.json$" | grep "$(hostname -s)"
}

package::preview() {
  local filename="$1"
  local FILES_PATH
  FILES_PATH="$(realpath -sm $2)"

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

package::common_dump_check() {
  local command_check file_path
  command_check="${1:-}"
  file_path="${2:-}"

  if [[ -n "${command_check:-}" ]] &&
      [[ -n "$file_path" ]] &&
      platform::command_exists "$command_check"
  then
    mkdir -p "$(dirname "$file_path")"
  fi
}

package::common_import_check() {
  local command_check file_path
  command_check="${1:-}"
  file_path="${2:-}"

  [[ -n "${command_check:-}" ]] &&\
    [[ -n "$file_path" ]] &&\
    platform::command_exists "$command_check" &&\
    [[ -f "$file_path" ]]
}

package::brew_dump() {
  HOMEBREW_DUMP_FILE_PATH="${1:-$HOMEBREW_DUMP_FILE_PATH}"

  if package::common_dump_check brew "$HOMEBREW_DUMP_FILE_PATH"; then
    output::write "🚀 Starting Brew dump to '$HOMEBREW_DUMP_FILE_PATH'"

    brew bundle dump --file="$HOMEBREW_DUMP_FILE_PATH" --force | log::file "Exporting $brew_title packages list"
    brew bundle --file="$HOMEBREW_DUMP_FILE_PATH" --force cleanup || true

    return 0
  fi

  return 1
}

package::brew_import() {
  HOMEBREW_DUMP_FILE_PATH="${1:-$HOMEBREW_DUMP_FILE_PATH}"

  if package::common_import_check brew "$HOMEBREW_DUMP_FILE_PATH"; then
    output::write "🚀 Importing 🍺 brew from '$HOMEBREW_DUMP_FILE_PATH'"
    brew bundle install --file="$HOMEBREW_DUMP_FILE_PATH" | log::file "Importing $brew_title packages list"

    return 0
  fi

  return 1
}

package::apt_dump() {
  APT_DUMP_FILE_PATH="${1:-$APT_DUMP_FILE_PATH}"

  if package::common_dump_check apt "$APT_DUMP_FILE_PATH"; then
    output::write "🚀 Starting APT dump to '$APT_DUMP_FILE_PATH'"
    apt-mark showmanual >|"$APT_DUMP_FILE_PATH" | log::file "Exporting $apt_title packages list"

    return 0
  fi

  return 1
}

package::apt_import() {
  APT_DUMP_FILE_PATH="${1:-$APT_DUMP_FILE_PATH}"

  if package::common_import_check apt "$APT_DUMP_FILE_PATH"; then
    output::write "🚀 Importing APT from '$HOMEBREW_DUMP_FILE_PATH'"
    xargs sudo apt-get install -y <"$APT_DUMP_FILE_PATH" | log::file "Importing $apt_title packages list"
  fi
}

package::snap_dump() {
  SNAP_DUMP_FILE_PATH="${1:-$SNAP_DUMP_FILE_PATH}"

  if package::common_dump_check snap "$SNAP_DUMP_FILE_PATH"; then
    output::write "🚀 Starting SNAP dump to '$SNAP_DUMP_FILE_PATH'"
    snap list | tail -n +2 | awk '{ print $1 }' >|"$SNAP_DUMP_FILE_PATH" | log::file "Exporting $snap_title containers list"

    return 0
  fi

  return 1
}

package::snap_import() {
  SNAP_DUMP_FILE_PATH="${1:-$SNAP_DUMP_FILE_PATH}"

  if package::common_import_check snap "$SNAP_DUMP_FILE_PATH"; then
    output::write "🚀 Importing SNAP from '$HOMEBREW_DUMP_FILE_PATH'"
    xargs -I_ sudo snap install "_" <"$SNAP_DUMP_FILE_PATH" | log::file "Importing $snap_title containers list"
  fi
}

package::python_dump() {
  PYTHON_DUMP_FILE_PATH="${1:-$PYTHON_DUMP_FILE_PATH}"

  if package::common_dump_check pip3 "$PYTHON_DUMP_FILE_PATH"; then
    output::write "🚀 Starting Python dump to '$PYTHON_DUMP_FILE_PATH'"
    pip3 freeze >"$PYTHON_DUMP_FILE_PATH" | log::file "Exporting $pip_title packages list"

    return 0
  fi

  return 1
}

package::python_import() {
  PYTHON_DUMP_FILE_PATH="${1:-$PYTHON_DUMP_FILE_PATH}"

  if package::common_import_check pip3 "$PYTHON_DUMP_FILE_PATH"; then
    output::write "🚀 Importing Python packages from '$PYTHON_DUMP_FILE_PATH'" | log::file "Importing $pip_title packages list"
    pip3 install -r "$PYTHON_DUMP_FILE_PATH"

    return 0
  fi

  return 1
}

package::npm_dump() {
  NPM_DUMP_FILE_PATH="${1:-$NPM_DUMP_FILE_PATH}"

  if package::common_dump_check npm "$NPM_DUMP_FILE_PATH"; then
    output::write "🚀 Starting NPM dump to '$NPM_DUMP_FILE_PATH'"
    ls -1 /usr/local/lib/node_modules | grep -v npm >|"$NPM_DUMP_FILE_PATH" | log::file "Exporting $npm_title packages list"

    return 0
  fi

  return 1
}

package::npm_import() {
  NPM_DUMP_FILE_PATH="${1:-$NPM_DUMP_FILE_PATH}"

  if package::common_import_check npm "$NPM_DUMP_FILE_PATH"; then
    output::write "🚀 Importing NPM packages from '$NPM_DUMP_FILE_PATH'"
    xargs -I_ npm install -g "_" < "$NPM_DUMP_FILE_PATH" | log::file "Importing $npm_title packages list"
  fi

  return 1
}

package::volta_dump() {
  VOLTA_DUMP_FILE_PATH="${1:-$VOLTA_DUMP_FILE_PATH}"

  if package::common_dump_check volta "$VOLTA_DUMP_FILE_PATH"; then
    output::write "🚀 Starting VOLTA packages from '$VOLTA_DUMP_FILE_PATH'"
    volta list all --format plain | awk '{print $2}' >|"$VOLTA_DUMP_FILE_PATH" | log::file "Exporting $volta_title packages list"

    return 0
  fi

  return 1
}

package::volta_import() {
  VOLTA_DUMP_FILE_PATH="${1:-$VOLTA_DUMP_FILE_PATH}"

  if package::common_import_check volta "$VOLTA_DUMP_FILE_PATH"; then
    output::write "🚀 Importing VOLTA packages from '$VOLTA_DUMP_FILE_PATH'"
    xargs -I_ volta install "_" <"$VOLTA_DUMP_FILE_PATH" | log::file "Importing ⚡︎⚔️ volta packages list"

    return 0
  fi

  return 1
}
