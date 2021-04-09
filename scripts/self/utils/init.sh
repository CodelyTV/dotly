#!/usr/bin/env bash

DOTLY_INIT_SCRIPTS_PATH=${DOTLY_INIT_SCRIPTS_PATH:-$DOTLY_PATH/shell/init-scripts}
DOTFILES_INIT_SCRIPTS_PATH=${DOTFILES_INIT_SCRIPTS_PATH:-$DOTFILES_PATH/shell/init-scripts}
ENABLED_INIT_SCRIPTS_PATH=${ENABLED_INIT_SCRIPTS_PATH:-$DOTFILES_PATH/shell/init-scripts.enabled}

init::exists_script() {
    [[ -f "$DOTLY_INIT_SCRIPTS_PATH/$1" ]] || [[ -f "$DOTFILES_INIT_SCRIPTS_PATH" ]]
}

init::status() {
  init::exists_script "$1" && [[ -f "$ENABLED_INIT_SCRIPTS_PATH/$1" ]]
}

init::get_scripts() {
  [[ -d "$DOTLY_INIT_SCRIPTS_PATH" ]] &&\
    [[ -d "$DOTFILES_INIT_SCRIPTS_PATH" ]] &&\
    find "$DOTLY_INIT_SCRIPTS_PATH" \
        "$DOTFILES_INIT_SCRIPTS_PATH" -name "*" -type f |\
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
  local from1="$DOTLY_INIT_SCRIPTS_PATH"
  local from2="$DOTFILES_INIT_SCRIPTS_PATH"
  local to="$ENABLED_INIT_SCRIPTS_PATH"
  local item

  for item in "$@"; do
    # Check if exists in DOTLY_PATH
    [[ -f "$from1/$item" ]] &&\
      [[ ! -f "$to/$item" ]] &&\
      rm -f "$to/$item" &&\
      ln -s "$from1/$item" "$to/"
    
    # Check if exists in DOTFILES_PATH
    # This will prevail over DOTLY_PATH
    [[ -f "$from2/$item" ]] &&\
      [[ ! -f "$to/$item" ]] &&\
      rm -f "$to/$item" &&\
      ln -s "$from2/$item" "$to/"
  done
}

init::disable() {
  local enabled_path="$ENABLED_INIT_SCRIPTS_PATH"
  local item

  for item in "$@"; do
    [[ -f "$enabled_path/$item" ]] &&\
      rm -f "$enabled_path/$item"
  done
}