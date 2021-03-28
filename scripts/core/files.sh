#!/usr/bin/env bash

files::check_if_path_is_older() {
  [[ $(date -r "$1" +%s) -lt $(date -d "now - $2 days" +%s) ]]
}