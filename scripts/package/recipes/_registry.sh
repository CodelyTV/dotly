registry::recipe_exists() {
  local -r receipe="${1:-}"
  [[ -z "$receipe" ]] && return 1
  
  [[ -f "$DOTLY_PATH/scripts/package/recipes/$receipe.sh" ]] && echo "$DOTLY_PATH/scripts/package/recipes/$receipe.sh"
}

registry::install() {
  local -r receipe="${1:-}"
  [[ -z "$receipe" ]] && return 1
  file="$(registry::recipe_exists "$receipe" || echo -n "")"

  dot::get_script_src_path "${receipe}.sh" "$(dirname "$file")"
  
  declare -F "${receipe}::install" &>/dev/null && "${receipe}::install"
}
