#!/usr/bin/env bash

# Stuff we want to execute just once
if ! ${DOTLY_SECRETS_MODULE_PATH:-false}; then
  readonly DOTLY_SECRETS_MODULE_PATH="modules/secrets"

  if ! platform::command_exists jq || ! platform::command_exists sponge; then
    output::error "The commands 'jq' and 'sponge' are needed, try by executing:"
    output::answer "$DOTLY_PATH/bin/dot" package install jq
    output::answer "$DOTLY_PATH/bin/dot" package install sponge
    output::empty_line
    output::yesno "Do you want to execute now and continue" && {
        "$DOTLY_PATH/bin/dot" package install jq
        "$DOTLY_PATH/bin/dot" package install sponge
      } || exit 1
    output::empty_line
  fi
fi

secrets::find () {
  local find_relative_path exclude_itself arguments

  case "$1" in
    --exclude)
      exclude_itself=true; shift
    ;;
    *)
      exclude_itself=false
    ;;
  esac

  find_relative_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/"
  arguments=()

  if [ -e "$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/${1:-}" ]; then
    find_relative_path="$find_relative_path${1:-}"; shift
  fi

  if $exclude_itself; then
    arguments+=(-not -path "$find_relative_path")
  fi

  arguments+=("$@")

  find "$find_relative_path" -not -iname ".*" "${arguments[@]}" -print | while read -r item; do
    printf "%s\n" "${item/$find_relative_path\//}"
  done
}

secrets::fzf() {
  local piped_values
  piped_values="$(</dev/stdin)"

  printf "%s\n" ${piped_values[@]} | fzf -m --extended \
    --header "$1"\
    --preview "echo 'Press Tab+Shift to select multiple options.\
    \nPress Ctrl+C to exit with no selection.\n\n\
    CONTENT IS NOT SHOW DUE TO SECURITY REASONS'"
}

secrets::check_exists() {
  [[ -e "$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/$1" ]] && echo "$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/$1"
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

secrets::remove_file() {
  local start_dir
  start_dir="$(pwd)"
  cd "$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH" || return 1
  git filter-branch --index-filter 'git rm -f --ignore-unmatch $(realpath --relative-to="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH" "$1")' HEAD
  cd "$start_dir" || return
}

secrets::var_delete() {
  local var_path
  var_path="$(secrets::var_exists "$1")"; shift
  [[ -n "$var_path" ]] && secrets::remove_file "$var_path"
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
  file_path="$DOTFILES_PATH/modules/secrets/symlinks/secrets.json"
  
  start_dir="$(pwd)"
  cd "$DOTFILES_PATH" || return 1

  if [[ -f "$file_path" ]]; then
    jq -r '.[] | select( .link != null) | .link | keys[1:] | .[]' "$file_path" |\
      while read -r item; do
        output::answer "Remove symlink: $item"
        eval rm -f "$item"
      done
  fi

  cd "$start_dir" || return
}

secrets::purge_secrets_json() {
  local file_path item start_dir
  file_path="$DOTFILES_PATH/modules/secrets/symlinks/secrets.json"
  
  jq -r '.[] | select( .link != null) | .link | map_values(.) | keys[1:] | .[]' "$file_path" | while prompt -r item; do
    jq -r "del(.[1].link.\"$item\")" "$secrets_json" | sponge "$secrets_json"
  done
}

secrets::remove_symlink_by_stored_file() {
  local secrets_json item start_dir relative_path_to_remove file_path
  relative_path_to_remove="$DOTLY_SECRETS_MODULE_PATH/files/$1"
  secrets_json="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/symlinks/secrets.json"
  start_dir="$(pwd)"
  cd "$DOTFILES_PATH" || return 1

  if [[ -f "$secrets_json" ]] && [[ -n "$1" ]]; then
    jq -r \
      ".[] | select( .link != null) | .link | map_values(select(. == \"$relative_path_to_remove\")) | keys[0]" \
      "$secrets_json" | while read -r item; do
        [[ "$item" == "null" ]] && continue
        file_path=""
        file_path="$(jq -r ".[1].link.\"$item\"" "$secrets_json")"
        file_path="${file_path/$DOTLY_SECRETS_MODULE_PATH\//}"

        jq -r "del(.[1].link.\"$item\")" "$secrets_json" | sponge "$secrets_json"
        
        secrets::remove_file "$file_path"
        eval rm -f "$item"

        output::solution "File '$1' with alias '$item' removed."
    done
  fi

  cd "$start_dir" || return
}

secrets::store_file() {
  local secret_files_path item_symlink_path secret_link secrets_json
  item_symlink_path="$(secrets::relative_path "$1")"
  secrets_json="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/symlinks/secrets.json"

  if [[ -n "$2" ]]; then
    secret_files_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/files/$2"
    secret_link="$DOTLY_SECRETS_MODULE_PATH/files/$2/$(basename "$1")"
  else
    secret_files_path="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/files"
    secret_link="$DOTLY_SECRETS_MODULE_PATH/files/$(basename "$1")"
  fi

  if [[ -e "$secret_files_path/$(basename "$1")" ]]; then
    output::error "Already exists a file with this name, try adding a different secrets relative path"
    return 1
  fi

  output::answer "Moving the file to your secrets path"
  mkdir -p "$secret_files_path/"
  mv -n "$1" "$secret_files_path/"

  output::answer "Linking your file"
  eval ln -s "$secret_files_path/$(basename "$item_symlink_path")" "$item_symlink_path"

  # Add to json secrets file
  jq ".[1].link += {\"$item_symlink_path\": \"$secret_link\"}" "$secrets_json" | sponge "$secrets_json"
}