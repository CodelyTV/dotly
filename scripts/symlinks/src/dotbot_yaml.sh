#!/usr/bin/env bash
#shellcheck disable=SC2016

DOTBOT_BASE_PATH="${DOTBOT_BASE_PATH:-$DOTFILES_PATH}"
DOTBOT_DEFAULT_YAML_FILES_BASE_PATH="${DOTBOT_DEFAULT_YAML_FILES_BASE_PATH:-$DOTBOT_BASE_PATH/symlinks}"

dotbot::yaml_file_path() {
  local yaml_file_posibilities yaml_file yaml_dir_path
  yaml_file="${1:-}"
  yaml_dir_path="${2:-$DOTBOT_DEFAULT_YAML_FILES_BASE_PATH}"
  yaml_file_posibilities=(
    "$yaml_file"
    "$yaml_file.yaml"
    "$yaml_file.yml"
    "$yaml_dir_path/$yaml_file"
    "$yaml_dir_path/$yaml_file.yaml"
    "$yaml_dir_path/$yaml_file.yml"
  )

  for f in "${yaml_file_posibilities[@]}" ; do
    [[ -f "$f" ]] && [[ -w "$f" ]] && yaml_file="$f" && break
  done

  if [[ ! -w "$yaml_file" ]]; then
    yaml_file=""
  fi

  echo "$yaml_file" && return 0
}

dotbot::exec_in_dotbot_path() {
  local return_code
  [[ -z "$DOTBOT_BASE_PATH" ]] && [[ -d "$DOTBOT_BASE_PATH" ]] && output::error "Fatal error $DOTBOT_BASE_PATH not found" && exit 1
  cd "$DOTBOT_BASE_PATH" || return 1
  eval "$@"
  return_code=$?
  return ${return_code:-0}
}

# Return a path to store in the dotbot yaml file
dotbot::relative_path() {
  local link_path
  [[ -z "${1:-}" ]] && return

  link_path="${1//\~/$HOME}"
  link_path="$(realpath -qms --relative-base="$DOTBOT_BASE_PATH" "$link_path" 2>/dev/null || true)"
  link_path="${link_path//$HOME/~}"
  echo "$link_path"
}

# Return a path to do any stuff with the file
dotbot::realpath() {
  local file_path
  [[ -z "${1:-}" ]] && return

  file_path="${1//\~/$HOME}"
  dotbot::exec_in_dotbot_path realpath -qms "\"$file_path\"" 2>/dev/null || true
}

