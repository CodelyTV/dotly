yum::install() {
  yes | sudo yum install "$@"
}

yum::is_installed() {
  local package
  if [[ $# -gt 1 ]]; then
    for package in "$@"; do
      if ! sudo yum list --installed | grep -q "$package"; then
        return 1
      fi
    done
    
    return 0
  else
    [[ -n "${1:-}" ]] && sudo yum list --installed | grep -q "$2"
  fi
}
