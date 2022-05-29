dotfiles::list_bash_files() {
  grep "#!/usr/bin/env bash" "$DOTFILES_PATH"/{bin,scripts,shell} -R | awk -F':' '{print $1}'
  find "$DOTLY_PATH"/{bin,scripts,shell} -type f -name "*.sh"
}
