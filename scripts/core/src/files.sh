#!/usr/bin/env bash

files::check_if_path_is_older() {
  local path_to_check number_of period date_file_path date_to_compare
  path_to_check="$1"
  number_of="${2:-0}"
  period="${3:-days}"
  date_file_path=$(command -p date -r "$path_to_check" +%s)

  if platform::is_bsd; then
    #shellcheck disable=SC2086
    date_to_compare=$(command -p date -j -v "-${number_of}${period:0:1}" +%s)
  else
    date_to_compare=$(command -p date --date="now - $number_of $period" +%s)
  fi

  [[ -e "$path_to_check" ]] && [[ $date_file_path -lt $date_to_compare ]]
}

#;
# files::backup_move_if_path_exists
# Move a file or directory if exists by appending a suffix and return its new location
# @param string file_path
# @param string suffix for the backup
# @return void
#"
files::backup_move_if_path_exists() {
  local file_path bk_suffix bk_file_path
  file_path="$(realpath -q -m "${1/#\~/$HOME}")"
  bk_suffix="${2:-$(date +%s)}"
  bk_file_path="$file_path.${bk_suffix}"

  if [[ -n "$file_path" ]] && [[ -e "$file_path" ]] && [[ ! -L "$file_path" ]]; then
    mv "$file_path" "$bk_file_path" && echo "$bk_file_path"
  fi
}

#;
# files::fzf()
# Show fzf but can include libraries in a easier way
#;
files::fzf() {
  local arguments preview multiple preview_args preview_path libraries_to_load dot_lib
  preview=false
  multiple=false
  preview_args=()
  preview_path=""
  arguments=()

  while [ ${#:-0} -gt 0 ]; do
    case "${1:-}" in
      --default-preview)
        preview=true
        shift
        ;;
      --preview)
        preview=true
        preview_args+=("$2;")
        shift 2
        ;;
      -p | --preview-path)
        #shellcheck disable=SC2034
        [[ -d "${2:-}" ]] && preview_path="${2:-}/"
        shift 2
        ;;
      -m | --multi)
        multiple=true
        arguments+=(--multi)
        shift

        if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
          arguments+=("${1:-}")
          shift
        fi
        ;;
      -c | --sloth-core | --dotly-core)
        # Load core .Sloth libraries
        preview=true

        if [[ ${#preview_args[@]} -gt 0 ]]; then
          preview_args=(
            ". \"${SLOTH_PATH:-}/scripts/core/src/_main.sh\";"
            "${preview_args[@]};"
          )
        else
          preview_args=(
            ". \"${SLOTH_PATH:-}/scripts/core/src/_main.sh\";"
          )
        fi
        shift
        ;;
      --script-libs)
        # Load the same libraries that are currently loaded when call fzf
        preview=true
        libraries_to_load=()
        for dot_lib in "${SCRIPT_LOADED_LIBS[@]}"; do
          [[ ! -f "$dot_lib" ]] && continue
          libraries_to_load+=(
            ". \"$dot_lib\";"
          )
        done

        preview_args=(
          ". \"${SLOTH_PATH:-}/scripts/core/src/_main.sh\";"
          "${libraries_to_load[@]}"
          "${preview_args[@]}"
        )
        shift
        ;;
      *)
        break 2
        ;;
    esac
  done

  # Default preview
  if $preview && [[ -z "${preview_args[*]}" ]]; then
    $multiple && preview_args+=(
      'echo "Press Tab+Shift to select multiple options.";'
    )
    #shellcheck disable=SC2016
    preview_args+=(
      'file={};'
      'file_path=\"${preview_path:-}$file\";'
      'echo "Press Ctrl+C to exit with no selection.\n";'
      'echo "File: $file_path";'
      'echo "\n----";'
      '[[ -f "$file_path" ]] && cat "$file_path";'
    )
  fi

  # Add the arguments
  if $preview && [[ -n "${preview_args[*]:-}" ]]; then
    arguments+=(
      --preview
      "${preview_args[*]}"
    )
  fi
  arguments+=("$@")

  fzf "${arguments[@]}"
}
