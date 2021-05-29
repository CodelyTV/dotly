docpars::install(){
    log::append "Installing docpars"

   platform::command_exists brew && brew install denisidoro/tools/docpars && return 0 || true

    log::append "Not installed in brew"

   script::depends_on rust

   "$DOTLY_PATH/bin/dot" package add docpars --skip-recipe
}
