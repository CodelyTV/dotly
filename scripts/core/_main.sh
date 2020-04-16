#!/usr/bin/env bash

if ! ${DOT_MAIN_SOURCED:-false}; then
  source "$DOTLY_PATH/scripts/core/args.sh"
  source "$DOTLY_PATH/scripts/core/collections.sh"
  source "$DOTLY_PATH/scripts/core/log.sh"
  source "$DOTLY_PATH/scripts/core/platform.sh"

  readonly DOT_MAIN_SOURCED=true
fi
