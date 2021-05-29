#!/usr/bin/env bash

script::depends_on() {
  utils::curry command_not_exists utils::not platform::command_exists
  non_existing_commands=$(coll::filter command_not_exists "$@")

  echo "dot self install" | log::file "Debug 5"

  for non_existing_command in $non_existing_commands; do
    output::question "\`$non_existing_command\` is a dependency of this script. Should this be installed? [Y/n]" "has_to_install"

    echo "Before answer is" | log::file "Debug 5.5"
    if output::answer_is_yes "$has_to_install"; then
      echo "Before dot package add" | log::file "Debug 6"

      "$DOTLY_PATH/bin/dot" package add "$non_existing_command"
    else
      echo "answer is not yes" | log::file "Debug 6.2"
      output::write "🙅‍ The script can't be ran without \`$non_existing_command\` being installed before."
      exit 1
    fi
  done
}
