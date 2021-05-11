#!/usr/bin/env bash

brew::install() {
  # Some aliases
  case "$1" in
  "docpars") package="denisidoro/tools/docpars" ;;
  *) package="$1" ;;
  esac

  brew install "$package"
}

brew::update_all() {
  brew::self_update
  brew::update_apps
}

brew::self_update() {
  brew update 2>&1 | log::file "Updating brew"
}

brew::update_apps() {
  outdated_apps=$(brew outdated)

  if [ -n "$outdated_apps" ]; then
    echo "$outdated_apps" | while IFS= read -r outdated_app; do
      outdated_app_info=$(brew info "$outdated_app")

      app_new_version=$(echo "$outdated_app_info"| head -1 | sed "s/$outdated_app: //g")
      app_old_version=$(brew list "$outdated_app" --versions | sed "s/$outdated_app //g")
      app_info=$(echo "$outdated_app_info"| head -2 | tail -1)
      app_url=$(echo "$outdated_app_info"| head -3 | tail -1 | head -1)

      output::write "🍄 $outdated_app"
      output::write "├ $app_old_version -✨-> $app_new_version"
      output::write "├ $app_info"
      output::write "└ $app_url"
      output::empty_line

      brew upgrade "$outdated_app" 2>&1 | log::file "Updating brew app: $outdated_app"
    done
  fi

}
