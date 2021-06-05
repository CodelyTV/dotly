script::depends_on() {
  utils::curry command_not_exists utils::not platform::command_exists
  non_existing_commands=$(coll::filter command_not_exists "$@")

  for non_existing_command in $non_existing_commands; do
    has_to_install=$(output::question "\`$non_existing_command\` is a dependency of this script. Should this be installed? [Y/n]")

    if output::answer_is_yes "$has_to_install"; then
      "$DOTLY_PATH/bin/dot" package add "$non_existing_command"
    else
      output::write "🙅‍ The script can't be ran without \`$non_existing_command\` being installed before."
      exit 1
    fi
  done
}
