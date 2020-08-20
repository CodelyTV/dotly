#!/usr/bin/env bash

paths::list_dotly_scripts() {
  find "$DOTLY_PATH/scripts" -maxdepth 2 -perm +111 -type f |
    grep -v core
}

paths::list_dotfiles_scripts() {
  find "$DOTFILES_PATH/scripts" -maxdepth 2 -perm +111 -type f |
    grep -v core
}

paths::list_all_scripts()  {
  paths::list_dotly_scripts
  paths::list_dotfiles_scripts
}

paths::list_scripts_sorted()  {
  paths::list_all_scripts | sort
}
