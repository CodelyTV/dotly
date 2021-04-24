#!/usr/bin/bash

if ! platform::command_exists python || ! platform::command_exists jq || ! platform::command_exists sponge; then
  output::error "The commands 'python', 'jq' and 'sponge' are needed, try by executing:"
  output::answer "$DOTLY_PATH/bin/dot" package install python3
  output::answer "$DOTLY_PATH/bin/dot" package install jq
  output::answer "$DOTLY_PATH/bin/dot" package install sponge
  output::empty_line
  output::yesno "Do you want to execute now and continue" && {
      "$DOTLY_PATH/bin/dot" package install python3
      "$DOTLY_PATH/bin/dot" package install jq
      "$DOTLY_PATH/bin/dot" package install sponge
  } || exit 1
  output::empty_line
fi

source "$DOTLY_PATH/scripts/core/yaml.sh"
source "$DOTLY_PATH/scripts/core/json.sh"
source "$DOTLY_PATH/scripts/core/dotbot_yaml.sh"