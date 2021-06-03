#!/usr/bin/env bash

npm::update_all() {
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
