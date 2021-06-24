red='\033[0;31m'
green='\033[0;32m'
bold_blue='\033[1m\033[34m'
normal='\033[0m'

_output::parse_code() {
  local color="$normal"
  case "${1:-}" in
    --color)
      color="$2"
      shift 2
      ;;
  esac

  local -r text="${*:-}"

  with_code_parsed=$(echo "$text" | awk "{ORS=(NR+1)%2==0?\"${green}\":RS}1" RS="\`" | awk "{ORS=NR%1==0?\"${color}\":RS}1" RS="\`" | tr -d '\n')

  echo -e "$with_code_parsed"
}

output::write() {
  local with_code_parsed color
  color="$normal"
  case "${1:-}" in
    --color)
      color="$2"
      shift 2
      ;;
  esac

  local -r text="${*:-}"
  with_code_parsed="$(_output::parse_code --color "${color}" "$text")"
  echo -e "$with_code_parsed"
}
output::answer() {
  local color
  color="$normal"
  case "${1:-}" in
    --color)
      color="$2"
      shift 2
      ;;
  esac
  output::write --color "${color}" " > ${*:-}";
}
output::error() { output::answer --color "${red}" "${red}${*:-}${normal}"; }
output::solution() { output::answer --color "${green}" "${green}${*:-}${normal}"; }
output::question() {
  local with_code_parsed color
  color="$normal"
  case "${1:-}" in
    --color)
      color="$2"
      shift 2
      ;;
  esac
  with_code_parsed="$(_output::parse_code --color "${color}" "${1:-}")"

  if [ "${DOTLY_ENV:-PROD}" == "CI" ] || [ "${DOTLY_INSTALLER:-false}" = true ]; then
    echo "y"
  elif declare -F platform::is_macos &>/dev/null && platform::is_macos; then
    echo -n " > 🤔 $1: ";
    read -r "$2";
  else
    read -rp "🤔 $1: " "$2"
  fi
}
output::question_default() {
  local question default_value var_name

  [[ $# -ne 3 ]] && return 1

  question="${1:-}"
  default_value="${2:-}"
  var_name="${3:-}"

  output::question "$question? [$default_value]" "$var_name"
  eval "$var_name=\"\${$var_name:-$default_value}\""
}
output::yesno() {
  local question default PROMPT_REPLY values

  [[ $# -eq 0 ]] && return 1

  question="$1"
  default="${2:-Y}"

  if [[ "$default" =~ ^[Yy] ]]; then
    values="Y/n"
  else
    values="y/N"
  fi

  output::question "$question? [$values]" "PROMPT_REPLY"
  [[ "${PROMPT_REPLY:-$default}" =~ ^[Yy] ]]
}
output::answer_is_yes() {
  if [[ "${1:-Y}" =~ ^[Yy] ]]; then
    return 0
  fi

  return 1
}

output::question_default() {
  local with_code_parsed color question default_value var_name
  color="$normal"
  case "${1:-}" in
    --color)
      color="$2"
      shift 2
      ;;
  esac

  [[ $# -lt 3 ]] && return 1

  question="$1"
  default_value="$2"
  var_name="$3"

  with_code_parsed="$(_output::parse_code --color "${color}" "$question")"

  read -rp "🤔 $with_code_parsed ? [$default_value]: " PROMPT_REPLY
  eval "$var_name=\"${PROMPT_REPLY:-$default_value}\""
}

output::yesno() {
  local with_code_parsed color question default PROMPT_REPLY values
  color="$normal"
  case "${1:-}" in
    --color)
      color="$2"
      shift 2
      ;;
  esac

  [[ $# -eq 0 ]] && return 1

  question="$1"
  default="${2:-Y}"
  with_code_parsed="$(_output::parse_code --color "${color}" "$question")"

  if [[ "$default" =~ ^[Yy] ]]; then
    values="Y/n"
  else
    values="y/N"
  fi

  output::question_default "$with_code_parsed" "$values" "PROMPT_REPLY"
  [[ "$PROMPT_REPLY" == "$values" ]] && PROMPT_REPLY=""
  [[ "${PROMPT_REPLY:-$default}" =~ ^[Yy] ]]
}

output::empty_line() { echo ''; }

output::header() {
  output::empty_line
  output::write --color "${bold_blue}" "${bold_blue}---- ${*:-} ----${normal}"
}
output::h1_without_margin() { output::write --color "${bold_blue}" "${bold_blue}# ${*:-}${normal}"; }
output::h1() {
  output::empty_line
  output::h1_without_margin "${*:-}"
}
output::h2() {
  output::empty_line
  output::write --color "${bold_blue}" "${bold_blue}## ${*:-}${normal}"
}
output::h3() {
  output::empty_line
  output::write --color "${bold_blue}" "${bold_blue}### ${*:-}${normal}"
}
