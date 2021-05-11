#!/usr/bin/env bash

. "$DOTLY_PATH/scripts/self/src/update.sh"

autoupdate::dotly_updater() {
  local CURRENT_DIR remote_dotly_minor
  set +e # Avoid crash if any function return an error

  # Other needed variables
  CURRENT_DIR="$(pwd)"

  # Change to dotly path
  cd "$DOTLY_PATH" || return 1

  [[ -f "$DOTFILES_PATH/.dotly_updated" ]] &&\
  [[ "${DOTLY_AUTO_UPDATE_MODE:-auto}" != "silent" ]] && {
    output::empty_line
    output::write "     🥳 🎉 🍾      DOTLY UPDATED     🥳 🎉 🍾  "
    output::empty_line
    rm "$DOTFILES_PATH/.dotly_updated"
  }

  [[ -f "$DOTFILES_PATH/.dotly_update_available" ]] && return 0
  
  if files::check_if_path_is_older "$DOTLY_PATH" "${DOTLY_AUTO_UPDATE_PERIOD_IN_DAYS:-7}" "days" &&\
    ! git::check_local_repo_is_updated "origin" "$DOTLY_PATH"
  then
    touch "$DOTFILES_PATH/.dotly_update_available"

    remote_dotly_minor="$(update::check_minor_update)"
    if [[ -z "$remote_dotly_minor" ]]; then
      touch "$DOTFILES_PATH/.dotly_update_available_is_major"
    fi
  fi

  cd "$CURRENT_DIR" || return 1
}

autoupdate::dotly_success() {
  if [[ -f "$DOTFILES_PATH/.dotly_update_available" ]] && [[ ! -f "$DOTFILES_PATH/.dotly_force_current_version" ]]; then
    if [[ -f "$DOTFILES_PATH/.dotly_update_available_is_major" ]] && [[ "$(str::to_lower "$DOTLY_UPDATE_VERSION")" =~ minor$ ]]; then
      return 0
    fi

    case "$(str::to_lower "${DOTLY_AUTO_UPDATE_MODE:-auto}")" in
      "silent")
        update::update_local_dotly_module
        rm -f "$DOTFILES_PATH/.dotly_update_available"
        ;;
      "info")
        output::empty_line
        output::write " ---------------------------------------------"
        output::write "|  🥳🎉🍾 NEW DOTLY VERSION AVAILABLE 🥳🎉🍾  |"
        output::write " ---------------------------------------------"
        output::empty_line
        ;;
      "prompt")
        # Nothing to do here
        ;;
      *) # auto
          output::answer "🚀 Updating DOTLY Automatically"
          update::update_local_dotly_module
          output::solution "Updated, restart your terminal."
          rm -f "$DOTFILES_PATH/.dotly_update_available"
      ;;
    esac
  fi
}

autoupdate::dotly_reject() {
  # Nothing to be updated
  return 0
}
