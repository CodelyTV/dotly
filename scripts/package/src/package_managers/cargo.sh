cargo::update_all() {
	# A plain `xargs cargo install` still runs once with no arguments when no crate is
	# installed, and `cargo install` alone tries to install the current directory.
	cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ' |
		while read -r cargo_package; do
			cargo install "$cargo_package"
		done
	output::answer "Done"
}
