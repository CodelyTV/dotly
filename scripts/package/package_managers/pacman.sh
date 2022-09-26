pacman::install() {
	if platform::command_exists yay; then
		sudo yay -S --noconfirm "$@"
	else
		sudo pacman -S --noconfirm "$@"
	fi
}
