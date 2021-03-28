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

  local var_name="XXX_$(str::to_upper $1 | tr '-' '_')_XXX"; shift
  local values=($@); shift

  # Replacer
  if [[ -f $any ]]; then
    sed -i -e "s|$var_name|$values|g" "$any"
  else
    echo "$any" | sed -e "s|$var_name|$values|g"
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
  echo $input | templating::replace_var "$var_name" "$joined_str"
}

# templating::replace "XXX_NAME_XXX <XXX_EMAIL_ADDRESS_XXX>" --name=Gabriel --email-address=no-email@example.com
# templating::replace "XXX_NAME_XXX <XXX_EMAIL_ADDRESS_XXX>" --name Gabriel --email-address no-email@example.com
# templating::replace "XXX_NAME_XXX <XXX_EMAIL_ADDRESS_XXX>" name Gabriel email-address no-email@example.com
# echo "XXX_NAME_XXX <XXX_EMAIL_ADDRESS_XXX>" |\
#   templating::replace name Gabriel email-address no-email@example.com
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
      if [[ -f "$1" ]]; then
        output="$(cat $1)"
      else
        output="$1"
      fi
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

    output="$(templating::replace_var "$output" "$var_name" "$var_value")"
  done

  echo "$output"
}

#
# This will do the same as "templating::replace" but first param should
# be a path to existing file and will replace all passed vars
# 
# templating::file /path/to/file --name=Gabriel --email-address=no-email@example.com
# templating::file /path/to/file --name Gabriel --email-address no-email@example.com
# templating::file /path/to/file name Gabriel email-address no-email@example.com
#
templating::file() {
  local file="$1"; shift
  local IFS="\n"
  local templated
  templated=("$(cat "$file" | templating::replace "$@")")

  echo ${templated[@]} > "$file"
}