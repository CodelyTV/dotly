#!/usr/bin/env bash

symlinks::get_file_path() {
  local yaml_file_posibilities yaml_file
  yaml_file="${1:-conf}"
  yaml_file_posibilities=(
    "$yaml_file"
    "$yaml_file.yaml"
    "$yaml_file.yml"
    "$DOTFILES_PATH/symlinks/$yaml_file"
    "$DOTFILES_PATH/symlinks/$yaml_file.yaml"
    "$DOTFILES_PATH/symlinks/$yaml_file.yml"
    "$DOTFILES_PATH/symlinks/conf.yml"
  )

  for f in "${yaml_file_posibilities[@]}" ; do
    [[ -f "$f" ]] && [[ -w "$f" ]] && yaml_file="$f" && break
  done

  if [ ! -w "$yaml_file" ]; then
    output::error "The yaml file '$yaml_file' does not exists or its not writable by you."
    exit 1
  fi

  echo "$yaml_file" && return 0
}

symlinks::link_exists() {
  local link_or_dotfile_path yaml_file link_check_value
  yaml_file="${1:-}"
  link_or_dotfile_path="${2:-}"

  if [ -z "$link_or_dotfile_path" ] || [ -z "$yaml_file" ]; then
    return 1
  fi

  link_check_value="$(dotbot::get_value_of_key_in "link" "$link_or_dotfile_path" "$yaml_file")"
  [ -n "$link_check_value" ] && echo "$link_or_dotfile_path" && return 0

  link_check_value="$(dotbot::get_value_of_key_in "link" "$(dotbot::create_relative_link "$link_or_dotfile_path")" "$yaml_file")"
  [ -n "$link_check_value" ] && echo "$(dotbot::create_relative_link "$link_or_dotfile_path")" && return 0

  link_check_value="$(dotbot::get_key_by_value_in "link" "$link_or_dotfile_path" "$yaml_file")"
  [ -n "$link_check_value" ] && echo "$link_check_value" && return 0

  link_check_value="$(dotbot::get_key_by_value_in "link" "$(dotbot::create_relative_link "$link_or_dotfile_path")" "$yaml_file")"
  [ -n "$link_check_value" ] && echo "$link_check_value" && return 0

  return 1
}

# From can be the current path, to should be the path inside your dotfiles
symlinks::add_yaml_and_move_files() {
  local yaml_file from link_in_yaml link_in_yaml_target path_to current_link_target
  yaml_file="${1:-}"
  from="${2:-}"
  path_to="$(realpath -sm $DOTBOT_BASE_PATH/${3:-})"

  current_link_target="$path_to/$(basename "$from")"

  link_in_yaml="$(dotbot::create_relative_link "$from")"
  link_in_yaml_target="$(dotbot::create_relative_link "$path_to/$(basename "$from")")"

  if [ -e "$yaml_file" ]; then
    # Eval to solve globbing and paths like ~/my_file
    mkdir -p "$path_to"
    eval mv -i "$from" "$path_to/"
    eval ln -s "$current_link_target" "$from"
    dotbot::add_or_edit_json_value_to_directive "link" "$link_in_yaml" "$link_in_yaml_target" "$yaml_file"
  fi
}

symlinks::move_from_pwd_to_dotfiles() {
  local from path_to
  from="${1:-}"
  path_to="$(realpath -sm $DOTBOT_BASE_PATH/${2//$DOTBOT_BASE_PATH/})"

  if [ -z "${1:-}" ]; then
    return 1
  fi

  if [ -e "$yaml_file" ]; then
    mkdir -p "$path_to"
    mv -i "$from" "$path_to/" # eval to solve ~/myfile resolution
  fi
}

symlinks::restore_by_link() {
  local yaml_file link dotfiles_file_path
  yaml_file="${1:-}"

  [ ! -e "$yaml_file" ] && return 1

  link="$(dotbot::create_relative_link "${2:-}")"
  dotfiles_file_path="$(dotbot::get_value_of_key_in "link" "$link" "$yaml_file")"

  dotbot::exec_in_dotbot_path rm -i -f "$link"
  dotbot::exec_in_dotbot_path mv -i "$dotfiles_file_path" "$link"
  dotbot::exec_in_dotbot_path rmdir -p "$(dirname "$dotfiles_file_path")" >/dev/null 2>&1
  dotbot::delete_by_key_in "link" "$link" "$yaml_file"
}

# Not used but it worked
symlinks::restore_by_dotfile_file_path() {
  local yaml_file link dotfiles_file_path
  yaml_file="${1:-}"

  [ ! -e "$yaml_file" ] && return 1

  dotfiles_file_path="$(dotbot::create_relative_link "${2:-}")"
  link="$(dotbot::get_key_by_value_in "link" "$dotfiles_file_path" "$yaml_file")"

  if [ -n "$link" ]; then
    symlinks::restore_by_link "$yaml_file" "$link"
  fi
}

