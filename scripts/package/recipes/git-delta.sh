git-delta::install() {
  "$DOTLY_PATH/bin/dot" package add git-delta --skip-recipe

  ln -s "$(command -v delta)" "$DOTFILES_PATH/bin/git-delta"
}
