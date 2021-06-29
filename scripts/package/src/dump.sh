#!/usr/bin/env bash
#. "$DOTLY_PATH/scripts/core/platform.sh"

apt_title='@ APT'
cargo_title='📦 Cargo'
brew_title='🍺 Brew'
pip_title='🐍 pip'
npm_title='🌈 npm'
volta_title='⚡︎⚔️ volta'
snap_title='Snap'

package::clarification() {
  output::write "${1:-} could not be updated. Use \`dot self debug\` to view more details."
}

package::exists_dump_current_machine_file() {
  local FILES_PATH
  FILES_PATH="$(realpath -sm "${1:-}")"

  find "$FILES_PATH" -name "*" -not -iname "*lock*" -not -iname ".*" -print0 2>/dev/null | xargs -0 -I _ basename _ | grep -Ei "^$(hostname -s)(.txt|.json)?$" | head -n 1
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

  #shellcheck disable=SC2207
  files=($(find "$FILES_PATH" -not -iname ".*" -maxdepth 1 -type f,l -print0 -exec echo {} \; 2>/dev/null | xargs basename | sort -u))

  if [[ -d "$FILES_PATH" && ${#files[@]} -gt 0 ]]; then
    answer="$(printf "%s\n" "${files[@]}" | fzf -0 --filepath-word -d ',' --prompt "$(hostname -s) > " --header "$header" --preview "[[ -f $FILES_PATH/{} ]] && cat $FILES_PATH/{} || echo No import a file for this package manager")"
    [[ -f "$FILES_PATH/$answer" ]] && answer="$FILES_PATH/$answer" || answer=""
  fi
  eval "$var_name=${answer:-}"
}

package::common_dump_check() {
  local command_check file_path
  command_check="${1:-}"
  file_path="${2:-}"

  if [[ -n "${command_check:-}" ]] &&
    [[ -n "$file_path" ]] &&
    platform::command_exists "$command_check"; then
    mkdir -p "$(dirname "$file_path")"
  fi
}

package::common_import_check() {
  local command_check file_path
  command_check="${1:-}"
  file_path="${2:-}"

  [[ -n "${command_check:-}" ]] &&
    [[ -n "$file_path" ]] &&
    platform::command_exists "$command_check" &&
    [[ -f "$file_path" ]]
}

package::brew_dump() {
  HOMEBREW_DUMP_FILE_PATH="${1:-$HOMEBREW_DUMP_FILE_PATH}"

  if package::common_dump_check brew "$HOMEBREW_DUMP_FILE_PATH"; then
    output::write "🚀 Starting Brew dump to '$HOMEBREW_DUMP_FILE_PATH'"

    brew bundle dump --file="$HOMEBREW_DUMP_FILE_PATH" --force | log::file "Exporting $brew_title packages"
    brew bundle --file="$HOMEBREW_DUMP_FILE_PATH" --force cleanup || true

    return 0
  fi

  return 1
}

package::brew_import() {
  HOMEBREW_DUMP_FILE_PATH="${1:-$HOMEBREW_DUMP_FILE_PATH}"

  if package::common_import_check brew "$HOMEBREW_DUMP_FILE_PATH"; then
    output::write "🚀 Importing 🍺 brew from '$HOMEBREW_DUMP_FILE_PATH'"
    brew bundle install --file="$HOMEBREW_DUMP_FILE_PATH" | log::file "Importing $brew_title packages"

    return 0
  fi

  return 1
}

package::apt_dump() {
  APT_DUMP_FILE_PATH="${1:-$APT_DUMP_FILE_PATH}"

  if package::common_dump_check apt "$APT_DUMP_FILE_PATH"; then
    output::write "🚀 Starting APT dump to '$APT_DUMP_FILE_PATH'"
    apt-mark showmanual | tee "$APT_DUMP_FILE_PATH" | log::file "Exporting $apt_title packages"

    return 0
  fi

  return 1
}

package::apt_import() {
  APT_DUMP_FILE_PATH="${1:-$APT_DUMP_FILE_PATH}"

  if package::common_import_check apt "$APT_DUMP_FILE_PATH"; then
    output::write "🚀 Importing APT from '$HOMEBREW_DUMP_FILE_PATH'"
    xargs sudo apt-get install -y <"$APT_DUMP_FILE_PATH" | log::file "Importing $apt_title packages"
  fi
}

package::snap_dump() {
  SNAP_DUMP_FILE_PATH="${1:-$SNAP_DUMP_FILE_PATH}"

  if package::common_dump_check snap "$SNAP_DUMP_FILE_PATH"; then
    output::write "🚀 Starting SNAP dump to '$SNAP_DUMP_FILE_PATH'"
    snap list | tail -n +2 | awk '{ print $1 }' | tee "$SNAP_DUMP_FILE_PATH" | log::file "Exporting $snap_title containers"

    return 0
  fi

  return 1
}

package::snap_import() {
  SNAP_DUMP_FILE_PATH="${1:-$SNAP_DUMP_FILE_PATH}"

  if package::common_import_check snap "$SNAP_DUMP_FILE_PATH"; then
    output::write "🚀 Importing SNAP from '$HOMEBREW_DUMP_FILE_PATH'"
    xargs -I_ sudo snap install "_" <"$SNAP_DUMP_FILE_PATH" | log::file "Importing $snap_title containers"
  fi
}

package::python_dump() {
  PYTHON_DUMP_FILE_PATH="${1:-$PYTHON_DUMP_FILE_PATH}"

  if package::common_dump_check pip3 "$PYTHON_DUMP_FILE_PATH"; then
    output::write "🚀 Starting Python dump to '$PYTHON_DUMP_FILE_PATH'"
    pip3 freeze | tee "$PYTHON_DUMP_FILE_PATH" | log::file "Exporting $pip_title packages"

    return 0
  fi

  return 1
}

package::python_import() {
  PYTHON_DUMP_FILE_PATH="${1:-$PYTHON_DUMP_FILE_PATH}"

  if package::common_import_check pip3 "$PYTHON_DUMP_FILE_PATH"; then
    output::write "🚀 Importing Python packages from '$PYTHON_DUMP_FILE_PATH'" | log::file "Importing $pip_title packages"
    pip3 install -r "$PYTHON_DUMP_FILE_PATH"

    return 0
  fi

  return 1
}

package::npm_dump() {
  NPM_DUMP_FILE_PATH="${1:-$NPM_DUMP_FILE_PATH}"

  if package::common_dump_check npm "$NPM_DUMP_FILE_PATH"; then
    output::write "🚀 Starting NPM dump to '$NPM_DUMP_FILE_PATH'"
    ls -1 /usr/local/lib/node_modules | grep -v npm | tee "$NPM_DUMP_FILE_PATH" | log::file "Exporting $npm_title packages"

    return 0
  fi

  return 1
}

package::npm_import() {
  NPM_DUMP_FILE_PATH="${1:-$NPM_DUMP_FILE_PATH}"

  if package::common_import_check npm "$NPM_DUMP_FILE_PATH"; then
    output::write "🚀 Importing NPM packages from '$NPM_DUMP_FILE_PATH'"
    xargs -I_ npm install -g "_" <"$NPM_DUMP_FILE_PATH" | log::file "Importing $npm_title packages"
  fi

  return 1
}

package::volta_dump() {
  VOLTA_DUMP_FILE_PATH="${1:-$VOLTA_DUMP_FILE_PATH}"

  if package::common_dump_check volta "$VOLTA_DUMP_FILE_PATH"; then
    output::write "🚀 Starting VOLTA packages from '$VOLTA_DUMP_FILE_PATH'"
    volta list all --format plain | awk '{print $2}' | tee "$VOLTA_DUMP_FILE_PATH" | log::file "Exporting $volta_title packages"

    return 0
  fi

  return 1
}

package::volta_import() {
  VOLTA_DUMP_FILE_PATH="${1:-$VOLTA_DUMP_FILE_PATH}"

  if package::common_import_check volta "$VOLTA_DUMP_FILE_PATH"; then
    output::write "🚀 Importing VOLTA packages from '$VOLTA_DUMP_FILE_PATH'"
    xargs -I_ volta install "_" <"$VOLTA_DUMP_FILE_PATH" | log::file "Importing $volta_title packages"

    return 0
  fi

  return 1
}

package::cargo_dump() {
  CARGO_DUMP_FILE_PATH="${1:-$CARGO_DUMP_FILE_PATH}"

  if package::common_dump_check cargo "$CARGO_DUMP_FILE_PATH"; then
    cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ' | tee "$CARGO_DUMP_FILE_PATH" | log::file "Exporting $cargo_title packages"

    return 0
  fi

  return 1
}

package::cargo_import() {
  CARGO_DUMP_FILE_PATH="${1:-$VOLTA_DUMP_FILE_PATH}"

  if package::common_import_check cargo "$CARGO_DUMP_FILE_PATH"; then
    xargs -I_ cargo install <"$CARGO_DUMP_FILE_PATH" | log::file "Importing $cargo_title packages"

    return 0
  fi

  return 1
}
