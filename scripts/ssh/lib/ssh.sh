#!/usr/bin/env bash

# For testing pourposes:
# alias load_ssh_lib='source $DOTLY_PATH/scripts/ssh/helpers/ssh.sh'
# source "$DOTLY_PATH/scripts/core/_main.sh"

# Some needed vars
DOTFILES_SSH_CONFIGD="${DOTFILES_SSH_CONFIGD:-$DOTFILES_PATH/ssh/config.d}"
DOTFILES_SSH_CONFIG_ENABLED="${DOTFILES_SSH_CONFIG_ENABLED:-"$DOTFILES_PATH/ssh/config.d-enabled"}"

ssh::get_alias() {
  local configuration
  configuration="${1:-$(</dev/stdin)}"
  [[ -f "$configuration" ]] && configuration="$(cat "$configuration")"
  echo "$configuration" | grep "^Host " | grep -v "*" | awk '{$1="";print $0;}' | tr "\n" " " | str::to_lower
}

ssh::get_all_alias() {
  cat "$(dirname "$DOTFILES_SSH_CONFIGD")/config" "$DOTFILES_SSH_CONFIGD/"* | ssh::get_alias
}


ssh::get_enabled_alias() {
  cat "$(dirname "$DOTFILES_SSH_CONFIGD")/config" "$DOTFILES_SSH_CONFIG_ENABLED/"* | ssh::get_alias
}

ssh::check_alias_exists() {
  local ssh_hosts ssh_alias
  ssh_hosts=$(ssh::get_all_alias)

  for ssh_alias in "$@"; do
    (echo "$ssh_hosts" | grep -qiwE "$ssh_alias") && return 0
  done

  return 1
}

ssh::check_enabled_alias() {
  (ssh::get_enabled_alias | grep -qiwE "$1") && return 0

  return 1
}

ssh::check_configd_file_name() {
  local ssh_file
  ssh_file="$DOTFILES_SSH_CONFIGD/$(basename "$1")"
  [[ -f "$ssh_file" ]] && echo "$ssh_file"
}

ssh::check_is_enabled_file_name() {
  [[ -n "$1" ]] &&\
    [[ -e "$DOTFILES_SSH_CONFIG_ENABLED/$(basename "$1")" ]] &&\
    echo "$DOTFILES_SSH_CONFIG_ENABLED/$(basename "$1")"
}

ssh::get_configd_file_by_alias() {
  local ssh_alias config_file check_config
  ssh_alias="$1"
  check_config=$(ssh::get_alias "$(dirname "$DOTFILES_SSH_CONFIGD")/config" | grep -q -wE "$ssh_alias")

  if [[ -n "$check_config" ]]; then
    echo "$(dirname "$DOTFILES_SSH_CONFIGD")/config"
    return 0
  fi

  find "$DOTFILES_SSH_CONFIGD" -name "*" -type f | while read -r config_file; do
    if ssh::get_alias "$config_file" | grep -qiwE "$ssh_alias"; then
      echo "$config_file"
      return 0
    fi
  done
  
  return 1
}

ssh::enable_by_configd_file() {
  local ssh_file
  ssh_file="$(ssh::check_configd_file_name "${1:-}")"

  # Required params
  [[ -z "$ssh_file" ]] && return 1

  ln -sf "$(realpath --relative-to "$DOTFILES_SSH_CONFIG_ENABLED" "$ssh_file")" "$DOTFILES_SSH_CONFIG_ENABLED"
}

ssh::disable_by_configd_file() {
  local ssh_file

  for ssh_link in "$@"; do
    ssh_link=""
    # Getting ssh file by inception: $($(^_^))
    ssh_link="$DOTFILES_SSH_CONFIG_ENABLED/$(basename "$(ssh::check_configd_file_name "${1:-}")")"
    [[ -e "$ssh_link" ]] && rm -f "$ssh_link"
  done
}

ssh::enable_by_alias() {
  local ssh_alias ssh_file
  [[ $# -eq 0 ]] && return 1

  for ssh_alias in "$@"; do
    ssh_file=""
    ssh_file="$(ssh::get_configd_file_by_alias "$ssh_alias")"
    [[ -n "$ssh_file" ]] && ssh::enable_by_configd_file "$ssh_file"
  done
}

ssh::disable_by_alias() {
  local ssh_file item_alias
  for item_alias in "$@"; do
    ssh_file="$(ssh::get_configd_file_by_alias "$item_alias")"
    ssh::disable_by_configd_file "$(basename "$ssh_file")"
  done
}

ssh::enable() {
  local item
  for item in $@; do
    if ssh::enable_by_alias "$item" || ssh::enable_by_configd_file "$item"; then
      output::solution "'$item' disabled."
    else
      output::error "'$item' could not be disabled."
    fi
  done
}

ssh::disable() {
  local item
  for item in $@; do
    if ssh::disable_by_alias "$item" || ssh::disable_by_configd_file "$item"; then
      output::solution "'$item' disabled."
    else
      output::error "'$item' could not be disabled."
    fi
  done
}

ssh::fzf() {
  fzf -m --extended\
    --header "Select ssh configuration file to ${1:-}"\
    --preview "bash -c '. \"$DOTLY_PATH/scripts/ssh/lib/ssh.sh\"; ssh::preview {}'"
}

ssh::preview() {
  local file
  file="$(ssh::check_configd_file_name "${1:-}")"

  # Preview header
  echo "Press Tab+Shift to select multiple options."
  echo "Press Ctrl+C to exit with no selection."
  echo
  
  [[ -z "$file" ]] && return
  if ssh::check_is_enabled_file_name "$file"; then
    file_name="$(basename "$file") (enabled)"
  else
    file_name="$(basename "$file") (diabled)"
  fi
  echo ">>> File: $file_name"
  echo
  cat "$file"
}

ssh::get_configd_fzf() {
  #basename "$(ls -d -1 "$DOTFILES_SSH_CONFIGD/"*)" | ssh::fzf "enable"
  find "$DOTFILES_SSH_CONFIGD" -name "*" -type f | xargs -I _ basename _ | ssh::fzf "enable"
}

ssh::get_enabled_fzf() {
  #basename "$(ls -d -1 "$DOTFILES_SSH_CONFIG_ENABLED/"*)" | ssh::fzf "disable"
  find "$DOTFILES_SSH_CONFIG_ENABLED" -name "*" -type l | xargs -I _ basename _ | ssh::fzf "disable"
}

ssh::new_ssh_config_from_tpl() {
  local ssh_aliases ssh_hostname ssh_user ssh_port output
  ssh_aliases="$1"
  ssh_hostname="$2"
  ssh_user="${3:-}"
  ssh_port="${4:-}"

  output=("Host $ssh_aliases")
  output+=("    Hostname $ssh_hostname")
  [[ -n "$ssh_user" ]] && output+=("    User $ssh_user")
  [[ -n "$ssh_port" ]] && output+=("    Port $ssh_port")
  printf "%s\n" "${output[@]}" > "$DOTFILES_SSH_CONFIGD/$ssh_hostname"
}