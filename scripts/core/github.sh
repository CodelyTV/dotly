#!/usr/bin/env bash

# Api Url
readonly GITHUB_API_URL="https://api.github.com/repos"
readonly GITHUB_DOTLY_REPOSITORY="CodelyTV/dotly"
readonly GITHUB_CACHE_PETITIONS="$DOTFILES_PATH/.cached_github_api_calls"
GITHUB_CACHE_PETITIONS_PERIOD_IN_DAYS="${GITHUB_CACHE_PETITIONS_PERIOD_IN_DAYS:-1}"

github::curl() {
  local url CURL_BIN
  url="${1:-$(</dev/stdin)}"
  CURL_BIN="$(which curl)"

  params=(-S -s -L -q -f -k "-H 'Accept: application/vnd.github.v3+json'")
  [[ -n "$GITHUB_TOKEN" ]] && params+=("-H 'Authorization: token $GITHUB_TOKEN'")
  
  eval "$CURL_BIN ${params[*]} ${*} $url 2>/dev/null"
}

github::cached_curl() {
  local md5command cached_request_file_path _command url
  url=${1:-$(</dev/stdin)}

  md5command=""
  cached_request_file_path=""
  _command=""

  # Force creation of cache folder
  mkdir -p "$GITHUB_CACHE_PETITIONS"

  # Cache vars
  md5command="$(md5 -s "$_command")"
  cached_request_file_path="$GITHUB_CACHE_PETITIONS/$md5command"

  [[ -f "$cached_request_file_path" ]] &&\
    files::check_if_path_is_older "$cached_request_file_path" "$GITHUB_CACHE_PETITIONS_PERIOD_IN_DAYS"

  # Cache result if is not
  if [ ! -f "$cached_request_file_path" ]; then
    eval "$_command" > "$cached_request_file_path"
  fi

  cat "$cached_request_file_path"
}