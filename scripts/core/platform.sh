#!/usr/bin/env bash

platform::command_exists() {
  type "$1" >/dev/null 2>&1
}

platform::is_macos() {
  [[ $(uname -s) == "Darwin" ]]
}

platform::is_macos_arm() {
  [[ $(uname -p) == "arm" ]]
}

platform::is_linux() {
  [[ $(uname -s) == "Linux" ]]
}

platform::is_wsl() {
  grep -qEi "(Microsoft|WSL|microsoft)" /proc/version &> /dev/null
}

platform::wsl_home_path(){
  wslpath "$(wslvar USERPROFILE 2> /dev/null)"
}

platform::normalize_ver() {
  local version
  version="${1//./ }"
  echo "${version//v/}"
}

platform::compare_ver() {
  [[ $1 -lt $2 ]] && echo -1 && return
  [[ $1 -gt $2 ]] && echo 1 && return

  echo 0
}

# It does not support beta, rc and similar suffix
platform::semver_compare() {
  if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
    return 1
  fi

  v1="$(platform::normalize_ver "${1:-}")"
  v2="$(platform::normalize_ver "${2:-}")"

  major1="$(echo "$v1" | awk '{print $1}')"
  major2="$(echo "$v2" | awk '{print $1}')"

  minor1="$(echo "$v1" | awk '{print $2}')"
  minor2="$(echo "$v2" | awk '{print $2}')"

  patch1="$(echo "$v1" | awk '{print $3}')"
  patch2="$(echo "$v2" | awk '{print $3}')"

  compare_major="$(platform::compare_ver "$major1" "$major2")"
  compare_minor="$(platform::compare_ver "$minor1" "$minor2")"
  compare_patch="$(platform::compare_ver "$patch1" "$patch2")"

  if [[ $compare_major -ne 0 ]]; then
    echo "$compare_major"
  elif [[ $compare_minor -ne 0 ]]; then
    echo "$compare_minor"
  else
    echo "$compare_patch"
  fi
}

# It does not support beta, rc and similar suffix
# First argument is the current version to say if second argument is
# a version update that is no a major update
platform::semver_is_minor_or_patch_update() {
  v1="$(platform::normalize_ver "$1")"
  v2="$(platform::normalize_ver "$2")"

  major1="$(echo "$v1" | awk '{print $1}')"
  major2="$(echo "$v2" | awk '{print $1}')"

  minor1="$(echo "$v1" | awk '{print $2}')"
  minor2="$(echo "$v2" | awk '{print $2}')"

  patch1="$(echo "$v1" | awk '{print $3}')"
  patch2="$(echo "$v2" | awk '{print $3}')"

  compare_major="$(platform::compare_ver "$major1" "$major2")"
  compare_minor="$(platform::compare_ver "$minor1" "$minor2")"
  compare_patch="$(platform::compare_ver "$patch1" "$patch2")"

  [[ $compare_major -eq 0 ]] && { # Only equals major are minor or patch updates
    [[ $compare_minor -eq -1 ]] || { # If minor is over current minor is and update
      [[ $compare_minor -eq 0 ]] && [[ $compare_patch -eq -1 ]] # If minor is equal and patch is greater
    }
  }
}
