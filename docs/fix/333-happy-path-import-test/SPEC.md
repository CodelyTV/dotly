# fix/333-happy-path-import-test

> Fix specification for adding a happy-path integration test for `skills::import`.

## Goal

`tests/package/skills.bats` covers 4 import scenarios — all error/empty paths. No
test exercises the real install loop with valid provider/skill/agent rows. This
leaves a critical gap: failures in the install loop (e.g. `_execute_single_install`
argument forwarding, `_verify_install` integration) go undetected until a user
reports them. Add one happy-path bats test that creates a valid YAML lockfile,
mocks the external command, runs `skills::import`, and verifies skills land in
`SKILLS_DIR`.

## Issue

[#333](https://github.com/gtrabanco/dotSloth/issues/333) — tracked issue. The PR must close it.

## Branch

`fix/333-happy-path-import-test`

## Root cause

`tests/package/skills.bats` (`tests/package/skills.bats:197-232`) tests 4 import
cases: function defined (`:49`), no YAML file (`:199`), invalid format version
(`:210`), no entries (`:221`). All exercise error/empty paths. No test creates a
valid `skill-lock-v1` YAML with real provider/skill/agent rows and runs the full
`skills::import` loop (`scripts/package/src/package_managers/skills.sh:470-568`).

The affected logic includes `skills::_parse_yaml_document` (parsing),
`skills::_execute_single_install` (command dispatch via `"${cmd_parts[@]}"`),
and `skills::_verify_install` (directory + lockfile check). None of these are
exercised together in a success path.

## Scope

### In scope

- One new bats test in `tests/package/skills.bats` titled "import: installs skills from valid YAML lockfile" that:
  1. Creates a valid `skill-lock-v1` YAML with ≥1 provider, ≥1 skill, ≥1 agent
  2. Mocks the external command tool (e.g. `bunx`) via `mock_command_script` to simulate successful installation (creates skill dir + `.skill-lock.json`)
  3. Sources skills.sh, sets `SKILLS_DUMP_FILE_PATH` + `SKILLS_DIR`, runs `skills::import`
  4. Verifies exit code 0
  5. Verifies the skill directory exists under `SKILLS_DIR`
  6. Verifies `.skill-lock.json` exists inside the skill directory
  7. Verifies log output contains "Import complete: N total, N succeeded, 0 failed"

### Out of scope

- Wrapper script tests (`skills-add-bunx.sh` / `skills-add-npx.sh`) — tracked as `#333` out-of-scope.
- Import of skills without lockfile (fallback path — `_discover_skills_from_package_json`) — filed separately if needed.
- Fix for `((count++))` under `set -e` (FN1) — already resolved at commit f34bd41.
- Adding new mock infrastructure beyond what's needed for this single test — reuse `mock_command_script` from `tests/helpers/mock.sh`.
- Negative-path import tests (missing fields, command not found, failed install) — already covered at `tests/package/skills.bats:197-232`.

## Impact

- **Modules/files touched:** `tests/package/skills.bats` (add ~50 lines); optionally `tests/helpers/mocks/` (add a mock script for the external command, e.g. `bunx`).
- **Blast radius:** Dev-only. A broken test fails `bats tests/package/skills.bats` locally and in CI. No production impact.
- **Detection lead time:** Immediate — `bats` returns non-zero exit code on failure. CI gate catches it before merge.

## Rules that must never be violated

- **Test isolation:** Each test must set up its own `SKILLS_DIR` + `SKILLS_DUMP_FILE_PATH` in `setup()` and clean up in `teardown()`. No cross-test state leakage.
- **No real external commands:** The mock must intercept the command tool (`bunx` / `npx`). The existing `PATH` prepend in `tests/helpers/setup.bash:9` (`export PATH="${SLOTH_PATH}/tests/helpers/mocks:${PATH}"`) ensures the mock shadows the real binary.
- **No hardcoded paths:** Use `${SKILLS_DIR}` and `${SKILLS_DUMP_FILE_PATH}` from the test environment.
- **All new scripts must be POSIX-compatible bash** (`CLAUDE.md` Hard rules).
- **set -euo pipefail** is mandatory in standalone mock scripts (`CLAUDE.md` Hard rules).

## Risks

### Operational risks

- **n/a.** No scheduled jobs, queues, caches, schemas, or external-adapter interactions. The test is fully self-contained.

### Security risks

- **n/a.** No auth, secrets, PII, webhooks, or rate-limits involved. The mock does not execute real external commands.

### Compliance touchpoints

- **n/a.** No domain/compliance rules apply. Test-only change.

## Acceptance criteria

- [ ] `tests/package/skills.bats` contains a new `@test "import: installs skills from valid YAML lockfile"` that:
  - Creates a valid `skill-lock-v1` YAML with one provider, one skill, and one agent row
  - Mocks the external command tool to simulate installation (creating skill dir + `.skill-lock.json`)
  - Runs `skills::import` and asserts exit code 0
  - Asserts the skill directory exists under `SKILLS_DIR`
  - Asserts `.skill-lock.json` exists inside the skill directory
  - Asserts stdout contains `"Import complete: 1 total, 1 succeeded, 0 failed"`
- [ ] `bats tests/package/skills.bats` passes (test layer: integration)
- [ ] `./scripts/core/lint && ./scripts/core/static_analysis` passes (verification gate)

## Rollback

**n/a** — test-only change. Revert the commit:
```bash
git revert <sha>
```
No data-side cleanup needed. No schema changes. No archives affected.

## Effort

**XS** — 1 commit, ≤ 1h. Single new bats test (~50 lines) following the established test patterns in `tests/package/skills.bats`.

## Observability

- **n/a** — test-only change, no production observability impact. Test pass/fail is visible in bats output and CI logs.

## Affected docs

- **n/a** — no documentation changes needed. The change is test-only.

## Cross-issue notes

| Issue | Relation | Decision |
|-------|----------|----------|
| #330 | Parallel — feature: package dump/import for agent skills | This test validates the import side of the same feature. Two could merge but have different labels (#330 is unlabeled/unscoped). Keep separate — this fix ships first. |
| #268 | Rolled out — tests for restorer and installer bootstrap | Exemplar of how integration tests are structured in this repo. Reference pattern. |
| #273 | Unrelated — gem.bats test quality | Different package manager, different test concerns. No overlap. |
| PP2 (review-findings.md) | This fix IS PP2 — "No happy-path integration test for skills::import" | The postponed finding that this SPEC resolves. Trigger met: "Before next merge or feature wrap-up." |

## Decisions made during drafting

- **Mock approach:** Use `mock_command_script` with a custom mock script rather than `mock_command` because the mock needs to create the skill directory structure (`SKILLS_DIR/<skill>/.skill-lock.json`), which simple stdout-only mocks cannot do. The mock script takes the skill name from the last path component of the provider argument (e.g., `owner/repo` → `repo`), or alternatively the test can use a skill name that matches the target directory name directly.
- **Command to mock:** `bunx` — the most common command prefix in skills lockfiles. The mock will intercept `bunx skills add <provider> [--agent <agent>]`.
- **Test setup reuse:** The existing `setup()` and `teardown()` functions in `tests/package/skills.bats` already create fresh `SKILLS_DIR` and `SKILLS_DUMP_FILE_PATH`. The new test reuses them without modification.
- **Single-provider, single-agent row:** The test uses one provider with one skill and one agent. This exercises the full install loop without making the test unnecessarily complex. A follow-up could add multi-agent or multi-skill variants.
- **Mock script location:** Place the mock script at `tests/helpers/mocks/bunx` so the existing PATH prepend picks it up automatically. The mock must `set -euo pipefail` and forward only the needed behavior.

## Phases

### P1 — Implement happy-path import test

- [x] Write mock script `tests/helpers/mocks/bunx` that:
  - Accepts `skills add <provider> [--agent <agent>]` arguments
  - Creates `<SKILLS_DIR>/<skill-name>/` directory
  - Writes a minimal `.skill-lock.json` into that directory
  - Exits 0
- [x] Write `@test "import: installs skills from valid YAML lockfile"` in `tests/package/skills.bats` that:
  - Creates valid `skill-lock-v1` YAML with one provider, one skill, one agent row
  - Sets `SKILLS_DUMP_FILE_PATH` to the lockfile
  - Calls `skills::import` via `run bash -c "source ... skills::import"`
  - Asserts: `[ "$status" -eq 0 ]`
  - Asserts: `[[ -d "${SKILLS_DIR}/<skill-name>" ]]`
  - Asserts: `[[ -f "${SKILLS_DIR}/<skill-name>/.skill-lock.json" ]]`
  - Asserts: `echo "$output" | grep "Import complete: 1 total, 1 succeeded, 0 failed"`
- [x] Verify gate: `bats tests/package/skills.bats` passes
- [x] Verify gate: `./scripts/core/lint && ./scripts/core/static_analysis` passes

**Phase-lint:**
- ✓ Each task is independently checkable without judgement
- ✓ Zero open design decisions (all recorded in "Decisions made during drafting")
- ✓ Single layer/concern (test + mock)
- ✓ Gate runnable locally
- ✓ No speculative/untestable tasks
- ✓ No merge with other phases
- ✓ Every task has a clear pass/fail criterion
- ✓ Phase produces a coherent atomic unit of value

### P2 — Hardening & PR

- [x] Squash the single phase commit into a clean commit with message:
      `test(package): add happy-path integration test for skills::import`
- [x] Push the branch to remote:
      `git push origin fix/333-happy-path-import-test`
- [x] Open a PR against `main` with title:
      `test(package): add happy-path integration test for skills::import`
- [x] In the PR body, add:
      `Closes #333`
- [x] Request review from the team (sole collaborator is author — n/a)
- [ ] After approval, merge to `main`
- [ ] Remove the row from `docs/fix/README.md`

**Hardening & PR** tasks keep the delivery pipeline clean and auditable.
*The tasks above are fixed — keep them literally (not paraphrased, not merged
into an implementation phase).*
