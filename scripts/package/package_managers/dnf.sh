#!/usr/bin/env bash

dnf::install() {
   sudo dnf -y install "$@"
}
