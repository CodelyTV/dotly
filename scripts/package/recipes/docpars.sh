docpars::install() {
	# The Homebrew formula only ships an x86_64 binary, which doesn't run without Rosetta
	if platform::is_macos_arm; then
		script::depends_on cargo
		cargo install docpars
		return
	fi

	platform::command_exists brew && brew install denisidoro/tools/docpars && return 0 || true

	script::depends_on cargo

	"$DOTLY_PATH/bin/dot" package add docpars --skip-recipe
}

docpars::is_installed() {
	platform::command_exists docpars
}
