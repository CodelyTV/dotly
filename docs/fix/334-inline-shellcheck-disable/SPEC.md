# fix/334-inline-shellcheck-disable

> Fix for SC2012 shellcheck warnings in bunx/npx wrappers. Copy of base template `docs/fix/_TEMPLATE/SPEC.md`.

## Goal

Shellcheck reports SC2012 ("Use find instead of ls -1", or similar lint warning on `ls -1`) in `skills-add-bunx.sh` and `skills-add-npx.sh`. Both files have a file-level `# shellcheck disable=SC2012` at line 3, but shellcheck only respects inline disables — the file-level directive has no effect. The fix adds inline `# shellcheck disable=SC2012` before each `ls -1` line and removes the dead file-level directive.

## Issue

`#334` — tracked issue. Required. The PR must close it.

## Branch

`fix/334-inline-shellcheck-disable`

## Root cause

Shellcheck's `# shellcheck disable=SC2012` at file scope (line 3) does not suppress line-level warnings on subsequent `ls -1` invocations. The disable must be placed as an inline comment immediately before each `ls -1` line. Both `skills-add-bunx.sh` and `skills-add-npx.sh` have the same pattern:

- `scripts/package/src/wrappers/skills-add-bunx.sh` line 3: file-level `# shellcheck disable=SC2012` (dead code — has no effect)
- `scripts/package/src/wrappers/skills-add-bunx.sh` lines 84, 91, 103: three `ls -1 "$SKILLS_DIR" 2> /dev/null | sort > "$before"/"$after" || true` lines — each emits SC2012
- `scripts/package/src/wrappers/skills-add-npx.sh` line 3: same file-level disable (dead code)
- `scripts/package/src/wrappers/skills-add-npx.sh` lines 84, 91, 103: same three `ls -1` invocations

(Note: `shell/init-sloth.sh:4` and `scripts/script/install_remote:63` have file-level disables too, but they are not referenced in the issue and have separate tracking.)

## Scope

### In scope

The smallest change set that closes the issue:

1. In `scripts/package/src/wrappers/skills-add-bunx.sh`: add inline `# shellcheck disable=SC2012` before each of the 3 `ls -1 "$SKILLS_DIR"` lines (lines 84, 91, 103); remove the dead file-level disable at line 3.
2. In `scripts/package/src/wrappers/skills-add-npx.sh`: add inline `# shellcheck disable=SC2012` before each of the 3 `ls -1 "$SKILLS_DIR"` lines (lines 84, 91, 103); remove the dead file-level disable at line 3.

Total: 6 inline disable comments added, 2 file-level disable comments removed.

### Out of scope

- Adding shellcheck to CI: should be filed as a separate `docs/fix/` entry or tracked issue.
- Replacing `ls -1` with `find` (the preferred POSIX alternative): explicitly deferred by the issue — this fix suppresses, not refactors.
- Fixing file-level shellcheck disables in other files (`shell/init-sloth.sh:4`, `scripts/script/install_remote:63`): separate fix entries as needed.

## Impact

- **Modules/files touched:**
  - `scripts/package/src/wrappers/skills-add-bunx.sh` (lines 3, 84, 91, 103)
  - `scripts/package/src/wrappers/skills-add-npx.sh` (lines 3, 84, 91, 103)
- **Layers:** infrastructure / package manager wrappers only. No core logic, no API, no user-facing behavior changes.
- **Blast radius:** zero behavioral change — only adding/removing comments. If applied to the wrong lines, shellcheck warnings may remain or new ones may appear, but the script's output and execution are unaffected.
- **Detection lead time:** immediate — `./scripts/core/static_analysis` will surface or confirm the fix.

## Rules that must never be violated

- From `CLAUDE.md` Hard rules: **"Shell compatibility: all scripts must be POSIX-compatible bash. Never use bashisms that break on macOS default bash (3.2)."** — removing file-level disables does not affect shell compatibility.
- From `CLAUDE.md` Hard rules: **"`set -euo pipefail`" — all new scripts must use this header; existing scripts that lack it should be migrated when touched.** — both files already have this header; no change needed.
- From `CLAUDE.md` Hard rules: **Docs language: all committed artifacts in English.** — this SPEC is in English.
- From `CLAUDE.md` Commands: verification gate `./scripts/core/lint && ./scripts/core/static_analysis` must be green before commit.

## Risks

- **Operational:** n/a — only comment changes, no behavioral impact.
- **Security:** n/a — no code paths, secrets, PII, or auth touched.
- **Compliance:** n/a — no domain or regulatory touchpoints.

## Acceptance criteria

