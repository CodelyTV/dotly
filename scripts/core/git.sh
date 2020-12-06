#!/usr/bin/env bash

git::is_in_repo() {
  git rev-parse HEAD >/dev/null 2>&1
}

git::current_branch() {
  git branch
}
