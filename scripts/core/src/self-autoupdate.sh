#!/usr/bin/env bash

#shellcheck disable=SC1091
. "$DOTLY_PATH/scripts/self/src/update.sh"

autoupdate::sloth_updater() {
  local CURRENT_DIR remote_sloth_minor
  set +e # Avoid crash if any function return an error

  # Other needed variables
  CURRENT_DIR="$(pwd)"

  # Change to dotly path
  cd "$DOTLY_PATH" || return 1

  [[ -f "$DOTFILES_PATH/.sloth_updated" ]] &&
    [[ "${SLOTH_AUTO_UPDATE_MODE:-auto}" != "silent" ]] && {
    output::empty_line
    output::write "     🥳 🎉 🍾      SLOTH UPDATED     🥳 🎉 🍾  "
    output::empty_line
    migration_script="$(uptate::migration_script_exits)"
    if [[ -n "$migration_script" ]]; then
      output::write "Migration script is neccesary to be executed and must be done syncronously by executing:"
      output::answer "dot self migration $migration_script"
      output::empty_line
    fi

    [[ -z "$migration_script" ]] && rm "$DOTFILES_PATH/.sloth_updated"
  }

  [[ -f "$DOTFILES_PATH/.sloth_update_available" ]] && return 0

  if files::check_if_path_is_older "$DOTLY_PATH" "${SLOTH_AUTO_UPDATE_PERIOD_IN_DAYS:-7}" "days" &&
    ! git::check_local_repo_is_updated "origin" "$DOTLY_PATH"; then
    touch "$DOTFILES_PATH/.sloth_update_available"

    remote_sloth_minor="$(update::check_minor_update)"
    if [[ -z "$remote_sloth_minor" ]]; then
      touch "$DOTFILES_PATH/.sloth_update_available_is_major"
    fi
  fi

  cd "$CURRENT_DIR" || return 1
}

autoupdate::sloth_success() {
  if [[ -f "$DOTFILES_PATH/.sloth_update_available" ]] && [[ ! -f "$DOTFILES_PATH/.sloth_force_current_version" ]]; then
    if [[ -f "$DOTFILES_PATH/.sloth_update_available_is_major" ]] && [[ "$(str::to_lower "$SLOTH_UPDATE_VERSION")" =~ minor$ ]]; then
      return 0
    fi

    case "$(str::to_lower "${SLOTH_AUTO_UPDATE_MODE:-auto}")" in
    "silent")
      update::update_local_sloth_module
      rm -f "$DOTFILES_PATH/.sloth_update_available"
      ;;
    "info")
      output::empty_line
      output::write " ---------------------------------------------"
      output::write "|  🥳🎉🍾 NEW SLOTH VERSION AVAILABLE 🥳🎉🍾  |"
      output::write " ---------------------------------------------"
      output::empty_line
      ;;
    "prompt")
      # Nothing to do here
      ;;
    *) # auto
      output::answer "🚀 Updating SLOTH Automatically"
      update::update_local_sloth_module
      output::solution "Updated, restart your terminal."
      rm -f "$DOTFILES_PATH/.sloth_update_available"
      ;;
    esac
  fi
}

autoupdate::sloth_reject() {
  # Nothing to be updated
  return 0
}
