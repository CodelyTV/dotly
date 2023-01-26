docpars::install() {
	platform::command_exists brew && brew install denisidoro/tools/docpars && return 0 || true

	script::depends_on cargo

	"$DOTLY_PATH/bin/dot" package add docpars --skip-recipe
}

docpars::is_installed() {
	platform::command_exists docpars
}
