# Repository State

**Status:** frozen
**Generated:** 2026-07-31
**Revision:** 645dce7 (HEAD of main)

---

## Repository Facts

Each fact carries direct evidence (file:line or command output).

### Project identity

| Fact | Evidence |
|------|----------|
| Project is "dotSloth" — modular Bash dotfiles framework, fork of CodelyTV/dotly | `README.md:1`, `CLAUDE.md:54` |
| Architecture: modular monolith with context-based namespacing (command-dispatch pattern) | `docs/architecture/ARCHITECTURE.md:5` |
| Entry point: `bin/dot` resolves `<context> <script> [args]`, sources `_main.sh`, dispatches | `docs/architecture/ARCHITECTURE.md:7-10` |
| Core libraries: `scripts/core/src/` contains 24 sourced `.sh` files | `scripts/core/src/` directory listing |
| Contexts: 10 directories under `scripts/` — core, dotfiles, generator, init, mac, package, script, self, shell, symlinks | `scripts/` directory listing |
| Entry point binaries: `bin/dot`, `bin/up`, `bin/sloth`, `bin/git-discard`, `bin/git-undo`, `bin/open`, `bin/pbcopy`, `bin/pbpaste` | `bin/` directory listing |
| Target platforms: Linux, macOS, FreeBSD | `CLAUDE.md:68` |

### Tooling and verification

| Fact | Evidence |
|------|----------|
| Verification gate: `bash scripts/self/static_analysis && bash scripts/self/lint && make test` | `CLAUDE.md:50-52`, `docs/features/SHIP_DECISIONS.md:43` |
| `scripts/self/lint` runs `shfmt -ln bash -sr -ci -i 2` on all bash files (excludes `shell/zsh/`) | `scripts/self/lint:60,69,86` |
| `scripts/self/static_analysis` runs `shellcheck -s bash -S warning -e SC1090 -e SC2010 -e SC2154` | `scripts/self/static_analysis:36` |
| Tests: bats-core, 200 tests passing on `main` | `bats --recursive tests/ → 1..200` |
| Test structure: `tests/{core,package,scripts,integration,helpers}/` | `tests/` directory listing |
| Mock harness for external commands exists at `tests/helpers/mocks.sh` | `tests/README.md:103-104` |
| Pre-commit hooks: `.pre-commit-config.yaml` with shfmt-format, shfmt-lint, bats-test (3 local hooks) | `.pre-commit-config.yaml:1-29` |
| CI: GitHub Actions (`.github/workflows/ci.yml`) with build (macOS+Ubuntu), format (macOS+Ubuntu), static-analysis (Ubuntu), lint (Ubuntu), test (macOS+Ubuntu) | `.github/workflows/ci.yml:1-165` |
| `make test` target runs `bats --recursive tests/` | `Makefile:86-89` |
| `make format` target runs `shfmt -w -ln bash -sr -ci -i 2` on scripts/bin/shell/dotfiles_template/_raycast | `Makefile:63-67` |

### Git state

| Fact | Evidence |
|------|----------|
| Current branch: `main` | `git branch --show-current → main` |
| Working tree: clean | `git status --short → (empty)` |
| Latest tag: `v4.3.1` | `git tag --sort=-v:refname → v4.3.1` |
| Latest commit: `645dce7` — "fix: correct skills::import install command to use skills add subcommand (#339)" | `git log --oneline -1` |
| 133 commits since 2026-07-06 | `git log --oneline --since="2026-07-06" --until="2026-07-31" \| wc -l` |

### Open work (GitHub)

| Fact | Evidence |
|------|----------|
| 4 open issues: #334 (shellcheck SC2012), #330 (package dump/import for skills), #273 (gem.bats grep tests), #224 (documentation improvements) | `gh issue list --state open` |
| 0 open PRs | `gh pr list --state open → (empty)` |

### Directory structure (top-level)

| Fact | Evidence |
|------|----------|
| Top-level entries: `_raycast/`, `.claude/`, `.editorconfig`, `.git/`, `.github/`, `.gitignore`, `.opencode/`, `.pre-commit-config.yaml`, `.worktrees/`, `AGENTS.md`, `agents/`, `bin/`, `CLAUDE.md`, `docs/`, `dotfiles_template/`, `dotly-migrator`, `ic_twitter_share.svg`, `IDEA.md`, `installer`, `langs/`, `LICENSE`, `Makefile`, `migration/`, `os/`, `README.md`, `restorer`, `scripts/`, `shell/`, `sloth.png`, `sloth.svg`, `symlinks/`, `tests/` | `ls` output |
| `.claude/` contains `hooks/`, `README.md`, `settings.json.example` | `.claude/` directory listing |
| `.opencode/` contains `.gitignore`, `index/`, `node_modules/`, `package-lock.json`, `package.json` | `.opencode/` directory listing |

---

## Accepted Decisions

Sourced from `docs/features/SHIP_DECISIONS.md` and `docs/features/ROADMAP.md`.

