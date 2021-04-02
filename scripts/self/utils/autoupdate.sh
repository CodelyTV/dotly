#!/usr/bin/env bash

# DOTLY_AUTO_UPDATE_DAYS=${DOTLY_AUTO_UPDATE_DAYS:-7}
# DOTLY_AUTO_UPDATE_MODE=${DOTLY_AUTO_UPDATE_MODE:-reminder} # prompt
# async "autoupdate::updater '/Users/gtrabanco/MyCodes/dotly2'" autoupdate::success autoupdate::reject


autoupdate::updater() {
  local CURRENT_DIR GIT_UPDATE_CHECK

  # Other needed variables
  CURRENT_DIR="$(pwd)"
  GIT_UPDATE_CHECK="${1:-$DOTLY_PATH}"

  # Change to dotly path
  cd "$GIT_UPDATE_CHECK" || return 1

  [[ -f "$DOTFILES_PATH/.dotly_update_available" ]] && return 0
  
  if [[ $(date -r "$GIT_UPDATE_CHECK" +%s) -lt $(date -d "now - ${DOTLY_AUTO_UPDATE_DAYS:-7} days" +%s) ]] &&\
    [ "$(git rev-parse HEAD)" != "$(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1)" ]
  then
    touch "$DOTFILES_PATH/.dotly_update_available"
  fi

  cd "$CURRENT_DIR" || return 1
}

autoupdate::success() {
  if [[ -f "$DOTFILES_PATH/.dotly_update_available" ]]; then
    case "${DOTLY_AUTO_UPDATE_MODE:-reminder}" in
      "auto"|"autoupdate"|"auto-update"|"update")
          output::answer "🚀 Updating DOTLY Automatically"
          "$DOTLY_PATH/bin/dot" self update
          output::solution "Updated, restart your terminal."
          rm -f "$DOTFILES_PATH/.dotly_update_available"
        ;;
      "info")
        output::empty_line
        output::write " ---------------------------------------------"
        output::write "|  🥳🎉🍾 NEW DOTLY VERSION AVAILABLE 🥳🎉🍾  |"
        output::write " ---------------------------------------------"
        output::empty_line
        ;;
      *) # prompt or reminder...
        # Nothing to do here
      ;;
    esac
  fi
}

autoupdate::reject() {
  # Nothing to be updated
  return 0
}