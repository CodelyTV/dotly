#!/usr/bin/env bash

script::depends_on() {
  utils::curry command_not_exists utils::not platform::command_exists
  non_existing_commands=$(coll::filter command_not_exists "$@")

  for non_existing_command in $non_existing_commands; do
    output::question "\`$non_existing_command\` is a dependency of this script. Should this be installed? [Y/n]" "has_to_install"

    if [[ "${has_to_install:-Y}" =~ ^[Yy] ]]; then
      dot package install "$non_existing_command"
    else
      output::write "🙅‍ The script can't be ran without \`$non_existing_command\` being installed before."
      exit 1
    fi
  done
}
