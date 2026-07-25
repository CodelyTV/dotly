# Fix #338: Package import for agent skills

## Problem
The `dot package import` for skills reads the YAML lockfile produced by `dot package dump` and reinstalls skills per agent, but the `_execute_single_install` function used the wrong `npx` command syntax (`npx -y <provider>#<path>` instead of `npx -y skills add <provider>#<path>`), causing all import attempts to fail.

## Solution
Correct the install command in `skills::_execute_single_install()` to use the proper `skills add` subcommand, matching the wrapper scripts (`skills-add-bunx.sh`, `skills-add-npx.sh`).

## Changes

### `scripts/package/src/package_managers/skills.sh`
- **Line ~337**: Replace `npx -y "${provider}#${path}" --agent "${agent:-}"` with a corrected command that:
  1. Detects whether `bunx` or `npx` is available (prefers `bunx`)
  2. Uses `skills add` subcommand: `<cmd> -y skills add <provider>#<path> [--agent <agent>]`
  3. Conditionally includes `--agent` only when an agent is specified

### `tests/package/skills.bats`
- **Import test mock**: Updated the mock script to:
  1. Mock both `bunx` and `npx` (since `bunx` is preferred on this system)
  2. Use `$4` for the provider path argument (correct position in `bunx -y skills add <provider>#<path>`)

## Verification
- All 23 tests in `tests/package/skills.bats` pass

## Files changed
- `scripts/package/src/package_managers/skills.sh`
- `tests/package/skills.bats`