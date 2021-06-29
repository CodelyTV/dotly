dotly::list_bash_files() {
  grep "#!/usr/bin/env bash" "$DOTLY_PATH"/{bin,dotfiles_template,scripts,shell,installer,restorer} -R | awk -F':' '{print $1}'
  find "$DOTLY_PATH"/{bin,dotfiles_template,scripts,shell} -type f -name "*.sh" -print0 | xargs -0 -I _ echo _
}