symlinks::edit_link_by_link_path() {
  local yaml_file old_link new_link link_value
  yaml_file="${1:-}"
  old_link="${2:-}"
  new_link="$(dotbot::create_relative_link "${3:-}")"

  [ ! -e "$yaml_file" ] && return 1

  link_value="$(dotbot::get_value_of_key_in "link" "$old_link" "$yaml_file")"
  # If link value has no value maybe user is given a link in working directory
  # so resolve what could be the relative to $DOTBOT_BASE_PATH directory to
  # check if the link exists
  if [ -z "${link_value:-}" ]; then
    old_link="$(dotbot::create_relative_link "$old_link")"
    link_value=${link_value:-$(dotbot::get_value_of_key_in "link" "$old_link" "$yaml_file")}
  fi

  if [ -n "$link_value" ]; then
    dotbot::delete_by_key_in "link" "$old_link" "$yaml_file"
    dotbot::add_or_edit_json_value_to_directive "link" "$new_link" "$link_value" "$yaml_file"
    dotbot::exec_in_dotbot_path rm -i -rf "$old_link"
    dotbot::exec_in_dotbot_path ln -s "$link_value" "$new_link"
    return 0
  fi

  return 1
}

symlinks::edit_link_by_dotfile_file_path() {
  local yaml_file dotfiles_file_path new_link old_link
  yaml_file="${1:-}"
  dotfiles_file_path="$(dotbot::create_relative_link "${2:-}")"
  new_link="$(dotbot::create_relative_link "${3:-}")"

  [ ! -e "$yaml_file" ] && return 1

  old_link="$(dotbot::get_key_by_value_in "link" "$dotfiles_file_path" "$yaml_file")"

  [ -n "$old_link" ] && symlinks::edit_link_by_link_path "$yaml_file" "$old_link" "$new_link"
}

# Delete by the provided link
# Executes "rm -i -rf" to the file in DOTBOT_BASE_PATH unless you pass more
# arguments which would be the argument to delete the file being the
# last param the link. Example
#   symlinks::delete_by_link "$yaml_file" "~/mylink" rm -i
# This will delete using "rm -i"
symlinks::delete_by_link() {
  local yaml_file link delete_cmd dotbot_file_path
  yaml_file="${1:-}"
  link="${2:-}"
  shift 2

  { [[ -z "$yaml_file" ]] || [[ -z "$link" ]] || [[ ! -f "$yaml_file" ]]; } && return 1

  if [[ -z "${*:-}" ]]; then
    delete_cmd=(rm -i -rf)
  else
    delete_cmd=("$@")
  fi

  link="$(dotbot::create_relative_link "$link")"
  dotbot_file_path="$(dotbot::get_value_of_key_in "link" "$link" "$yaml_file")"

  dotbot::delete_by_key_in "link" "$link" "$yaml_file"
  dotbot::exec_in_dotbot_path rm -i -rf "$link" # Link
  dotbot::exec_in_dotbot_path "${delete_cmd[@]}" "$dotbot_file_path" # The file
}

# Same as symlinks::delete_by_link but with the value of the link
symlinks::delete_by_dotbot_file_path() {
  local yaml_file link delete_cmd
  yaml_file="${1:-}"

  [ ! -e "$yaml_file" ] && return 1
  
  link="$(dotbot::get_key_by_value_in "link" "$(dotbot::create_relative_link "${2:-}")" "$yaml_file")"
  shift 2
  
  [ -n "$link" ] && symlinks::delete_by_link "$yaml_file" "$link" "$@"
}

symlinks::find() {
  local find_relative_path exclude_itself arguments preview
  arguments=()

  case "${1:-}" in
    --exclude)
      exclude_itself=true; shift
    ;;
    *)
      exclude_itself=false
    ;;
  esac

  find_relative_path="$DOTBOT_BASE_PATH/"

  if [ -e "$DOTBOT_BASE_PATH/${1:-}" ]; then
    find_relative_path="$find_relative_path${1:-}"; shift
  fi

  if $exclude_itself; then
    arguments+=(-not -path "$find_relative_path")
  fi

  arguments+=("$@")

  find "$find_relative_path" -not -iname ".*" "${arguments[@]}" -print0 -exec echo {} \; | while read -r item; do
    printf "%s\n" "${item/$find_relative_path\//}"
  done
}

symlinks::fzf() {
  local arguments preview multiple preview_cmd preview_path
  preview=false
  multiple=false
  preview_cmd='echo "'
  preview_path="$DOTBOT_BASE_PATH/"
  arguments=()

  while [ ${#:-0} -gt 0 ]; do
    case "${1:-}" in
      --preview)
        preview=true
        arguments+=("${1:-}"); shift
        arguments+=("${1:-}"); shift
        ;;
      -p|--preview-path)
        [ -d "${2:-}" ] && preview_path="${2:-}/"
        shift 2
        ;;
      -m|--multi)
        multiple=true
        arguments+=(--multi); shift

        if [[ "${1:-}" =~ '^[0-9]+$' ]]; then
          arguments+=("${1:-}"); shift
        fi
        ;;
      *)
        break 2
        ;;
    esac
  done

  arguments+=("$@")
  (! $preview) && $multiple && preview_cmd+='Press Tab+Shift to select multiple options.\n'

  if ! $preview; then
    preview_cmd+='Press Ctrl+C to exit with no selection.\n\nFile: {}\n\n--\n\n";'
    preview_cmd+="cat $preview_path{}"
    arguments+=(--preview)
    arguments+=("$preview_cmd")
  fi
  
  fzf "${arguments[@]}"
}
