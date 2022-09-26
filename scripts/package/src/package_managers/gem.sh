gem::update_all() {
	outdated=$(gem outdated)

	if [ -n "$outdated" ]; then
		echo "$outdated" | while IFS= read -r outdated_app; do
			package=$(echo "$outdated_app" | awk '{print $1}')
			current_version=$(echo "$outdated_app" | awk '{print $2}' | sed 's/(//g')
			new_version=$(echo "$outdated_app" | awk '{print $4}' | sed 's/)//g')

			output::write "♦️  $package"
			output::write "└ $current_version -> $new_version"
			output::empty_line

			gem update "$package" 2>&1 | log::file "Updating gem app: $package"
		done
	else
		output::answer "Already up-to-date"
	fi
}
