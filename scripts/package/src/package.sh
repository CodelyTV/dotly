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

  local -r file="$DOTLY_PATH/scripts/package/package_managers/$package_manager.sh"

  [[ ! -f "$file" ]] && exit 4
  . "$file"
  declare -F "$package_manager::$command" &>/dev/null && "$package_manager::$command" "${args[@]}"
}

package::is_installed() {
  package::command is_installed "$1" || platform::command_exists "$1"
}