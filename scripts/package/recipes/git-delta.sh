git-delta::install() {
  "$DOTLY_PATH/bin/dot" package add git-delta --skip-recipe
}

git-delta::is_installed() {
  platform::command_exists delta
}
