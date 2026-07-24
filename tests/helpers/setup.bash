#!/usr/bin/env bats
# bats file=true

# Common setup for all tests
# Sets SLOTH_PATH, sources core libraries, provides mock infrastructure

# Point SLOTH_PATH to the repo root (go up 2 dirs: tests/core/.. -> tests/ -> root/)
# Use realpath if available, otherwise fallback
if [[ -n "$(command -v realpath)" ]]; then
    export SLOTH_PATH="$(realpath "${BATS_TEST_DIRNAME}/../..")"
else
    export SLOTH_PATH="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
fi
export DOTLY_PATH="${SLOTH_PATH}"

# Add mocks and bins directories to PATH (before real commands)
export PATH="${SLOTH_PATH}/tests/helpers/mocks:${PATH}"
export PATH="${SLOTH_PATH}/tests/helpers/bins:${PATH}"

# Source core libraries for testing
#shellcheck disable=SC1091
. "${SLOTH_PATH}/scripts/core/src/_main.sh"

# Source mock harness
#shellcheck disable=SC1091
. "${SLOTH_PATH}/tests/helpers/mock.sh"
export MOCK_DIR="${SLOTH_PATH}/tests/helpers/mocks"

# Track if we're running in CI
if [[ -n "${CI:-}" ]]; then
    export SLOTH_CI=true
fi

# Helper: create a temporary file with content
# Usage: temp_file "content"
temp_file() {
    local content="${1:-}"
    local tmp
    tmp=$(mktemp)
    printf '%s\n' "$content" > "$tmp"
    echo "$tmp"
}

# Helper: create a temporary directory
temp_dir() {
    mktemp -d
}

# Helper: check if a command exists (mockable)
command_exists_check() {
    command -v "$1" >/dev/null 2>&1
}

# Helper: assert that a function is defined
assert_function_exists() {
    local func_name="$1"
    declare -f "$func_name" >/dev/null 2>&1
    assert_success
}

# Helper: assert that a function is NOT defined
assert_function_not_exists() {
    local func_name="$1"
    declare -f "$func_name" >/dev/null 2>&1
    assert_failure
}

# Helper: run a script and capture output/exit code
# Usage: run_script <script_path> [args...]
run_script() {
    local script="$1"
    shift
    if [[ -x "$script" ]]; then
        run "$script" "$@"
    elif [[ -f "$script" ]]; then
        run bash "$script" "$@"
    else
        echo "ERROR: Script not found: $script"
        return 1
    fi
}

# Helper: check if bats-core is installed
bats_installed() {
    command -v bats >/dev/null 2>&1
}

# Helper: get bats version
bats_version() {
    bats --version 2>/dev/null | head -1
}
