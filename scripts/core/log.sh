#!/usr/bin/env bash

echoerr() {
  echo "$@" 1>&2
}

log::ansi() {
  local bg=false
  case "$@" in
  *reset*)
    echo "\e[0m"
    return 0
    ;;
  *black*) color=30 ;;
  *red*) color=31 ;;
  *green*) color=32 ;;
  *yellow*) color=33 ;;
  *blue*) color=34 ;;
  *purple*) color=35 ;;
  *cyan*) color=36 ;;
  *white*) color=37 ;;
  esac
  case "$@" in
  *regular*) mod=0 ;;
  *bold*) mod=1 ;;
  *underline*) mod=4 ;;
  esac
  case "$@" in
  *background*) bg=true ;;
  *bg*) bg=true ;;
  esac

  if $bg; then
    echo "\e[${color}m"
  else
    echo "\e[${mod:-0};${color}m"
  fi
}

if [ -z ${DOT_LOG_FILE+x} ]; then
  readonly DOT_LOG_FILE="/tmp/$(basename "$0").log"
fi

_log() {
  local template=$1
  shift
  if ${log_to_file:-false}; then
    echoerr -e $(printf "$template" "$@") | tee -a "$DOT_LOG_FILE" >&2
  else
    echoerr -e $(printf "$template" "$@")
  fi
}

_header() {
  local TOTAL_CHARS=60
  local total=$TOTAL_CHARS-2
  local size=${#1}
  local left=$((($total - $size) / 2))
  local right=$(($total - $size - $left))
  printf "%${left}s" '' | tr ' ' =
  printf " $1 "
  printf "%${right}s" '' | tr ' ' =
}

log::header() { _log "\n$(log::ansi bold)$(log::ansi purple)$(_header "$1")$(log::ansi reset)\n"; }
log::success() { _log "$(log::ansi green)✔ %s$(log::ansi reset)\n" "$@"; }
log::error() { _log "$(log::ansi red)✖ %s$(log::ansi reset)\n" "$@"; }
log::warning() { _log "$(log::ansi yellow)➜ %s$(log::ansi reset)\n" "$@"; }
log::note() { _log "$(log::ansi blue)%s$(log::ansi reset)\n" "$@"; }

die() {
  log::error "$@"
  exit 42
}
