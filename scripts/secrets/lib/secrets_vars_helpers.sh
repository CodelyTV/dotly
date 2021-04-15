#!/usr/bin/env bash

source "$DOTLY_PATH/scripts/secrets/lib/install_needed_soft_and_vars.sh"
source "$DOTLY_PATH/scripts/secrets/lib/secrets_helpers.sh"

secrets::get_bash_script_all_variables_name() {
  [[ -e "$1" ]] && awk '/[A-Za-z0-9]+=/ { gsub(/=.*/,"",$0); print $NF; }' "$1"
}

secrets::var_exists() {
  local var_path
  var_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/vars"
  [[ -n "$1" ]] && [[ -e "$var_path/$1" ]] && echo "$var_path/$1"
}

secrets::var() {
  local var_path var_name
  var_name="$1"; shift
  var_path="$(secrets::var_exists "$var_name")"
  value="${*:-}"

  if [[ -n "$value" ]]; then
    rm -f "$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/vars/$var_name"
    touch "$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/vars/$var_name"
    echo "$value" > "$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/vars/$var_name"
  elif [[ -n "$var_path" ]]; then
    cat "$var_path"
  fi
}

secrets::var_delete() {
  local var_path
  var_path="$(secrets::var_exists "$1")"; shift
  [[ -n "$var_path" ]] && secrets::remove_file "$var_path"
}