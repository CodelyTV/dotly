args::total_is() {
  total_expected="${1}"
  arguments="${*:2}"

  total_arguments=$(echo "$arguments" | wc -w)

  [[ $total_arguments -eq $total_expected ]]
}

args::has_no_args() {
  args::total_is 0 "$@"
}
