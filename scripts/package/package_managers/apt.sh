#!/usr/bin/env bash

apt::install() {
   sudo apt-get update
   sudo apt-get -y install "$@"
}
