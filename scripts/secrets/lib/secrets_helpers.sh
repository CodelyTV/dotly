#!/usr/bin/env bash

source "$DOTLY_PATH/scripts/secrets/lib/install_needed_soft_and_vars.sh"
source "$DOTLY_PATH/scripts/secrets/lib/secrets_json.sh"

secrets::remove_file() {
  local start_dir
  start_dir="$(pwd)"
  cd "$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH" || return 1
  git filter-branch --index-filter 'git rm -f --ignore-unmatch $(realpath --relative-to="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH" "$1")' HEAD
  cd "$start_dir" || return
}
