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

platform::semver_is_minor_patch_update() {
  normalize_ver() {
    echo "${${1//./ }//v/}"
  }

  compare_ver() {
    [[ $1 -lt $2 ]] && echo -1 && return
    [[ $1 -gt $2 ]] && echo 1 && return

    echo 0
  }

  v1="$(normalize_ver $1)"
  v2="$(normalize_ver $2)"

  major1="$(echo $v1 | awk '{print $1}')"
  major2="$(echo $v2 | awk '{print $1}')"

  minor1="$(echo $v1 | awk '{print $2}')"
  minor2="$(echo $v2 | awk '{print $2}')"

  patch1="$(echo $v1 | awk '{print $3}')"
  patch2="$(echo $v2 | awk '{print $3}')"

  compare_major="$(compare_ver $major1 $major2)"
  compare_minor="$(compare_ver $minor1 $minor2)"
  compare_patch="$(compare_ver $patch1 $patch2)"

  [[ $compare_major -eq 0 ]] && { [[ $compare_minor -ne 0 ]] || [[ $compare_patch -ne 0 ]]; }
}

platform::get_script_path() {
    echo "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
}

platform::get_full_script_path() {
    echo "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename $0)"
}