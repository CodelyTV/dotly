#!/usr/bin/env bats
# bats file=true

# Test for scripts/package/src/package_managers/skills.sh — Skills package manager

load "../helpers/setup"

setup() {
    local skills_dir skills_dump_file dotfiles_dir
    skills_dir="$(mktemp -d)"
    skills_dump_file="$(mktemp)"
    SKILLS_DIR="$skills_dir"
    SKILLS_DUMP_FILE_PATH="$skills_dump_file"
    export SKILLS_DIR SKILLS_DUMP_FILE_PATH
    if [[ -z "${DOTFILES_PATH:-}" ]]; then
        dotfiles_dir="$(mktemp -d)"
        DOTFILES_PATH="$dotfiles_dir"
        export DOTFILES_PATH
    fi
}

teardown() {
    rm -rf "${SKILLS_DIR}" 2> /dev/null || true
    rm -f "${SKILLS_DUMP_FILE_PATH}" 2> /dev/null || true
}

# ── Public API function existence ─────────────────────────────────────────

@test "skills::title is defined" {
    run bash -c "source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'; declare -f skills::title"
    [ "$status" -eq 0 ]
}

@test "skills::is_available is defined" {
    run bash -c "source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'; declare -f skills::is_available"
    [ "$status" -eq 0 ]
}

@test "skills::setup is defined" {
    run bash -c "source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'; declare -f skills::setup"
    [ "$status" -eq 0 ]
}

@test "skills::dump is defined" {
    run bash -c "source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'; declare -f skills::dump"
    [ "$status" -eq 0 ]
}

@test "skills::import is defined" {
    run bash -c "source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'; declare -f skills::import"
    [ "$status" -eq 0 ]
}

# ── Discovery helpers ─────────────────────────────────────────────────────

