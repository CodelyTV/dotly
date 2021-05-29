docpars::install() {
  platform::command_exists brew && brew install denisidoro/tools/docpars && return 0 || true

  script::depends_on rust
  export PATH="$HOME/.cargo/bin:$PATH"

  "$DOTLY_PATH/bin/dot" package add docpars --skip-recipe
}
