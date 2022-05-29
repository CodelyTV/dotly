cargo::update_all() {
  cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ' | xargs -n1 cargo install
  output::answer "Done"
}
