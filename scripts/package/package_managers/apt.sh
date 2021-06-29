apt::install() {
  sudo apt-get -y install "$@"
}

apt::is_installed() {
  #apt list -a "$@" | grep -q 'installed'
  [[ -n "${1:-}" ]] && dpkg -l | awk '{print $2}' | grep -q ^"${1:-}"$
}
