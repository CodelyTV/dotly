#!/usr/bin/env bash

# Bibliography: http://github.com/frgomes/bash-scripts
# https://stackoverflow.com/a/60585911

yaml::validate() {
  if [[ -z "${1:-}" ]]; then
    python -c 'import sys, yaml, json; yaml.safe_load(sys.stdin.read())' 2>/dev/null
  else
    [[ -e "${1:-}" ]] &&\
      python -c 'import sys, yaml, json; yaml.safe_load(open(sys.argv[1]))' "$1" 2>/dev/null
  fi
}

# If file is not valid return 1 (false)
yaml::to_json() {
  if [[ -z "${1:-}" ]]; then
    python -c 'import sys, yaml, json; print(json.dumps(yaml.safe_load(sys.stdin.read())))' 2>/dev/null
  else
    [[ -e "${1:-}" ]] &&\
      python -c 'import sys, yaml, json; print(json.dumps(yaml.safe_load(open(sys.argv[1]))))' "$1" 2>/dev/null
  fi
}

# If file is not valid return 1 (false)
yaml::to_json_pretty() {
  if [[ -z "${1:-}" ]]; then
    python -c 'import sys, yaml, json; print(json.dumps(yaml.safe_load(sys.stdin.read()), indent=2, sort_keys=False))' 2>/dev/null
  else
    [[ -e "${1:-}" ]] &&\
      python -c 'import sys, yaml, json; print(json.dumps(yaml.safe_load(open(sys.argv[1])), indent=2, sort_keys=False))' "$1" 2>/dev/null
  fi
}
