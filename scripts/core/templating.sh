#!/usr/bin/env bash

#
# This set of functions are used for file/strings advanced templating
#
# Author: Gabriel Trabanco
# This was done, using "dot dotfiles create" as reference

# templating::replace_var [<file_path>|<template_string>] <var_name> [value1 [... [valueN]]
# echo "template string" | templating::replace_var <var_name> [value1 [... [valueN]]
#
# echo "Those are my family names: XXX_FAMILY_NAMES_XXX" |\
#   templating::replace_var family-names Miguel Manuel
#
# This will print:
#   "Those are my family names: Miguel Manuel"
templating::replace_var () {
  local any
  if (( $# % 2 == 0 )); then
    any="$(</dev/stdin)"
  elif [ $# -gt 0 ]; then
    any="$1"; shift
  fi

  local var_name="XXX_$(str::to_upper "$1" | tr '-' '_')_XXX"; shift
  local value="$1"; shift

  # Replacer
  if [[ -f $any ]]; then
    echo "Using sed: $var_name = $value"
    sed -i -e "s|${var_name}|${value}|g" "$any"
  else
    echo "Using var"
    echo "${any//$var_name/$value}"
  fi
}

# This is the unique function that only allow piped template
#
# templating::replace_var_join <var_name> <glue> [value1 [... [valueN]]
#
# echo "Those are common names in spain: XXX_NAMES_XXX" |\
#   templating::replace_var_join names ', ' Manuel Jorge David Luis Pedro
#
# This will print:
#   "Those are common names in spain: Manuel, Jorge, David, Luis, Pedro"
#
templating::replace_var_join() {
  local input="$(</dev/stdin)"
  local var_name="$1"; shift
  local glue="$1"; shift
  local joined_str="$(str::join "$glue" "$@")"
  local IFS=''
  if [[ -f "$input" ]]; then
    templating::replace_var "$input" "$var_name" "$joined_str"
  else
    echo "$input" | templating::replace_var "$var_name" "$joined_str"
  fi
}

# templating::replace "XXX_NAME_XXX <XXX_EMAIL_ADDRESS_XXX>" --name=Gabriel --email-address=no-email@example.com
# templating::replace "XXX_NAME_XXX <XXX_EMAIL_ADDRESS_XXX>" --name Gabriel --email-address no-email@example.com
# templating::replace "XXX_NAME_XXX <XXX_EMAIL_ADDRESS_XXX>" name Gabriel email-address no-email@example.com
# echo "XXX_NAME_XXX <XXX_EMAIL_ADDRESS_XXX>" |\
#   templating::replace name Gabriel email-address no-email@example.com
# templating::replace /path/to/file --name=Gabriel --email-address=no-email@example.com
# templating::replace /path/to/file --name Gabriel --email-address no-email@example.com
# templating::replace /path/to/file name Gabriel email-address no-email@example.com

#
# This will print
#   "Gabriel <no-email@example.com>"
#
templating::replace() {
  local var_name var_value output
  case "$1" in
    --*=*|--*)
      output=$(</dev/stdin)
      ;;
    *)
      output="$1"
      shift
      ;;
  esac

  while [ $# -gt 0 ]; do
    case $1 in
      --*=*)
        var_name="$(echo $1 | awk -F '=' '{print $1}' | sed 's/^\-\-//')";
        var_value="$(echo $1 | awk -F '=' '{print $2}')";
        shift
        ;;
      --*)
        var_name="$(echo $1 | sed 's/\-\-//')"; shift
        var_value="${1:-}"; shift
        ;;
      *)
        var_name="$1"; shift
        var_value="${1:-}"; shift
        ;;
    esac

    if [[ -f "$output" ]]; then
      templating::replace_var "$output" "$var_name" "$var_value"
    else
      output="$(echo "$output" | templating::replace_var "$var_name" "$var_value")"
    fi
  done

  if [[ -f "$output" ]]; then
    cat "$output"
  else
    echo "$output"
  fi
}

# Modify from current bash file like exports.sh a given varible by the value
# if the variable does not exists add it at the first line of the file
# Example:
#    templating::modify_bash_file_variable "$DOTFILES_PATH/shell/exports.sh" "DOTFILES_PATH" "~/.new-dotfiles"
templating::modify_bash_file_variable() {
  local var_name file_line file_path
  file_path="${1:-}"
  var_name="${2:-}"
  shift 2
  value="${*:-}"

  if [[ -n "$file_path" ]] && [[ -f "$file_path" ]] && [[ -n "$var_name" ]]; then
    file_line="$(grep --line-number "\s*export\s*$var_name\s*=." "$file_path" | awk -F ':' '{print $1}' | head -n 1)"
    [[ -n "$file_line" ]] && sed -i "${file_line:-1}d" "$file_path"
    sed -i "${file_line:-1}i export $var_name=\"$value\"" "$file_path"
  fi
}
