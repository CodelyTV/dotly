if ! ${DOT_REGISTRY_SOURCED:-false}; then
  for file in $DOTLY_PATH/scripts/package/recipes/{docpars,cargo}.sh; do
    source "$file"
  done
  unset file

  readonly DOT_REGISTRY_SOURCED=true
fi

registry::install() {
  case "$1" in
  docpars) docpars::install ;;
  cargo) cargo::install ;;
  *) return 1 ;;
  esac
}
