str::split() {
  local -r text=$1
  local -r splitter=$2

  echo "$text" | tr "$splitter" "\n"
}

str::contains() {
  [[ $2 == *$1* ]]
}

str::to_upper() { echo "${@:-$(</dev/stdin)}" | tr '[:lower:]' '[:upper:]'; }
str::to_lower() { echo "${@:-$(</dev/stdin)}" | tr '[:upper:]' '[:lower:]'; }

# output::join: https://stackoverflow.com/a/17841619
str::join() {
  local glue=${1-} f=${2-}
  if shift 2; then printf "%s" "$f" "${@/#/$glue}"; fi
}
