#!/usr/bin/env bash

# Stuff we want to execute just once
if [[ -z "$DOTLY_SECRETS_MODULE_PATH" ]]; then
  readonly DOTLY_SECRETS_MODULE_PATH="modules/secrets"
  readonly SECRETS_JSON="$DOTFILES_PATH/$DOTLY_SECRETS_MODULE_PATH/symlinks/secrets.json"

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