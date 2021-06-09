cargo::install() {
  cargo install "$@"
}

cargo::is_installed() {
  local package
  if [[ $# -gt 1 ]]; then
    for package in "$@"; do
      if ! cargo install --list | grep -q "$package"; then
        return 1
      fi
    done
    
    return 0
  else
    [[ -n "${1:-}" ]] && cargo install --list | grep -q "${1:-}"
  fi
}