- [ ] `scripts/package/src/wrappers/skills-add-bunx.sh` has inline `# shellcheck disable=SC2012` before each of the 3 `ls -1 "$SKILLS_DIR"` lines (unit/verify — grep for inline disables at lines ~85, ~92, ~104)
- [ ] `scripts/package/src/wrappers/skills-add-npx.sh` has inline `# shellcheck disable=SC2012` before each of the 3 `ls -1 "$SKILLS_DIR"` lines (unit/verify — same check)
- [ ] File-level `# shellcheck disable=SC2012` removed from both files at line 3 (unit/verify — grep confirms no occurrence in either file)
- [ ] `./scripts/core/static_analysis` passes with zero warnings for both files (integration/verify — command exit code 0 and no grep matches for SC2012 in output)
- [ ] `./scripts/core/lint` passes for both files (integration/verify — command exit code 0)
- [ ] Verification gate `./scripts/core/lint && ./scripts/core/static_analysis` passes (integration/verify — full gate)

## Rollback

Single command revert: `git revert <commit-sha>`. No data-side cleanup needed — only comment changes in shell scripts.

## Effort

XS — 6 lines added, 2 lines removed, zero behavioral change. One commit, < 1h.

## Affected docs

- `docs/fix/README.md` — add entry for `334-inline-shellcheck-disable` with status `pending`.

## Observability

Not applicable — no runtime behavior changes. The static analysis gate (`./scripts/core/static_analysis`) confirms the fix is correct at commit time.

## Cross-issue notes

- **#330** `feat: package dump/import for agent skills (bunx/npx skills)` — in-progress fix in `docs/fix/330-package-dump-import` (pending, branch not merged). Related to the same wrapper files but addresses a different concern (import/dump feature). No blocking relationship.
- **#300** `feat: audit set -euo pipefail across scripts` (pending) — may touch these files when auditing, but no conflict: adding inline disables is orthogonal to adding `set -euo pipefail`. Parallel, no dependency.
- **#273** `test: gem.bats tests 5-6 are grep-based regression guards` — unrelated; gem-specific tests.
- **#224** `[Doc] Documentation needs a lot of improvements` — unrelated.

No open PRs in the repository. No blocking or blocked relationships.

## Decisions made during drafting

- **Inline disable placement:** The `# shellcheck disable=SC2012` comment must be placed on the line *immediately before* each `ls -1` line (not on the same line). This is shellcheck's documented behavior — inline (not same-line) disables suppress the next statement's warnings.
- **File-level disable removal:** Since file-level disables have no effect (confirmed by the issue — `ls -1` lines still emit SC2012), both file-level disables are removed as dead code rather than left untouched.
- **`ls -1` not replaced with `find`:** Per the issue's explicit scope, the fix suppresses the warning rather than refactoring `ls -1` to `find`. This is deferred to a separate effort.
- **No impact on `install_remote` or `init-sloth.sh`:** These files have pre-existing file-level disables (at line 63 and line 4 respectively). They are not in scope and will be addressed separately if they have the same issue.

## Phases

> Execution ledger: one phase per invocation of `execute-phase --fix`. Each phase independently checkable without judgment, zero open design decisions, one layer/concern, gate runnable locally.

- [ ] **P1 — Add inline shellcheck disables, remove dead file-level disables**
  - [ ] `skills-add-bunx.sh`: add inline `# shellcheck disable=SC2012` before each `ls -1 "$SKILLS_DIR"` line (lines 84, 91, 103)
  - [ ] `skills-add-bunx.sh`: remove file-level `# shellcheck disable=SC2012` at line 3
  - [ ] `skills-add-npx.sh`: add inline `# shellcheck disable=SC2012` before each `ls -1 "$SKILLS_DIR"` line (lines 84, 91, 103)
  - [ ] `skills-add-npx.sh`: remove file-level `# shellcheck disable=SC2012` at line 3
  - [ ] Gate: `./scripts/core/lint && ./scripts/core/static_analysis` passes green
  - **Gate:** `static_analysis` exit 0, lint exit 0, no SC2012 in output

- [ ] **P2 — Hardening & PR**
  - [ ] Run verification gate one final time: `./scripts/core/lint && ./scripts/core/static_analysis`
  - [ ] Review diff: confirm only comment changes in 2 files, no behavioral diffs
  - [ ] Ensure the branch is on local `fix/334-inline-shellcheck-disable`, not pushed
  - [ ] Open PR against `main` with title `fix: add inline shellcheck disable for SC2012 in wrappers` and body referencing `Closes #334`
  - [ ] Request review from issue author `@gtrabanco`