| Decision | Record | Rationale |
|----------|--------|-----------|
| Run mode: `--fullauto` (auto-merge with non-negotiable safety floors) | `SHIP_DECISIONS.md:3` | Dual-keyed: flag + decision record |
| Rust migration (features 01-03) deferred, not cancelled | `SHIP_DECISIONS.md:26-34` | Requires native binary distribution infrastructure; revisit when Bash codebase is stable |
| Stack: Bash, shfmt + shellcheck, bats-core | `SHIP_DECISIONS.md:37` | Confirmed in interview round 3 |
| Architecture: modular monolith with context-based namespacing | `SHIP_DECISIONS.md:38` | No changes from substrate |
| Merge policy: `--fullauto` with safety floors | `SHIP_DECISIONS.md:51` | No merge without explicit user permission (hard rule in CLAUDE.md) |
| Feature 12 (skill-lockfile): designed, SPEC complete | `docs/features/12-skill-lockfile/SPEC.md:345-348` | `Design status: designed` marker present |
| Issue #202: closed as wontfix (obsolete) | `docs/LOGS.md:42` | Fix merged in PR #204 in 2022 |

---

## Planned work

### Roadmap features

| NN | Slug | Status | Depends on | Issue |
|----|------|--------|------------|-------|
| 01 | rust-tooling | planned | — | #236 |
| 02 | rust-dot-cli | planned | 01 | #237 |
| 03 | rust-up-cli | planned | 01 | #238 |
| 04 | upstream-sync | done | — | #239 |
| 05 | testing-framework | done | — | #240 |
| 06 | pm-timeouts | done | — | #241 |
| 07 | restorer-v2 | done | — | #242 |
| 08 | test-coverage-expansion | done | — | #267 |
| 09 | mock-harness | done | — | #302 |
| 10 | core-library-tests | done | 09 | #301 |
| 11 | local-ci-pre-commit | done | — | #328 |
| 12 | skill-lockfile | designed | — | (no issue linked) |

Source: `docs/features/ROADMAP.md:9-21`

### Active fixes (from `docs/fix/README.md`)

| Folder | Topic | Status | Issue |
|--------|-------|--------|-------|
| `268-restorer-installer-tests` | tests for restorer and installer | done · PR #324 | #268 |
| `300-audit-set-euo-pipefail` | audit standalone scripts for missing set -euo pipefail | pending | #300 |
| `329-bun-dump-readonly-error` | fix `dot package dump` crash with custom manager files lacking dump function | done · PR #331 | #329 |
| `333-happy-path-import-test` | add happy-path integration test for skills::import | done · PR #335 | #333 |
| `338-package-import` | correct skills::import install command | done · PR #339 | #338 |

---

## Documentation

Claims that exist only in documentation, without separate implementation evidence.

| Claim | Source |
|-------|--------|
| "158 tests" in ship report (now 200 by direct count) | `SHIP_REPORT_2026-07-07.md:34` |
| "product-audit is due now" (every 5 merged units or pre-release) | `SHIP_REPORT_2026-07-07.md:119-120` |
| Skills installed via `bunx skills add` / `npx skills add` | `docs/features/12-skill-lockfile/SPEC.md:14` |
| `.skill-lock.json` schema: `{provider, branch, agents, command, installed_at}` | `docs/features/12-skill-lockfile/SPEC.md:127-134` |
| `skill-lock.yaml` dump file schema: `{format, providers[]}` | `docs/features/12-skill-lockfile/SPEC.md:146-163` |
| Init scripts must be idempotent and fast | `docs/architecture/ARCHITECTURE.md:37` |
| `set -euo pipefail` mandatory in all standalone/executable scripts | `docs/architecture/ARCHITECTURE.md:38` |
| Core libraries intentionally omit `set -e` | `docs/architecture/ARCHITECTURE.md:38` |
| Installer/restorer must be self-contained | `docs/architecture/ARCHITECTURE.md:34` |

---

## Inference

Reasoning based on observed evidence.

| Inference | Basis |
|-----------|-------|
| Feature 12 (skill-lockfile) was implemented and merged but not yet registered in ROADMAP.md as `done` | Commits `8446145` through `645dce7` show full P1-P4 execution + fold fixes + PR #332 merge; ROADMAP.md has no row for 12 |
| The `agents/` directory is a new top-level directory created by feature 12 | `ls` shows `agents/` at top level; SPEC.md defines `$DOTFILES_PATH/agents/` |
| Fix #300 (set -euo pipefail audit) is the only pending fix — all others are done | `docs/fix/README.md` shows only `300-audit-set-euo-pipefail` as `pending` |
| The verification gate runs 3 stages: static_analysis (shellcheck) → lint (shfmt) → test (bats) | `CLAUDE.md:50-52`, Makefile targets |
| The project has no MCP server dependencies (stated in CLAUDE.md) | `CLAUDE.md:148-150` |
| Test count grew from 158 (ship report 2026-07-07) to 200 (current) — 42 new tests since the ship report | `SHIP_REPORT_2026-07-07.md:34` vs `bats --recursive tests/ → 1..200` |

---

## Open Questions

| Question | Context |
|----------|---------|
| Should feature 12 (skill-lockfile) be registered in ROADMAP.md? | Implemented and merged (PR #332) but no roadmap row exists |
| Is a product-audit due? | Ship report says "every 5 merged units or pre-release" — 5+ units have merged since last audit |
| What is the status of the `agents/` directory at top level vs `$DOTFILES_PATH/agents/`? | SPEC says dump file goes to `$DOTFILES_PATH/agents/skill-lock.yaml`; top-level `agents/` exists in the repo |
| Is fix #300 (set -euo pipefail audit) still relevant? | pending status in fix README; last touched in commit `2c021ff` |

---

## Contradictions

None recorded. Snapshot is frozen.
