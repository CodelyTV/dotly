#!/usr/bin/env bash

package::command() {
  local package_manager
  local -r command="$1"
  local -r args=("${@:2}")

  # Package manager
  if platform::is_macos; then
    for package_manager in brew mas ports cargo none; do
      if platform::command_exists "$package_manager"; then
        break
      fi
    done
  else
    for package_manager in apt dnf yum brew pacman cargo none; do
      if platform::command_exists "$package_manager"; then
        break
      fi
    done
  fi

  if [[ "$package_manager" == "none" ]]; then
    return 1
  fi

  local -r package_managers_src="${DOTLY_PATH}/scripts/package/package_managers"
  local -r file="$package_manager.sh"

  dot::load_library "$file" "$package_managers_src"
  # If function does not exists for the package manager it will return 0 (true) always
  declare -F "$package_manager::$command" &>/dev/null && "$package_manager::$command" "${args[@]}" || return
}

package::is_installed() {
  [[ -z "${1:-}" ]] && return 1

  platform::command_exists "$1" ||\
    package::command is_installed "$1" ||\
    registry::is_installed "$1"
}
