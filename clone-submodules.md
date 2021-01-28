git clone --recurse-submodules --remote-submodules keybase://private/gtrabanco/dotfiles .dotfiles

git submodule update --init --recursive

rm /tmp/unifi_sysvinit_all.deb &> /dev/null; curl -o "/tmp/unifi_sysvinit_all.deb" "$pkg_url" && dpkg -i /tmp/unifi_sysvinit_all.deb && rm /tmp/unifi_sysvinit_all.deb

[submodule "modules/zimfw"]
	path = modules/zimfw
	url = https://github.com/zimfw/zimfw.git
	ignore = dirty
[submodule "modules/dotbot"]
	path = modules/dotbot
	url = https://github.com/anishathalye/dotbot.git
	ignore = dirty
[submodule "modules/z"]
	path = modules/z
	url = https://github.com/rupa/z.git
	ignore = dirty
