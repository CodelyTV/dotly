#!/usr/bin/env bash

# Bibliography: http://github.com/frgomes/bash-scripts
# https://stackoverflow.com/a/60585911

json::validate() {
  if [[ -z "${1:-}" ]]; then
    python -c 'import sys, yaml, json; json.loads(sys.stdin.read())' 2>/dev/null
  else
    [[ -e "${1:-}" ]] && python -c 'import sys, yaml, json; json.loads(open(sys.argv[1]))' "$1" 2>/dev/null
  fi
}

# If file is not valid return 1 (false)
json::to_yaml() {
  if [[ -z "${1:-}" ]]; then
    python -c 'import sys, yaml, json; print(yaml.dump(json.loads(sys.stdin.read())))' 2>/dev/null
  else
    [[ -e "${1:-}" ]] && python -c 'import sys, yaml, json; print(yaml.dump(json.loads(open(sys.argv[1]))))' "$1" 2>/dev/null
  fi
}