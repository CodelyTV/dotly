#!/usr/bin/env bash

# Stuff we want to execute just once
if ! ${DOTLY_SECRETS_MODULE_PATH:-false}; then
  readonly DOTLY_SECRETS_MODULE_PATH="modules/secrets"

  if ! platform::command_exists yq; then
    pip_cmd="$(which pip3)"
    [[ -z "$pip_cmd" ]] &&\
      output::error "Could not find pip3 to install 'yq' package." &&\
      exit 1
    
    $(which pip3) install yq
    unset pip_cmd
  fi
fi

secrets::check_exists() {
  [[ -d "$DOTLY_SECRETS_MODULE_PATH" ]]
}

secrets::check_remote_repository_exists() {
  git ls-remote "$1" >/dev/null 2>&1
}

secrets::get_bash_script_all_variables_name() {
  [[ -e "$1" ]] && awk '/[A-Za-z0-9]+=/ { gsub(/=.*/,"",$0); print $NF; }' "$1"
}

secrets::load_vars() {
  local vars_path
  vars_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/vars"
  find "$vars_path" -path "$vars_path/.*" -prune -o -name '*' -type f -print | while read -r item; do
    value="$(cat "$item")"
    echo "export $(basename "$item")=\"$(cat "$item")\""
    [[ -n "$value" ]] && eval export "$(basename "$item")=\"$(cat "$item")\""
    value=""
  done
}

secrets::hide_vars() {
  local vars_path
  vars_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/vars"
  find "$vars_path" -path "$vars_path/.*" -prune -o -name '*' -type f -print | while read -r item; do
    [[ -n "${!$(basename "$item")}" ]] && eval "export $(basename "$item")=\"****)\""
  done
}

secrets::unload_vars() {
  local vars_path
  vars_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/vars"
  find "$vars_path" -path "$vars_path/.*" -prune -o -name '*' -type f -print | while read -r item; do
    unset "$(basename "$item")"
  done
}

secrets::apply() {
  local file_path
  file_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/symlinks/secrets.yaml"
  if [[ -f "$file_path" ]]; then
    echo
    "$DOTLY_PATH/modules/dotbot/bin/dotbot" -d "$DOTFILES_PATH" -c "$file_path" "$@"
    echo
  fi
}