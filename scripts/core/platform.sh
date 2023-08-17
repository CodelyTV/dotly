platform::command_exists() {
	type "$1" >/dev/null 2>&1
}

platform::is_macos() {
	[[ $(uname -s) == "Darwin" ]]
}

platform::is_macos_arm() {
	[[ $(uname -p) == "arm" ]]
}

platform::is_linux() {
	[[ $(uname -s) == "Linux" ]]
}

platform::is_wsl() {
	grep -qEi "(Microsoft|WSL|microsoft)" /proc/version &>/dev/null
}

platform::wsl_home_path() {
	wslpath "$(wslvar USERPROFILE 2>/dev/null)"
}

platform::is_default_macos_ruby() {
	current_ruby_path=$(command -v ruby)
	default_ruby_path="/usr/bin/ruby"

	[[ $current_ruby_path == "$default_ruby_path" ]]
}
