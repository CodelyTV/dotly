# Active fixes

Index of in-progress and pending fixes. Merged fixes are removed from this table —
history lives in git log + closed issues.

## Status legend

- `pending` — SPEC drafted, branch not yet open
- `in-progress` — branch open, work ongoing
- `done` — built, PR open, awaiting merge (merge state lives in the forge — same
  meaning as the roadmap's `done`); remove the row only **after** the PR merges

## Active

| Folder | Topic | Status | Depends on | Issue |
|--------|-------|--------|------------|-------|
| `268-restorer-installer-tests` | tests for restorer and installer bootstrap | done · [#324](https://github.com/gtrabanco/dotSloth/pull/324) | — | #268 |
| `300-audit-set-euo-pipefail` | audit standalone scripts for missing set -euo pipefail | pending | — | #300 |
| `329-bun-dump-readonly-error` | fix `dot package dump` crash with custom manager files lacking dump function | done · [#331](https://github.com/gtrabanco/dotSloth/pull/331) | — | #329 |
| `333-happy-path-import-test` | add happy-path integration test for skills::import | done · [#335](https://github.com/gtrabanco/dotSloth/pull/335) | — | #333 |

## Conventions

- One folder per fix: `docs/fix/<issue-number>-<topic>/SPEC.md`.
- Every fix has a tracked issue; the PR closes it.
- Remove the row when the PR merges.
