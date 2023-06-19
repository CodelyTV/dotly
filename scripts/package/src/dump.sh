source "$DOTLY_PATH/scripts/core/platform.sh"

if platform::is_macos; then
	HOMEBREW_DUMP_FILE_PATH="$DOTFILES_PATH/os/mac/brew/Brewfile"
elif platform::is_linux; then
	HOMEBREW_DUMP_FILE_PATH="$DOTFILES_PATH/os/linux/brew/Brewfile"
fi

APT_DUMP_FILE_PATH="$DOTFILES_PATH/os/linux/apt/packages.txt"
CODE_DUMP_FILE_PATH="$DOTFILES_PATH/editors/code/extensions.txt"
NPM_DUMP_FILE_PATH="$DOTFILES_PATH/langs/js/global_modules.txt"
PACMAN_DUMP_FILE_PATH="$DOTFILES_PATH/os/linux/pacman/packages.txt"
PYTHON_DUMP_FILE_PATH="$DOTFILES_PATH/langs/python/requirements.txt"
SNAP_DUMP_FILE_PATH="$DOTFILES_PATH/os/linux/snap/packages.txt"
VOLTA_DUMP_FILE_PATH="$DOTFILES_PATH/langs/js/volta_dependencies.txt"
WINGET_DUMP_FILE_PATH="$DOTFILES_PATH/os/windows/winget.output"
ASDF_DUMP_FILE_PATH="$DOTFILES_PATH/langs/sdk/asdf.txt"

package::brew_dump() {
	if platform::is_macos; then
		mkdir -p "$DOTFILES_PATH/os/mac/brew"
	else
		mkdir -p "$DOTFILES_PATH/os/linux/brew"
	fi

	brew bundle dump --file="$HOMEBREW_DUMP_FILE_PATH" --force
	brew bundle --file="$HOMEBREW_DUMP_FILE_PATH" --force cleanup
}

package::brew_import() {
	if [ -f "$HOMEBREW_DUMP_FILE_PATH" ]; then
		brew bundle install --file="$HOMEBREW_DUMP_FILE_PATH"
	fi
}

package::apt_dump() {
	mkdir -p "$DOTFILES_PATH/os/linux/apt"

	apt-mark showmanual >"$APT_DUMP_FILE_PATH"
}

package::apt_import() {
	if [ -f "$APT_DUMP_FILE_PATH" ]; then
		xargs sudo apt-get install -y <"$APT_DUMP_FILE_PATH"
	fi
}

package::code_dump() {
	mkdir -p "$DOTFILES_PATH/editors/code"

	code --list-extensions >"$CODE_DUMP_FILE_PATH"
}

package::code_import() {
	mkdir -p "$DOTFILES_PATH/editors/code"

	xargs -I_ code --install-extension _ --force <"$CODE_DUMP_FILE_PATH"
}

package::snap_dump() {
	mkdir -p "$DOTFILES_PATH/os/linux/snap"

	snap list | tail -n +2 | awk '{ print $1 }' >"$SNAP_DUMP_FILE_PATH"
}

package::snap_import() {
	if [ -f "$SNAP_DUMP_FILE_PATH" ]; then
		xargs -I_ sudo snap install "_" <"$SNAP_DUMP_FILE_PATH"
	fi
}

package::python_dump() {
	mkdir -p "$DOTFILES_PATH/langs/python"

	pip3 freeze >"$PYTHON_DUMP_FILE_PATH"
}

package::python_import() {
	if [ -f "$PYTHON_DUMP_FILE_PATH" ]; then
		pip3 install -r "$PYTHON_DUMP_FILE_PATH"
	fi
}

package::npm_dump() {
	mkdir -p "$DOTFILES_PATH/langs/js"

	ls -1 $HOMEBREW_PREFIX/lib/node_modules | grep -v npm >"$NPM_DUMP_FILE_PATH"
}

package::npm_import() {
	if [ -f "$NPM_DUMP_FILE_PATH" ]; then
		xargs -I_ npm install -g "_" <"$NPM_DUMP_FILE_PATH"
	fi
}

package::volta_dump() {
	mkdir -p "$DOTFILES_PATH/langs/js"

	volta list all --format plain | awk '{print $2}' >"$VOLTA_DUMP_FILE_PATH"
}

package::volta_import() {
	if [ -f "$VOLTA_DUMP_FILE_PATH" ]; then
		xargs -I_ volta install "_" <"$VOLTA_DUMP_FILE_PATH"
	fi
}

package::winget_dump() {
	mkdir -p "$DOTFILES_PATH/os/windows"

	winget.exe export -o "$WINGET_DUMP_FILE_PATH" >/dev/null 2>&1
}

package::winget_import() {
	winget.exe import -i "$WINGET_DUMP_FILE_PATH"
}
package::pacman_dump() {
	mkdir -p "$DOTFILES_PATH/os/linux/pacman"

	pacman -Qm | awk '{print $1}' >"$PACMAN_DUMP_FILE_PATH"
}

package::pacman_import() {
	if [ -f "$PACMAN_DUMP_FILE_PATH" ]; then
		yay -s "$(cat $PACMAN_DUMP_FILE_PATH)"
	fi
}

package::asdf_dump() {
  mkdir -p "$DOTFILES_PATH/langs/sdk"
  echo -n >$ASDF_DUMP_FILE_PATH

  for plug in $(asdf plugin-list); do
    for ver in $(asdf list $plug | awk '{print $1; }'); do
      if [ -z "$ver" ]; then
        echo "No versions installed for $plug"
      else
        echo "$plug $ver" >>$ASDF_DUMP_FILE_PATH
      fi
    done
  done
}

package::asdf_import() {
  if [ -f "$ASDF_DUMP_FILE_PATH" ]; then
    for plug in $(cat $ASDF_DUMP_FILE_PATH | awk '{ print $1 }' | uniq); do
      echo "asdf plugin-add $plug"
    done
    while read -r line; do
      plug=$(echo $line | awk '{print $1; }')
      ver=$(echo $line | awk '{print $2; }')
      if [[ $ver == \** ]]; then
        ver=${ver:1}
        echo "asdf install $plug $ver"
        echo "asdf global $plug $ver"
      else
        echo "asdf install $plug $ver"
      fi
    done <$ASDF_DUMP_FILE_PATH
  fi
}
