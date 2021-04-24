#!/usr/bin/env bash

DOTLY_INIT_SCRIPTS_PATH=${DOTLY_INIT_SCRIPTS_PATH:-$DOTLY_PATH/shell/init-scripts}
DOTFILES_INIT_SCRIPTS_PATH=${DOTFILES_INIT_SCRIPTS_PATH:-$DOTFILES_PATH/shell/init-scripts}
ENABLED_INIT_SCRIPTS_PATH=${ENABLED_INIT_SCRIPTS_PATH:-$DOTFILES_PATH/shell/init-scripts.enabled}

init::exists_script() {
    [[ -e "$DOTLY_INIT_SCRIPTS_PATH/$1" ]] || [[ -e "$DOTFILES_INIT_SCRIPTS_PATH" ]]
}

init::status() {
  init::exists_script "$1" && [[ -f "$ENABLED_INIT_SCRIPTS_PATH/$1" ]]
}

init::get_scripts() {
  [[ -d "$DOTLY_INIT_SCRIPTS_PATH" ]] &&\
    [[ -d "$DOTFILES_INIT_SCRIPTS_PATH" ]] &&\
    find "$DOTLY_INIT_SCRIPTS_PATH" \
        "$DOTFILES_INIT_SCRIPTS_PATH" -name "*" -type f,l |\
    xargs -I _ basename _ | sort | uniq
}

init::get_enabled() {
  [[ -d "$ENABLED_INIT_SCRIPTS_PATH" ]] &&\
    find "$ENABLED_INIT_SCRIPTS_PATH" -name "*" -type l |\
    xargs -I _ basename _ | sort | uniq
}

init::fzf() {
  local piped_values="$(</dev/stdin)"

  printf "%s\n" ${piped_values[@]} | fzf -m --extended \
    --header "$1"\
    --preview "echo 'Press Tab+Shift to select multiple options.\nPress Ctrl+C to exit with no selection.'"
}

init::enable() {
  local dotly_init_scripts_path dotfiles_init_scripts_path to item
  dotly_init_scripts_path="$DOTLY_INIT_SCRIPTS_PATH"
  dotfiles_init_scripts_path="$DOTFILES_INIT_SCRIPTS_PATH"
  to="$ENABLED_INIT_SCRIPTS_PATH"

  for item in "$@"; do
    [[ -e "$dotly_init_scripts_path/$item" ]] &&\
      [[ ! -e "$to/$item" ]] &&\
      rm -f "$to/$item" &&\
      ln -s "$dotly_init_scripts_path/$item" "$to/"
    
    [[ -e "$dotfiles_init_scripts_path/$item" ]] &&\
      [[ ! -e "$to/$item" ]] &&\
      rm -f "$to/$item" &&\
      ln -s "$dotfiles_init_scripts_path/$item" "$to/"
  done
}

init::disable() {
  local enabled_path item
  enabled_path="$ENABLED_INIT_SCRIPTS_PATH"

  for item in "$@"; do
    [[ -e "$enabled_path/$item" ]] &&\
      rm -f "$enabled_path/$item"
  done
}
