#!/usr/bin/env bash

# shellcheck disable=SC2120
update::check_minor_update() {
  local local_sloth_version cremote_sloth_version tags_number tag_version
  tags_number="${1:-10}"
  local_sloth_version="$(git::sloth_repository_exec git::get_current_latest_tag)"
  cremote_sloth_version=($(git::get_all_remote_tags_version_only $(git::get_submodule_property sloth url) | head -n${tags_number}))

  [ -n "$local_sloth_version" ] && for tag_version in "${cremote_sloth_version[@]}"; do
    [ -z "$tag_version" ] && continue # I am not sure if this can happen
    [ "$(platform::semver_compare "$local_sloth_version" "$tag_version")" -le 0 ] && break # Older version no check

    if platform::semver_is_minor_or_patch_update "$local_sloth_version" "$tag_version"; then
      echo "$tag_version"
      return 0
    fi
  done

  return 1
}

# Get the latest minor using the HEAD as it could be 
update::get_latest_minor_local_head() {
  local current_tag_version latest_local_tag latest_tags_version tag_version return_code
  current_tag_version="$(git::sloth_repository_exec git::get_commit_tag)" # Current HEAD tag
  latest_local_tag="$(git::get_current_latest_tag)"
  return_code=1

  if [[ -z "$current_tag_version" ]] && [[ -n "$latest_local_tag" ]]; then
      echo "$latest_local_tag"
      return_code=0
      
  elif [[ -n "$current_tag_version" ]]; then
    latest_tags_version=($(git::get_all_local_tags))

    # Select latest local minor tag taking the current HEAD tag as main
    for tag_version in "${latest_tags_version[@]}"; do
      [[ "$(platform::semver_compare "$current_tag_version" "$tag_version")" -le 0 ]] && break
      if "$(platform::semver_is_minor_or_patch_update "$current_tag_version" "$tag_version")"; then
        current_tag_version="$tag_version"
        return_code=0
        break
      fi
    done
  fi

  [[ -n "$current_tag_version" ]] && echo "$current_tag_version"

  return "$return_code"
}

update::check_if_is_stable_update() {
  local local_sloth_version cremote_sloth_version tags_number
  set +e

  local_sloth_version="$(git::sloth_repository_exec git::get_current_latest_tag)"
  reremote_sloth_version="$(git::get_all_remote_tags_version_only $(git::get_submodule_property sloth url) | head -n1)"

  [[ "$(platform::semver_compare "$local_sloth_version" "$reremote_sloth_version")" -eq -1 ]] && echo "$reremote_sloth_version"
}

# shellcheck disable=SC2120
update::update_sloth_repository() {
  local current_directory current_branch update_submodules return_code
  set +e

  # Defaults values that are needed here
  current_directory="$(pwd)"
  return_code=0
  current_branch="$(git::get_submodule_property sloth branch)"

  # Arguments
  update_submodules="${1:-}"

  { [[ -d "$DOTLY_PATH" ]] && cd "$DOTLY_PATH"; } || return 1

  if git::is_in_repo; then
    git discard >/dev/null 2>&1
    git checkout "$current_branch" >/dev/null 2>&1
    git pull >/dev/null 2>&1
    return_code=$?
    
    if [[ -n "$update_submodules" ]] && [[ $return_code -eq 0 ]]; then
      git submodule update --init --recursive "$@" > /dev/null 2>&1 # $@ because maybe you want to update specific submodule only
    fi
  fi

  cd "$current_directory" || return $return_code

  return $return_code
}

update::check_consistency_with_sloth_version() {
  local local_commit_tag
  local_commit_tag="$(git::sloth_repository_exec git::get_commit_tag)"

  case "$(str::to_lower "$DOTLY_UPDATE_VERSION")" in
    "stable"|"minor")
      if [ -z "$local_commit_tag" ] && [ ! -f "$DOTFILES_PATH/.sloth_force_current_version" ]; then
        output::error "Error in your Dotly configuration, 'DOTLY_UPDATE_VERSION'"
        output::empty_line
        output::answer "You have selected to update to $DOTLY_UPDATE_VERSION but you are not"
        output::write "\tusing any stable version. Modify DOTLY_UPDATE_VERSION variable or use"
        output::write "\tthe script:"
        output::write "\t\tdot self version"
        output::empty_line
        output::write "You can also disable updates by using: 'dot self update --disable'"
        output::empty_line
        return 1
      fi
      ;;
    *)
    return 0
    ;;
  esac
}

update::update_local_sloth_module() {
  local current_sloth_hash local_sloth_version remote_sloth_minor remote_sloth_tag
  set +e # Avoid crash if any function fail

  current_sloth_hash="$(git::get_local_HEAD_hash)"
  local_sloth_version="$(git::sloth_repository_exec git::get_commit_tag)"
  remote_sloth_minor="$(update::check_minor_update)"
  remote_sloth_tag="$(update::check_if_is_stable_update)"

  # No update
  if [ ! -f "$DOTFILES_PATH/.sloth_force_current_version" ]; then
    return 1
  fi

  # Version consistency
  if ! update::check_consistency_with_sloth_version >/dev/null; then
    return 1
  fi

  # Update local repository
  if ! git::check_local_repo_is_updated "origin" "$DOTLY_PATH"; then
    update::update_sloth_repository
    [[ -n "$local_sloth_version" ]] && git checkout "$local_sloth_version" # Keep current tag
  fi

  case "$(str::to_lower "${DOTLY_AUTO_UPDATE_VERSION:-stable}")" in
    "latest"|"beta")
      ;;
    "minor"|"only_minor")
      if [ -n "$remote_sloth_minor" ]; then
        git::sloth_repository_exec git checkout "$remote_sloth_minor"
      fi
      ;;
    *) #Stable
      git::sloth_repository_exec git checkout -q "$remote_sloth_tag"
      ;;
  esac

  rm -f "$DOTFILES_PATH/.sloth_force_current_version"
  rm -f "$DOTFILES_PATH/.sloth_update_available"
  rm -f "$DOTFILES_PATH/.sloth_update_available_is_major"
  echo "$current_sloth_hash" >| "$DOTFILES_PATH/.sloth_updated"
}

uptate::migration_script_exits() {
  local latest_migration_script update_previous_commit
  latest_migration_script="$(find "$DOTLY_PATH/migration/" -name "*" -type f,l -executable -print0 -exec echo {} \; | sort --reverse | head -n 1 | xargs)"

  # No update no migration necessary
  if [[ ! -f "$DOTFILES_PATH/.sloth_updated" ]] || [[ -z "$latest_migration_script" ]]; then
    return 1
  fi

  # If was added in previous commit
  if ! git::check_file_exists_in_previous_commit "$latest_migration_script"; then
    echo "$latest_migration_script"
    return 0
  fi

  # Get previous commit and check if was added after
  update_previous_commit="$(cat "$DOTFILES_PATH/.sloth_updated")"
  [[ -z "$update_previous_commit" ]] && return 1 # Could not be checked if migration script should be executed
  
  git::check_file_is_modified_after_commit "$latest_migration_script" "$update_previous_commit" && echo "$latest_migration_script"
}
