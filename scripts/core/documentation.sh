#!/usr/bin/env bash

docs::parse() {
  if ! platform::command_exists docpars; then
    output::error "You need to have docpars installed in order to use dotly"
    output::solution "Run this command to install it:"
    output::solution "curl https://sh.rustup.rs -sSf | sh -s -- -y && cargo install docpars"

    exit 1
  fi

  eval "$(docpars -h "$(grep "^##?" "$0" | cut -c 5-)" : "$@")"
}
