#!/usr/bin/env bash

# Stuff we want to execute just once
if ! ${DOTLY_SECRETS_MODULE_PATH:-false}; then
  readonly DOTLY_SECRETS_MODULE_PATH="modules/secrets"

  if ! platform::command_exists yq; then
    output::error "The command yq version 4 is needed, try by executing:"
    output::answer "$DOTLY_PATH/bin/dot" package install yq
    output::empty_line
    output::yesno "Do you want to execute now and continue" &&\
      "$DOTLY_PATH/bin/dot" package install yq || exit 1
    output::empty_line
  elif [[ $(platform::semver_compare 4.0.0 "$(yq --version | awk '{print $3}')") -gt 0 ]]; then
    output::error "Wrong 'yq' version: There is needed at least version 4.0.0"
    exit 1
  fi

  if [[ ! -f "$DOTFILES_PATH/shell/zsh/completions/_yq" ]]; then
    yq shell-completion zsh > "$DOTFILES_PATH/shell/zsh/completions/_yq"
    "$DOTLY_PATH/bin/dot" shell zsh reload_completions
  fi

  if [[ ! -f "$DOTFILES_PATH/shell/bash/completions/_yq" ]]; then
    yq shell-completion bash > "$DOTFILES_PATH/shell/bash/completions/_yq"
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
    echo "$value" > "$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/vars/$var_name"
  elif [[ -n "$var_path" ]]; then
    cat "$var_path"
  fi
}

secrets::var_delete() {
  local var_path
  var_path="$(secrets::var_exists "$1")"; shift
  [[ -n "$var_path" ]] && rm -f "$var_path"
}

secrets::apply() {
  local file_path
  file_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/symlinks/secrets.json"
  if [[ -f "$file_path" ]]; then
    echo
    "$DOTLY_PATH/modules/dotbot/bin/dotbot" -d "$DOTFILES_PATH" -c "$file_path" "$@"
    echo
  fi
}

secrets::relative_path() {
  local item
  item="$(realpath -q -m "$1")"
  item="${item//$DOTFILES_PATH\//}"
  echo "${item//$HOME/\~}"
}

secrets::revert() {
  local file_path item start_dir
  file_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/symlinks/secrets.json"
  
  start_dir="$(pwd)"
  cd "$DOTFILES_PATH" || return 1

  if [[ -f "$file_path" ]]; then
    jq -r '.[] | select( .link != null) | .link | keys[]' "$file_path" |\
      while read -r item; do
        [ "shell/init-scripts/secrets_autoload" == "$item" ] && continue
        output::answer "Remove symlink: $item"
        eval rm -f "$item"
      done
  fi

  cd "$start_dir" || return
}

secrets::store() {
  local secret_files_path item_symlink_path secret_link secrets_yaml
  item_symlink_path="$(secrets::relative_path "$1")"
  secrets_yaml="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/symlinks/secrets.yaml"

  if [[ -z "${2:-}" ]]; then
    secret_files_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/files"
    secret_link="\$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/files/$(basename "$1")"
  else
    secret_files_path="$secret_files_path/$2"
    secret_link="\$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/files/$2/$(basename "$1")"
  fi

  if [[ -d "$secret_files_path/$(basename "$1")" ]]; then
    output::error "Already exists a file with this name, try adding a different secrets relative path"
    return 1
  fi

  output::answer "Moving the file to your secrets path"
  #mv "$1" "$secret_files_path/"

  output::answer "Linking your file"
  #eval ln -s "$secret_files_path/$(basename "$item_symlink_path")" "$item_symlink_path"

  # Add to yaml secrets file
  #TODO Test and if it fails fix this when link is not the firs element, we need to search firs wich is the good one to modify
  #yq --yaml-output -r "select(.[].link != null) .[].link += {\"$item_symlink_path\": \"$secret_link\"}" "$secrets_yaml" > "$secrets_yaml.tmp"
  yq ". | select(.[].link != null)" "$secrets_yaml"
  #yq ".[] | select(.link != null) .link += {\"$item_symlink_path\": \"$secret_link\"}" "$secrets_yaml"
  #rm -f "$secrets_yaml"
  #mv "$secrets_yaml.tmp" "$secrets_yaml"
}