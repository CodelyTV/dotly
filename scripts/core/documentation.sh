docs::parse() {
	if ! platform::command_exists docpars; then
		output::error "You need to have docpars installed in order to use dotly"
		output::solution "Run this command to install it:"
		output::solution "DOTLY_INSTALLER=true dot package add docpars"

		exit 1
	fi

	eval "$(docpars -h "$(grep "^##?" "$0" | cut -c 5-)" : "$@")"
}
