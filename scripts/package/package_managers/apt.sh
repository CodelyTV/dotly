apt::install() {
  sudo apt-get -y install "$@"
}

apt::is_installed() {
  apt list -a "$@" | grep -q 'installed'
}
