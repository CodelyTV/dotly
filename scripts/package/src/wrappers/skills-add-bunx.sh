#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="${HOME}/.agents/skills"

if ! command -v bunx &> /dev/null; then
  echo "Error: 'bunx' not found — install bun first (https://bun.sh)" >&2
  exit 1
fi

usage() {
  cat << EOF
Usage: $(basename "$0") <provider> [#<branch>] --agent <agent> [-g] [-y]

Wrap "bunx skills add" and produce a .skill-lock.json on success.

Arguments:
  <provider>   GitHub repo path (e.g., gtrabanco/agentic-workflow)
  #<branch>    Optional branch (e.g., #claude)
  --agent      Agent name to install the skill for (can be repeated)
  -g           Pass through to bunx skills add
  -y           Pass through to bunx skills add
EOF
  exit 1
}

json_escape() {
  printf '%s' "$1" | sed 's/"/\\"/g'
}

provider=""
branch=""
agents=()
extra_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      if [[ $# -lt 2 ]]; then
        echo "Error: --agent requires a value" >&2
        exit 1
      fi
      agents+=("$2")
      extra_args+=(--agent "$2")
      shift 2
      ;;
    -g | -y)
      extra_args+=("$1")
      shift
      ;;
    -h | --help)
      usage
      ;;
    \#*)
      branch="${1#\#}"
      extra_args+=("$1")
      shift
      ;;
    -*)
      extra_args+=("$1")
      shift
      ;;
    *)
      if [[ -z "$provider" ]]; then
        provider="$1"
        extra_args+=("$1")
      else
        extra_args+=("$1")
      fi
      shift
      ;;
  esac
done

[[ -z "$provider" ]] && echo "Error: provider argument is required" >&2 && usage

mkdir -p "$SKILLS_DIR"

before=$(mktemp)
after=$(mktemp)
trap 'rm -f "$before" "$after"' EXIT

# shellcheck disable=SC2012
ls -1 "$SKILLS_DIR" 2> /dev/null | sort > "$before" || true

if ! bunx skills add "${extra_args[@]}"; then
  echo "Error: bunx skills add failed" >&2
  exit 1
fi

# shellcheck disable=SC2012
ls -1 "$SKILLS_DIR" 2> /dev/null | sort > "$after" || true

skill_name=""
while IFS= read -r dir; do
  if [[ -n "$dir" ]] && [[ -d "$SKILLS_DIR/$dir" ]]; then
    skill_name="$dir"
    break
  fi
done < <(comm -13 "$before" "$after" 2> /dev/null)

if [[ -z "$skill_name" ]]; then
  echo "Warning: could not detect new skill directory via directory diff" >&2
  # shellcheck disable=SC2012
  newest_dir=$(ls -1t "$SKILLS_DIR" 2> /dev/null | head -1)
  if [[ -n "$newest_dir" ]]; then
    skill_name="$newest_dir"
    echo "Warning: using most recent directory: $skill_name" >&2
  else
    echo "Error: no skill directories found in $SKILLS_DIR" >&2
    exit 1
  fi
fi

installed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ 2> /dev/null || date -u +%Y-%m-%dT%H:%M:%S)Z

{
  printf '{\n'
  printf '  "provider": "%s",\n' "$(json_escape "$provider")"
  if [[ -n "$branch" ]]; then
    printf '  "branch": "%s",\n' "$(json_escape "$branch")"
  else
    printf '  "branch": null,\n'
  fi
  printf '  "agents": ['
  first=true
  for agent in "${agents[@]}"; do
    $first || printf ', '
    first=false
    printf '"%s"' "$(json_escape "$agent")"
  done
  printf '],\n'
  printf '  "command": "bunx skills add",\n'
  printf '  "installed_at": "%s"\n' "$installed_at"
  printf '}\n'
} > "$SKILLS_DIR/$skill_name/.skill-lock.json"

echo "Installed skill '$skill_name' — .skill-lock.json written"
