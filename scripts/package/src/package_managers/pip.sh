pip::update_all() {
	outdated=$(pip3 list --outdated | tail -n +3)

	if [ -n "$outdated" ]; then
		echo "$outdated" | while IFS= read -r outdated_app; do
			package=$(echo "$outdated_app" | awk '{print $1}')
			current_version=$(echo "$outdated_app" | awk '{print $2}')
			new_version=$(echo "$outdated_app" | awk '{print $3}')
			info=$(pip3 show "$package")

			summary=$(echo "$info" | head -n3 | tail -n1 | sed 's/Summary: //g')
			url=$(echo "$info" | head -n4 | tail -n1 | sed 's/Home-page: //g')

			output::write "🐍 $package"
			output::write "├ $current_version -> $new_version"
			output::write "├ $summary"
			output::write "└ $url"
			output::empty_line

			pip3 install -U "$package" 2>&1 | log::file "Updating pip app: $package"
		done
	else
		output::answer "Already up-to-date"
	fi
}
