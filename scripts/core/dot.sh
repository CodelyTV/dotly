#!/usr/bin/env bash

dot::list_contexts() {
  dotly_contexts=$(ls "$DOTLY_PATH/scripts")
  dotfiles_contexts=$(ls "$DOTFILES_PATH/scripts")

  echo "$dotly_contexts" "$dotfiles_contexts" | grep -v core | sort -u
}

dot::list_context_scripts() {
  context="$1"

  dotly_scripts=$(ls -p "$DOTLY_PATH/scripts/$context" 2>/dev/null | grep -v '/')
  dotfiles_scripts=$(ls -p "$DOTFILES_PATH/scripts/$context" 2>/dev/null | grep -v '/')

  echo "$dotly_scripts" "$dotfiles_scripts" | sort -u
}

dot::list_scripts() {
  _list_scripts() {
    scripts=$(dot::list_context_scripts "$1" | xargs -I_ echo "dot $1 _")

    echo "$scripts"
  }

  dot::list_contexts | coll::map _list_scripts
}

dot::list_scripts_path() {
  dotly_contexts=$(find "$DOTLY_PATH/scripts" -maxdepth 2 -perm /+111 -type f | grep -v "$DOTLY_PATH/scripts/core")
  dotfiles_contexts=$(find "$DOTFILES_PATH/scripts" -maxdepth 2 -perm /+111 -type f)

  printf "%s\n%s" "$dotly_contexts" "$dotfiles_contexts" | sort -u
}

dot::get_script_path() {
  echo "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
}

dot::get_full_script_path() {
  echo "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename "$0")"
}

dot::get_script_src_path() {
  local lib lib_path lib_paths lib_full_path
  lib="${1:-}"

  if [[ -n "${lib:-}" ]]; then
    lib_paths=(
      "$DOTLY_PATH/scripts/core"
      "${2:-$(dot::get_script_path)}/src"
      "${2:-$(dot::get_script_path)}"
    )

    for lib_path in "${lib_paths[@]}"; do
      [[ -f "$lib_path/$lib" ]] &&\
        lib_full_path="$lib_path/$lib" &&\
        break

      [[ -f "$lib_path/$lib.sh" ]] &&\
        lib_full_path="$lib_path/$lib" &&\
        break
    done
  fi

  # Library loading
  if [[ -n "$lib" ]] && [[ -f "$lib_full_path" ]]; then
    . "$lib_full_path"
  else
    output::error "🚨 Library loading error with: \"${lib:-No library provided}\""
    exit 1
  fi
}
