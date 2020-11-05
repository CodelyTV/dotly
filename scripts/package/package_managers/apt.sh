#!/usr/bin/env bash

apt::install() {
   sudo apt-get -y install "$@"
}
