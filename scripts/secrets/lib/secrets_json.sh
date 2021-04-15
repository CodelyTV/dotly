#!/usr/bin/env bash

secrets::get_all_aliases() {
  jq -r ".[].link | select(. != null) | keys[1:] | .[]" "$SECRETS_JSON"
}

secrets::get_stored_file_by_alias() {
  jq -r ".[].link | select(. != null) | .\"$1\"" "$SECRETS_JSON"
}

secrets::get_alias_by_stored_file() {
  local item
  jq -r\
    ".[] | select( .link != null) | .link | map_values(select(. == \"$1\")) | keys[]"\
    "$SECRETS_JSON" | while read -r item; do
      echo "$item"
  done
}

secrets::append_or_update_value_of_link() {
  # Can not set empty values of symlink or stored file
  if [[ -z "$1" ]] || [[ -z "$2" ]]; then
    return 1
  fi

  jq\
    ".[] | select(.link != null) |= .link + {\"$1\": \"$2\"}"\
    "$SECRETS_JSON" | sponge "$SECRETS_JSON"
}

secrets::remove_secrets_json_link_by_symlink() {
  [[ -n "$1" ]] && jq -r "del(.[].link.\"$1\")" "$SECRETS_JSON" | sponge "$SECRETS_JSON"
}

secrets::remove_secrets_json_link_by_stored_file() {
  local item value
  value="$1"

  [[ -z "$1" ]] && return 1

  jq -r\
    ".[] | select( .link != null) | .link | map_values(select(. == \"$value\")) | keys[]"\
    "$SECRETS_JSON" | while read -r item; do
      secrets::remove_secrets_json_link_by_symlink "$item"
  done
}