#!/usr/bin/env bash

apt::install() {
   sudo apt update
   sudo apt -y install "$@"
}
