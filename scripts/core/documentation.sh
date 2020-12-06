#!/usr/bin/env bash

docs::parse() {
  eval "$(docpars -h "$(grep "^##?" "$0" | cut -c 5-)" : "$@")"
}
