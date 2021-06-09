registry::recipe_exists() {
  local -r recipe="${1:-}"
  local -r recipe_path="$DOTLY_PATH/scripts/package/recipes/$recipe.sh"
  [[ -z "$recipe" || ! -f "$recipe_path" ]] && return
  
  echo "$recipe_path"
}

registry::install() {
  local -r recipe="${1:-}"
  local -r install_command="${recipe}::install"
  local -r recipe_path="$(registry::recipe_exists "$recipe" || echo -n "")"
  
  [[ -z "$recipe" || -z "$recipe_path" || ! -f "$recipe_path" ]] && return 1

  dot::load_library "${recipe}.sh" "$(dirname "$recipe_path")"

  if [[ "$(command -v "$install_command")" ]]; then
    "$install_command"
    return $?
  fi

  return 1
}

registry::is_installed() {
  local -r recipe="${1:-}"
  local -r is_installed_command="${recipe}::is_installed"
  local -r recipe_path="$(registry::recipe_exists "$recipe")"
  [[ -z "$recipe" || -z "$recipe_path" || ! -f "$recipe_path" ]] && return 1
  dot::load_library "${recipe}.sh" "$(dirname "$recipe_path")"

  if [[ "$(command -v "$is_installed_command")" ]]; then
    "$is_installed_command"
    return $?
  fi

  return 1
}