# Move files by converting values to relative in dotbot or don't
dotbot::mv() {
  local from_argn from to_argn to _args relative_dotbot
  relative_dotbot=false
  while true; do
    case "$1" in
      --relative-dotbot)
        relative_dotbot=true
        shift
        ;;
      *)
        break 2
        ;;
    esac
  done
  [[ $# -lt 2 ]] && return 1
  _args=( "$@" )
  from_argn=$(( ${#_args[@]:-2} - 2 ))
  to_argn=$(( ${#_args[@]:-2} - 1 ))
  from="$(dotbot::realpath "${_args[$from_argn]}")"
  to="$(dotbot::realpath"${_args[$to_argn]}")"
  unset "_args[$from_argn]" "_args[$to_argn]"
  
  if [[ -e "$from" ]]; then
    # TODO Undo in production
    echo mv "${_args[@]}" "$from" "$to"
  else
    return 1
  fi
}

# Remove files by converting or not the path to relative to DOTBOT_BASE_PATH
dotbot::rm() {
  local file_argn file_path _args rm_cmd relative_dotbot
  rm_cmd="rm"
  relative_dotbot=false
  while true; do
    case "$1" in
      --rm-cmd)
        rm_cmd="${2:-}"
        shift 2
        ;;
      --relative-dotbot)
        relative_dotbot=true
        shift
        ;;
      *)
        break 2
        ;;
    esac
  done
  [[ $# -lt 2 ]] && return 1
  _args=( "$@" )
  file_argn=$(( ${#_args[@]:-1} - 1 ))
  file_path="$(dotbot::realpath "${_args[$file_argn]}")"
  unset "_args[$file_argn]"

  # TODO Undo in production
  if [[ -e "$file_path" ]]; then
    #shellcheck disable=SC2086
    echo $rm_cmd "${_args[@]}" "\"$file_path\""
  fi
}

# Save json as yaml
dotbot::save_as_yaml() {
  local file_path input
  file_path="${1:-}"

  [[ -z "$file_path" ]] && return 1
  eval mkdir -p "$(dirname "$file_path")"
  touch "$file_path"
  json::to_yaml </dev/stdin | sponge "$file_path"
}

# Use jq with yaml file or stdin yaml content
# Last argument is the file if stdin is clean
dotbot::jq_yaml_file() {
  local _args file lastarg input
  _args=( "$@" )
  lastarg=$(( ${#:-1} - 1 ))

  if [[ -t 0 ]]; then
    file="${_args[$lastarg]}"
    unset "_args[$lastarg]"
    if json::is_valid "$file"; then
      jq "${_args[@]}" "$file"
    else
      yq "${_args[@]}" "$file"
    fi
  else
    input="$(</dev/stdin)"
    if echo "$input" | json::is_valid; then
      echo "$input" | jq "$@"
    else
      echo "$input" | yq "$@"
    fi
  fi
}

# Use jq with yaml file and save. Last argument is
# the file where to save (and read if not stdin)
dotbot::jq_yaml_file_save() {
  local _args file lastarg
  _args=( "$@" )
  lastarg=$(( ${#:-1} - 1 ))
  file="${_args[$lastarg]}"
  unset "_args[$lastarg]"

  if [[ -t 0 ]]; then
    dotbot::jq_yaml_file "$@" | dotbot::save_as_yaml "$file"
  else
    dotbot::jq_yaml_file "${_args[@]}" </dev/stdin | dotbot::save_as_yaml "$file"
  fi
}

# Get all keys of a dotbot directive
dotbot::get_all_keys_in() {
  local _jq_query _jq_args
  _jq_query='.[] | select(has($directive)) | .[] | keys[] | values'
  _jq_args=(-r --arg directive "${1:-}" "$_jq_query")

  if [[ -t 0 ]]; then
    dotbot::jq_yaml_file "${_jq_args[@]}" "${2:-}"
  else
    dotbot::jq_yaml_file "${_jq_args[@]}" < /dev/stdin
  fi
}

# Get all values of a dotbot directive
dotbot::get_all_values_in() {
  local _jq_query _jq_args
  _jq_query='.[] | select(has($directive)) | .[] | .[] | values'
  _jq_args=(-r --arg directive "${1:-}" "$_jq_query")

  if [[ -t 0 ]]; then
    dotbot::jq_yaml_file "${_jq_args[@]}" "${2:-}"
  else
    dotbot::jq_yaml_file "${_jq_args[@]}" < /dev/stdin
  fi
}

# Look for a key in a directive
dotbot::get_value_of_key_in() {
  local _jq_query _jq_args
  _jq_args=(-r --arg directive "${1:-}")

  if [[ "${2:-}" =~ ^[0-9]+$ ]]; then
    # Check for number key in array
    _jq_query='.[] | select(has($directive)) | .[$directive] | arrays | .[$key] | values'
    _jq_args+=(--argjson)
  else
    # Check for number
    _jq_query='.[] | select(has($directive)) | .[$directive] | objects | .[$key] | values'
    _jq_args+=(--arg)
  fi

  _jq_args+=(key "${2:-}" "$_jq_query")

  if [[ -t 0 ]]; then
    dotbot::jq_yaml_file "${_jq_args[@]}" "${3:-}"
  else
    dotbot::jq_yaml_file "${_jq_args[@]}" < /dev/stdin
  fi
}

dotbot::get_key_by_value_in() {
  local input _jq_query _jq_query_type _jq_args
  _jq_args=(-r --arg directive "${1:-}" --arg value "${2:-}")
  _jq_query_type='.[] | select(has($directive)) | .[$directive] | values | type'

  [[ -t 0 ]] && input="$(cat "${3:-}")" || input="$(</dev/stdin)"

  case "$(echo "$input" | dotbot::jq_yaml_file "${_jq_args[@]}" "$_jq_query_type")" in
    object)
      _jq_query='.[] | select(has($directive)) | .[$directive] | map_values(select(. == $value)) | keys[] | values'
      ;;
    array)
      _jq_query='.[] | select(has($directive)) | .[$directive] | select(index($value)) | index($value) | values'
      ;;
    *)
      return 1
      ;;
  esac

  _jq_args+=("$_jq_query")

  echo "$input" | dotbot::jq_yaml_file "${_jq_args[@]}"
}

# If you pipe something it will be used as yaml and save in the file, if only
# pass the file it will read from that file and save changes in it.
# If you do not provide a file to read/save it will read from piped value and
# output to stdout.
# dotbot::add_or_edit_value_to_directive directive json_value [file_to_read_and_save]
# dotbot::add_or_edit_value_to_directive directive object_key object_value [file_to_read_and_save]
#
# The json_value should be always a valid json (quoted string, right quoted object....), if is a string
# in array, should be an array to combine...
dotbot::add_or_edit_json_value_to_directive() {
  local input _jq_query _jq_args directive value check_directive_exists
  directive="${1:-}"

  if [[ -t 0 ]]; then
    if [[ $# -gt 3 ]]; then
      value="{\"${2:-}\": \"${3:-}\"}"
      file="${4:-}"
    else
      value="${2:-}"
      file="${3:-}"
    fi

    [[ ! -e "$file" ]] && return 1
    input="$(cat "$file")"
  else
    if [[ $# -gt 2 ]]; then
      value="{\"${2:-}\": \"${3:-}\"}"
      file="${4:-}"
    else
      value="${2:-}"
      file="${3:-}"
    fi
    input="$(</dev/stdin)"
  fi

  check_directive_exists=$(echo "$input" | dotbot::get_all_keys_in "$directive")

  if [[ -n "$check_directive_exists" ]]; then
    _jq_query='. | (.[] | .[$directive] | values) as $currentvalues | if select($currentvalues | values) then del(.[] | select(has($directive))) | . += [{($directive): ($currentvalues + $value)}] else . end'
  else
    _jq_query='. + [{($directive): $value}]'
  fi

  _jq_args=(-r --arg directive "$directive" --argjson value "$value" "$_jq_query")

  if [[ -n "$file" ]]; then
    echo "$input" | dotbot::jq_yaml_file_save "${_jq_args[@]}" "$file"
  else
    echo "$input" | dotbot::jq_yaml_file "${_jq_args[@]}"
  fi
}

# Delete directly a directive in yaml dotbot file
dotbot::delete_directive() {
  local _jq_query _jq_args
  _jq_query='del(.[] | select(has($directive)))'
  _jq_args=(-r --arg directive "${1:-}" "$_jq_query")

  if [[ -t 0 ]] && [[ -n "${3:-}" ]]; then
    dotbot::jq_yaml_file_save -r "${_jq_args[@]}" "${3:-}" < "${2:-}"
  elif [[ -t 0 ]]; then
    dotbot::jq_yaml_file_save -r "${_jq_args[@]}" "${2:-}"
  elif [[ -n "${2:-}" ]]; then
    dotbot::jq_yaml_file_save -r "${_jq_args[@]}" "${2:-}" < /dev/stdin
  else
    dotbot::jq_yaml_file -r "${_jq_args[@]}" < /dev/stdin
  fi
}

# Delete object in colection
dotbot::delete_by_key_in() {
  local _jq_query _jq_args directive key_to_delete file_to_read file_to_save
  directive="${1:-}"
  key_to_delete="${2:-}"
  file_to_write="${4:-${3:-}}"
  file_to_read="${3:-}"
  _jq_args=(-r --arg directive "$directive")

  if [[ "$key_to_delete" =~ ^[0-9]+$ ]]; then
    # Check for number key in array
    _jq_query='del(.[] | select(has($directive)) | .[$directive] | arrays | .[$key])'
    _jq_args+=(--argjson)
  else
    # Check for number
    _jq_query='del(.[] | select(has($directive)) | .[$directive] | objects | .[$key])'
    _jq_args+=(--arg)
  fi
  
  _jq_args+=(key "$key_to_delete" "$_jq_query")

  if [[ -t 0 ]] && [[ -n "${4:-}" ]]; then
    dotbot::jq_yaml_file_save "${_jq_args[@]}" "$file_to_write" < "$file_to_read"
  elif [[ -t 0 ]]; then
    # Fire to read is also to write
    [[ -e "$file_to_write" ]] && dotbot::jq_yaml_file_save "${_jq_args[@]}" "$file_to_write"
  else
    # File to write
    {
      [[ -n "$file_to_read" ]] &&\
      dotbot::jq_yaml_file_save "${_jq_args[@]}" "$file_to_write" < /dev/stdin;
      
    } || dotbot::jq_yaml_file "${_jq_args[@]}" < /dev/stdin
  fi
}

# Delete object in colection
dotbot::delete_by_value_in() {
  local input file_save directive value_to_delete key_to_delete
  directive="${1:-}"
  value_to_delete="${2:-}"
  file_save="${4:-${3:-}}"
  
  if [[ -t 0 ]]; then
    input="$(cat "${3:-}")"
  else
    input="$(</dev/stdin)"
  fi

  key_to_delete="$(echo "$input" | dotbot::get_key_by_value_in "$directive" "$value_to_delete")"

  echo "$input" | dotbot::delete_by_key_in "$directive" "$key_to_delete" "$file_save"
}