@test "_discover_skills_with_lockfiles: returns empty when SKILLS_DIR does not exist" {
    rm -rf "${SKILLS_DIR}"
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DIR='${SKILLS_DIR}'
        skills::_discover_skills_with_lockfiles
    "
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "_discover_skills_with_lockfiles: returns empty when no lockfiles exist" {
    mkdir -p "${SKILLS_DIR}/my-skill"
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DIR='${SKILLS_DIR}'
        skills::_discover_skills_with_lockfiles
    "
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "_discover_skills_with_lockfiles: parses valid .skill-lock.json" {
    mkdir -p "${SKILLS_DIR}/test-skill"
    cat > "${SKILLS_DIR}/test-skill/.skill-lock.json" << 'EOF'
{
  "provider": "owner/repo",
  "branch": "main",
  "agents": ["claude", "codex"],
  "command": "bunx skills add",
  "installed_at": "2025-01-01T00:00:00Z"
}
EOF
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DIR='${SKILLS_DIR}'
        skills::_discover_skills_with_lockfiles
    "
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "owner/repo|main|test-skill|bunx skills add|claude,codex"
}

@test "_discover_skills_with_lockfiles: handles missing fields with defaults" {
    mkdir -p "${SKILLS_DIR}/minimal-skill"
    cat > "${SKILLS_DIR}/minimal-skill/.skill-lock.json" << 'EOF'
{
  "provider": "owner/repo"
}
EOF
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DIR='${SKILLS_DIR}'
        skills::_discover_skills_with_lockfiles
    "
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "owner/repo||minimal-skill|unknown|unknown"
}

@test "_discover_skills_with_lockfiles: skips lockfile missing provider" {
    mkdir -p "${SKILLS_DIR}/no-provider"
    cat > "${SKILLS_DIR}/no-provider/.skill-lock.json" << 'EOF'
{"agents": ["claude"]}
EOF
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DIR='${SKILLS_DIR}'
        skills::_discover_skills_with_lockfiles 2>/dev/null
    "
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # skipped with warning (to stderr)
}

# ── Dump flow ─────────────────────────────────────────────────────────────

@test "dump: produces valid YAML when no skills directory exists" {
    rm -rf "${SKILLS_DIR}"
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        source '$SLOTH_PATH/scripts/package/src/lib/yaml.sh'
        HOME='$(mktemp -d)'
        SKILLS_DIR='${SKILLS_DIR}'
        SKILLS_DUMP_FILE_PATH='${SKILLS_DUMP_FILE_PATH}'
        skills::dump
    "
    [ "$status" -eq 0 ]
    grep -q "format: skill-lock-v1" "${SKILLS_DUMP_FILE_PATH}"
    grep -q "skills: \[\]" "${SKILLS_DUMP_FILE_PATH}"
}

@test "dump: produces YAML with provider and skill data" {
    local _agents_home="$(mktemp -d)"
    mkdir -p "${_agents_home}/.agents"
    cat > "${_agents_home}/.agents/.skill-lock.json" << 'EOF'
{
  "skills": {
    "my-skill": {
      "source": "owner/repo",
      "skillPath": "skills/my-skill"
    }
  }
}
EOF
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        source '$SLOTH_PATH/scripts/package/src/lib/yaml.sh'
        HOME='${_agents_home}'
        SKILLS_DUMP_FILE_PATH='${SKILLS_DUMP_FILE_PATH}'
        skills::dump
    "
    [ "$status" -eq 0 ]
    grep -q "format: skill-lock-v1" "${SKILLS_DUMP_FILE_PATH}"
    grep -q "owner/repo" "${SKILLS_DUMP_FILE_PATH}"
    grep -q "my-skill" "${SKILLS_DUMP_FILE_PATH}"
}

@test "dump: handles fallback via package.json" {
    local _agents_home="$(mktemp -d)"
    mkdir -p "${_agents_home}/.agents"
    cat > "${_agents_home}/.agents/.skill-lock.json" << 'EOF'
{
  "skills": {
    "lockfile-skill": {
      "source": "owner/lockfile",
      "skillPath": "skills/lockfile-skill"
    }
  }
}
EOF
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        source '$SLOTH_PATH/scripts/package/src/lib/yaml.sh'
        HOME='${_agents_home}'
        SKILLS_DUMP_FILE_PATH='${SKILLS_DUMP_FILE_PATH}'
        skills::dump 2>&1
    "
    [ "$status" -eq 0 ]
    grep -q "format: skill-lock-v1" "${SKILLS_DUMP_FILE_PATH}"
    grep -q "owner/lockfile" "${SKILLS_DUMP_FILE_PATH}"
}

# ── Import flow ──────────────────────────────────────────────────────────

@test "import: fails with clear error when no YAML file exists" {
    rm -f "${SKILLS_DUMP_FILE_PATH}"
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DUMP_FILE_PATH='${SKILLS_DUMP_FILE_PATH}'
        skills::import
    "
    [ "$status" -eq 1 ]
    echo "$output" | grep -qi "no skill-lock.yaml found"
}

@test "import: fails with version error on invalid format" {
    echo 'format: unknown-v1' > "${SKILLS_DUMP_FILE_PATH}"
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DUMP_FILE_PATH='${SKILLS_DUMP_FILE_PATH}'
        skills::import
    "
    [ "$status" -eq 1 ]
    echo "$output" | grep -qi "invalid or missing format"
}

@test "import: returns 0 when YAML has no entries" {
    cat > "${SKILLS_DUMP_FILE_PATH}" << 'EOF'
format: skill-lock-v1
skills: []
EOF
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DUMP_FILE_PATH='${SKILLS_DUMP_FILE_PATH}'
        skills::import
    "
    [ "$status" -eq 0 ]
}

@test "import: installs skills from valid YAML lockfile" {
    cat > "${SKILLS_DUMP_FILE_PATH}" << 'EOF'
format: skill-lock-v1
skills:
  - name: test-skill
    provider: owner/repo
    path: skills/test-skill
EOF
    # Save test's temp dir before sourcing (skills.sh line 5 overwrites SKILLS_DIR)
    local _saved_skills_dir="$SKILLS_DIR"
    # Mock bunx (preferred) / npx: creates skill dir + .skill-lock.json instead of actually installing
    local _mock_dir="$(mktemp -d)"
    for _cmd in bunx npx; do
      cat > "${_mock_dir}/${_cmd}" << MOCKCMD
#!/usr/bin/env bash
provider_path="\$4"
path="\${provider_path##*#}"
name="\${path##*/}"
mkdir -p "\${SKILLS_DIR}/\${name}" 2>/dev/null
echo "{\"provider\":\"owner/repo\",\"skillPath\":\"\${path}\"}" > "\${SKILLS_DIR}/\${name}/.skill-lock.json"
exit 0
MOCKCMD
      chmod +x "${_mock_dir}/${_cmd}"
    done
    PATH="${_mock_dir}:$PATH"
    source "${SLOTH_PATH}/scripts/package/src/package_managers/skills.sh"
    SKILLS_DIR="$_saved_skills_dir"
    export SKILLS_DIR
    run skills::import
    [ "$status" -eq 0 ]
    [[ -d "${SKILLS_DIR}/test-skill" ]]
    [[ -f "${SKILLS_DIR}/test-skill/.skill-lock.json" ]]
    echo "$output" | grep -F "Import complete: 1 total, 1 succeeded, 0 failed."
}

# ── Verify install helper ────────────────────────────────────────────────

@test "_verify_install: returns 0 when skill directory and lockfile exist" {
    mkdir -p "${SKILLS_DIR}/existing-skill"
    touch "${SKILLS_DIR}/existing-skill/.skill-lock.json"
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DIR='${SKILLS_DIR}'
        skills::_verify_install 'existing-skill'
    "
    [ "$status" -eq 0 ]
}

@test "_verify_install: returns 1 when skill directory does not exist" {
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DIR='${SKILLS_DIR}'
        skills::_verify_install 'nonexistent-skill'
    "
    [ "$status" -eq 1 ]
}

# ── Execute single install ───────────────────────────────────────────────

@test "_execute_single_install: idempotent when .skill-lock.json already exists" {
    mkdir -p "${SKILLS_DIR}/already-installed"
    touch "${SKILLS_DIR}/already-installed/.skill-lock.json"
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DIR='${SKILLS_DIR}'
        skills::_execute_single_install 'owner/repo' 'skills/already-installed' '' 'already-installed' 2>&1
    "
    [ "$status" -eq 0 ]
    echo "$output" | grep -qi "already installed"
}

# ── YAML parser ──────────────────────────────────────────────────────────

@test "_parse_yaml_document: parses valid skill-lock YAML" {
    cat > "${SKILLS_DUMP_FILE_PATH}" << 'EOF'
format: skill-lock-v1
skills:
  - name: my-skill
    provider: owner/repo
    path: skills/my-skill
EOF
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DUMP_FILE_PATH='${SKILLS_DUMP_FILE_PATH}'
        skills::_parse_yaml_document '${SKILLS_DUMP_FILE_PATH}'
    "
    [ "$status" -eq 0 ]
    echo "$output" | grep -F "my-skill|owner/repo|skills/my-skill|"
}

@test "_parse_yaml_document: parses multi-provider YAML" {
    cat > "${SKILLS_DUMP_FILE_PATH}" << 'EOF'
format: skill-lock-v1
skills:
  - name: skill-a
    provider: owner/repo-a
    path: skills/skill-a
  - name: skill-b
    provider: owner/repo-b
    path: skills/skill-b
EOF
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DUMP_FILE_PATH='${SKILLS_DUMP_FILE_PATH}'
        skills::_parse_yaml_document '${SKILLS_DUMP_FILE_PATH}'
    "
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "skill-a"
    echo "$output" | grep -q "skill-b"
}

@test "_parse_yaml_document: reports line numbers on malformed entries" {
    cat > "${SKILLS_DUMP_FILE_PATH}" << 'EOF'
format: skill-lock-v1
skills:
  - name: my-skill
    provider: owner/repo
    badfield: unexpected
    path: skills/my-skill
EOF
    run bash -c "
        source '$SLOTH_PATH/scripts/package/src/package_managers/skills.sh'
        SKILLS_DUMP_FILE_PATH='${SKILLS_DUMP_FILE_PATH}'
        skills::_parse_yaml_document '${SKILLS_DUMP_FILE_PATH}' 2>&1
    "
    echo "$output" | grep -qi "line 5"
    echo "$output" | grep -qi "badfield"
}
