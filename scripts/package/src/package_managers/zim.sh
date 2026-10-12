# shellcheck shell=bash
# Zim is optional: a zsh setup without it never sets ZIM_HOME.
zim::is_configured() {
	[[ -n ${ZIM_HOME:-} && -f "$ZIM_HOME/zimfw.zsh" ]]
}

zim::update_all() {
	zsh "$ZIM_HOME/zimfw.zsh" upgrade 2>&1 | log::file "Upgrading Zim" &&
		zsh "$ZIM_HOME/zimfw.zsh" update 2>&1 | log::file "Updating Zim" &&
		output::answer "Done"
}
