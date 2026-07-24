#!/usr/bin/env bash

npm_title='🌈 npm'
NPM_DUMP_FILE_PATH="${NPM_DUMP_FILE_PATH:-${DOTFILES_PATH}/langs/js/npm/$(hostname -s).txt}"

npm::title() {
  echo -n "🌈 npm"
}

npm::is_available() {
  platform::command_exists npm
}

npm::install() {
  [[ -n "${1:-}" ]] && npm::is_available && npm install --global "$1"
}

npm::is_installed() {
  [[ -n "${1:-}" ]] && npm::is_available && npm list --global "$1" > /dev/null 2>&1
}

npm::uninstall() {
  [[ -n "${1:-}" ]] && npm::is_available && npm uninstall --global "$1"
}

npm::package_exists() {
  [[ -n "${1:-}" ]] && npm::is_available && npm search grunt | awk '{print $1}' | tail -n +2 | grep -q "^$1$"
}

npm::update_apps() {
  local outdated
  outdated=$(npm -g outdated | tail -n +2)

  if [ -n "$outdated" ]; then
    echo "$outdated" | while IFS= read -r outdated_app; do
      package=$(echo "$outdated_app" | awk '{print $1}')
      current_version=$(echo "$outdated_app" | awk '{print $2}')
      new_version=$(echo "$outdated_app" | awk '{print $4}')

      info=$(npm view "$package")
      summary=$(echo "$info" | tail -n +3 | head -n 1)
      url=$(echo "$info" | tail -n +4 | head -n 1)

      output::write "🌈 $package"
      output::write "├ $current_version -> $new_version"
      output::write "├ $summary"
      output::write "└ $url"
      output::empty_line

      npm install -g "$package" 2>&1 | log::file "Updating npm app: $package"
    done
  else
    output::answer "Already up-to-date"
  fi
}

npm::self_update() {
  local -r timeout="${NPM_TIMEOUT:-${SLOTH_PM_TIMEOUT:-300}}"
  package::run_with_timeout "$timeout" npm install -g npm@latest
}

npm::update_all() {
  npm::self_update
  npm::update_apps
}

npm::dump() {
  local node_modules
  node_modules="$(npm root -g)"
  NPM_DUMP_FILE_PATH="${1:-$NPM_DUMP_FILE_PATH}"

  if package::common_dump_check npm "$NPM_DUMP_FILE_PATH"; then
    if [[ ! -d "$node_modules" ]]; then
      printf '[npm::dump] [warn] npm root directory %q does not exist\n' "$node_modules" >&2
      : > "$NPM_DUMP_FILE_PATH"
      return 0
    fi
    find "$node_modules" -maxdepth 1 -mindepth 1 -type d -print0 | xargs -0 -I _ basename _ | grep -v npm | tee "$NPM_DUMP_FILE_PATH" | log::file "Exporting ${npm_title} packages"

    return 0
  fi

  return 1
}

npm::import() {
  NPM_DUMP_FILE_PATH="${1:-$NPM_DUMP_FILE_PATH}"
  local -r filename="${NPM_DUMP_FILE_PATH##*/}"
  local -r global_packages="${NPM_DUMP_FILE_PATH%%/"${filename}"}/global_packages.txt"

  if package::common_import_check npm "$NPM_DUMP_FILE_PATH"; then
    if [[ $filename != "global_packages.txt" ]] && [[ -r "$global_packages" ]]; then
      xargs -I_ npm install -g _ < "$global_packages" | log::file "Importing global ${npm_title} packages"
    fi

    xargs -I_ npm install -g _ < "$NPM_DUMP_FILE_PATH" | log::file "Importing ${npm_title} packages"
    return 0
  fi

  return 1
}
