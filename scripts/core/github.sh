#!/usr/bin/env bash

# Api Url
readonly GITHUB_API_URL="https://api.github.com/repos"
readonly GITHUB_RAW_FILES_URL="https://raw.githubusercontent.com"
readonly GITHUB_DOTLY_REPOSITORY="CodelyTV/dotly"
readonly GITHUB_DOTLY_CACHE_PETITIONS="$DOTFILES_PATH/.cached_github_api_calls"
GITHUB_CACHE_PETITIONS_PERIOD_IN_DAYS="${GITHUB_CACHE_PETITIONS_PERIOD_IN_DAYS:-1}"

github::get_api_url() {
  local user repository branch arguments

  while [ $# -gt 0 ]; do
    case $1 in
      --user|-u|--organization|-o)
        user="$2"
        shift 2
        ;;
      --repository|-r)
        repository="$2"
        shift 2
        ;;
      --branch|-b)
        branch="/branches/$2"
        shift 2
        ;;
      *)
        break 2
        ;;
    esac
  done

  if [[ -z "$user" ]] && [[ -z "$repository" ]]; then
    if [[ "$1" =~ [\/] ]]; then
      user="$(echo "$1" | awk -F '/' '{print $1}')"
      repository="$(echo "$1" | awk -F '/' '{print $2}')"
      shift
    else
      user="$1"
      repository="$2"
      shift 2
    fi
  fi
  
  [[ $# -gt 0 ]] && arguments="/$(str::join '/' "$*")"

  echo "$GITHUB_API_URL/$user/$repository${branch:-}${arguments:-}"
}

github::branch_raw_url() {
  local user repository branch arguments

  branch="master"

  while [ $# -gt 0 ]; do
    case $1 in
      --user|-u|--organization|-o)
        user="$2"
        shift 2
        ;;
      --repository|-r)
        repository="$2"
        shift 2
        ;;
      --branch|-b)
        branch="$2"
        shift 2
        ;;
      *)
        break 2
        ;;
    esac
  done

  if [[ -z "$user" ]] && [[ -z "$repository" ]]; then
    if [[ "$1" =~ [\/] ]]; then
      user="$(echo "$1" | awk -F '/' '{print $1}')"
      repository="$(echo "$1" | awk -F '/' '{print $2}')"
      shift
    else
      user="$1"
      repository="$2"
      shift 2
    fi
  fi
  
  [[ $# -gt 1 ]] && branch="$1" && shift
  [[ $# -gt 0 ]] && file="/$(str::join '/' "$*")"

  echo "$GITHUB_RAW_FILES_URL/$user/$repository/${branch:-master}${file:-}"
}

github::clean_cache() {
  rm -rf "$GITHUB_DOTLY_CACHE_PETITIONS"
}

github::_command() {
  local url CURL_BIN
  url="$1"; shift
  CURL_BIN="$(which curl)"

  params=(-S -s -L -q -f -k "-H 'Accept: application/vnd.github.v3+json'")
  [[ -n "$GITHUB_TOKEN" ]] && params+=("-H 'Authorization: token $GITHUB_TOKEN'")
  
  echo "$CURL_BIN ${params[*]} ${*} $url"
}

github::curl() {
  local md5command cached_request_file_path _command url cached cache_period
  
  cached=true
  cache_period="$GITHUB_CACHE_PETITIONS_PERIOD_IN_DAYS"

  case "$1" in
    --no-cache|-n)
      cached=false
      shift
      ;;
    --cached|-c)
      shift
      ;;
    --period-in-days|-p)
      cache_period="$2"
      shift 2
      ;;
  esac

  url=${1:-$(</dev/stdin)}
  _command="$(github::_command "$url")"

  if $cached; then
    # Force creation of cache folder
    mkdir -p "$GITHUB_DOTLY_CACHE_PETITIONS"

    # Cache vars
    md5command="$(echo "$_command" | md5)"
    cached_request_file_path="$GITHUB_DOTLY_CACHE_PETITIONS/$md5command"

    [[ -f "$cached_request_file_path" ]] &&\
      files::check_if_path_is_older "$cached_request_file_path" "$cache_period"

    # Cache result if is not
    if [ ! -f "$cached_request_file_path" ]; then
      eval "$_command 2>/dev/null" > "$cached_request_file_path"
    fi

    cat "$cached_request_file_path"
  else
    eval "$_command 2>/dev/null"
  fi
}

github::get_latest_dotly_tag() {
  github::curl $(github::get_api_url "$GITHUB_DOTLY_REPOSITORY" "tags") | jq -r '.[0].name' | uniq
}