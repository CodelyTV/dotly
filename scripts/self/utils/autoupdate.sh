#!/usr/bin/env bash

. "$DOTLY_PATH/scripts/core/github.sh"

autoupdate::updater() {
  local CURRENT_DIR GIT_UPDATE_CHECK

  # Other needed variables
  CURRENT_DIR="$(pwd)"
  GIT_UPDATE_CHECK="${1:-$DOTLY_PATH}"

  # Change to dotly path
  cd "$GIT_UPDATE_CHECK" || return 1

  [[ -f "$DOTFILES_PATH/.dotly_updated" ]] && {
    output::empty_line
    output::write "     🥳 🎉 🍾      DOTLY UPDATED     🥳 🎉 🍾  "
    output::empty_line
    rm "$DOTFILES_PATH/.dotly_updated"
  }

  [[ -f "$DOTFILES_PATH/.dotly_update_available" ]] && return 0
  
  if files::check_if_path_is_older "$GIT_UPDATE_CHECK" "${DOTLY_AUTO_UPDATE_PERIOD_IN_DAYS:-7}" "days" &&\
    # shellcheck disable=SC2048
    [ "$(git rev-parse HEAD)" != "$(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1)" ]
  then
    touch "$DOTFILES_PATH/.dotly_update_available"
  fi

  cd "$CURRENT_DIR" || return 1
}

autoupdate::success() {
  local latest_github_version current_dotly_version
  if [[ -f "$DOTFILES_PATH/.dotly_update_available" ]]; then
    case "$(str::to_lower "${DOTLY_AUTO_UPDATE_MODE:-minor}")" in
      "silent")
        "$DOTLY_PATH/bin/dot" self update
        rm -f "$DOTFILES_PATH/.dotly_update_available"
        ;;
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
      "minor"|"only_minor")
        # Needs a file in DOTLY_PATH called VERSION with current installed VERSION
        latest_github_version=$(github::cached_curl "$GITHUB_API_URL/$GITHUB_DOTLY_REPOSITORY/tags" | jq -r '.[0].name' | uniq)
        current_dotly_version="0.0.0"
        [ -f "$DOTLY_PATH/VERSION" ] && current_dotly_version="$(cat "$DOTLY_PATH/VERSION")"
        
        if [[ -n "$latest_github_version" ]] &&\
          [[ -n "$current_dotly_version" ]] &&\
          platform::semver_is_minor_patch_update "$current_dotly_version" "$latest_github_version"
        then
          output::answer "🚀 Updating DOTLY Automatically"
          "$DOTLY_PATH/bin/dot" self update
          output::solution "Updated, restart your terminal."
        fi

        rm -f "$DOTFILES_PATH/.dotly_update_available"
        ;;
      *) # Prompt
        #Nothing to do when only show a inbox in prompt
      ;;
    esac
  fi
}

autoupdate::reject() {
  # Nothing to be updated
  return 0
}