mas::update_all() {
  outdated=$(mas outdated)

  if [ -z "$outdated" ]; then
    output::answer "Already up-to-date"
  else
    mas upgrade
  fi
}
