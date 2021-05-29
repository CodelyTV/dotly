#!/usr/bin/env bash

cargo::install() {
  log::append "trying to cargo install $1"
  cargo install "$@"
}
