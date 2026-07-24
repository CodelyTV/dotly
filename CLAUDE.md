# CLAUDE.md

Guidance for AI coding agents working in this repository.

Always read the relevant documentation before changing code.

## Documentation map

The single most important table: it tells an agent which doc owns what, so it reads the right context before acting. Delete rows you don't have; add rows for your domains.

| Task | Required docs |
|---|---|
| Any code change | `docs/architecture/ARCHITECTURE.md` |
| New feature / planning / sequencing | `docs/features/ROADMAP.md`, `docs/features/_TEMPLATE/SPEC.md` |
| A fix | `docs/fix/_TEMPLATE/SPEC.md`, `docs/fix/README.md` |
| Session journal / resuming work | `docs/LOGS.md` (written by `/log-session` + the `.claude/` hooks) |

## Workflow conventions (the skills read this)

The single source of truth for what every agentic-workflow skill does first and always honors — referenced by the skills instead of restated in each one.

**Discovery (always first).** Before acting, read: this guide + the documentation map above, the roadmap (`docs/features/ROADMAP.md`), and the template(s) or recent artifacts for the task at hand. Never assume paths or formats; if a doc is missing, say so and fall back to these conventions rather than guessing.

**Forge (issue/PR tracker):** GitHub (`gh`) — the CLI the skills use for issues and PRs. The auto-close convention (`Closes #N` in the PR body) must hold.

**Git workflow:** worktrees — parallel units in separate checkouts. Every skill that creates a branch uses `git worktree add` to isolate work; the working tree is always the unit you're on. Worktrees are created under `../dotSloth-<branch-name>` (sibling of the repo root).

**Hard rules (always honored).**

- **Branch & PR:** never work on `main`; one PR per unit against `main`; never stack — see PR & branch workflow.
- **Gate before commit:** the verification gate (lint + static analysis) is green — see Commands.
- **Docs language:** every committed artifact in English, whatever language the work was requested in.
- **Evidence over reflex:** verify claims against the code (counts, repro, thresholds) and cite paths; don't assert from assumption.
- **Track, don't inline:** deferred work becomes a tracked issue / known-issue, never silently implemented.
- **Shell compatibility:** all scripts must be POSIX-compatible bash. Never use bashisms that break on macOS default bash (3.2) unless explicitly guarded. Test with `bash --posix` where feasible.
- **`set -euo pipefail`:** all new scripts must use this header. Existing scripts that lack it should be migrated when touched.
- **NO MERGE WITHOUT EXPLICIT PERMISSION:** You are STRICTLY PROHIBITED from merging any PR unless the human user explicitly says "merge" or gives unambiguous merge permission. Do NOT merge when asked to "review," "approve," "check," "audit," or any other non-merge instruction. The only actions you may take on a PR without explicit permission are: review, comment, request changes, run checks, and report status. Merging is the ONE action that requires explicit approval — treat it as such.

**Question protocol (when a skill must ask the user to decide).** Only ask when the answer materially changes the artifact — make routine choices silently and record them. Each question states: what is being decided; its scope (files, behavior, consumers affected); its criticality (critical / high / medium / low); and each option with pros and cons separately, recommendation flagged.

## Commands

```bash
# Lint (shfmt — formatting check, can auto-patch with --patch)
./scripts/core/lint

# Static analysis (shellcheck — warnings and above)
./scripts/core/static_analysis

# Verification gate (must pass before every commit):
./scripts/core/lint && ./scripts/core/static_analysis
```

## Architecture

This project's architecture is documented in `docs/architecture/ARCHITECTURE.md`. The workflow is architecture-agnostic — it does not assume any particular pattern. Record your chosen pattern, its layers/modules, and the dependency-direction rules that must never be violated in that doc, and the skills will respect them.

State the invariants explicitly there (e.g. "core scripts must not source dotfiles user scripts", "package manager wrappers must implement the dump/install/update interface"). Reference them from SPECs.

## Hard rules

Generic, stack-independent guardrails. Add your own.

- **Dependencies:** justify every new dependency; prefer the platform/standard library; pin versions. Avoid redundant libraries that duplicate existing ones. For shell tools, prefer POSIX builtins over external commands; document any external command requirement via `script::depends_on`.
- **Honesty to the user:** never hide real limitations of the product (limits, reductions, restrictions). Disclose them in the UI/output.
- **Secrets:** never commit secrets; read them from the environment/secret store. Init scripts (`shell/init.scripts/`) are the designated place for loading sensitive env vars.
- **Docs language:** all committed artifacts in English, regardless of the language the work was requested in.
- **Cross-platform:** dotSloth targets Linux, macOS, and FreeBSD. Never use platform-specific commands without a guard (`platform::command_exists` or equivalent). Use `command -p` for portable command resolution.

## Testing philosophy

Prefer integration tests over heavy mocking. Test behavior, not implementation detail. For Bash scripts, test by executing the script with representative inputs and verifying exit codes and output. State the required test layer for a change in its SPEC.

## Naming conventions

| Type | Convention |
|---|---|
| Script files | `snake_case` (e.g. `install_remote`, `static_analysis`) |
| Shell functions | `snake_case` with `::` namespace (e.g. `dot::list_contexts`, `package::is_installed`) |
| Directories | `snake_case` for scripts, `kebab-case` for docs |
| Environment variables | `UPPER_SNAKE_CASE` (e.g. `SLOTH_PATH`, `DOTFILES_PATH`) |
| Context scripts | `<context>/<script_name>` (e.g. `core/install`, `package/add`) |

## Feature workflow

Features are planned before they are coded. Flow:

1. `SPEC.md` (from `docs/features/_TEMPLATE/SPEC.md`)
2. `PLAN.md`
3. `TASKS.md`
4. execution by phase (one phase per commit, gate-verified)
5. hardening
6. verification & review
7. PR

Phases are labelled `P1, P2, …` ("phases") everywhere — `PLAN.md`, `TASKS.md`, `progress.md`, commits — never `S1`/"Steps". The label is `execute-phase`'s argument (`execute-phase NN P2`), so it must stay uniform.

Start a new feature by copying `docs/features/_TEMPLATE/SPEC.md` to `docs/features/<NN>-<slug>/SPEC.md` and registering it in `docs/features/ROADMAP.md` (the source of truth for numbering, order, and dependencies).

## Fix workflow

A fix is lighter than a feature: only a `SPEC.md` (from `docs/fix/_TEMPLATE/SPEC.md`), registered in `docs/fix/README.md`, no planning artifacts. Every fix has a tracked issue; its PR closes it.

## Session log

`docs/LOGS.md` is an append-only journal of working sessions — the why and the what-next that git history doesn't record. Two ways it's written, both optional:

- `/log-session` (manual, rich) — summary, decisions, next step. Run it before `/clear` or before closing for the day.
- `.claude/` hooks (automatic, free) — append a mechanical entry on `/clear` and exit; an opt-in hook re-injects the last entry to resume context. Copy `.claude/settings.json.example` to enable; see `.claude/README.md`.

## PR & branch workflow

One PR per unit of work, always against `main`. Each PR must be independently mergeable: it passes the verification gate and delivers standalone value.

Never work on `main` directly. Create a worktree first (`feat/<NN>-<slug>` or `fix/<n>-<topic>`).

Never stack PRs. A PR's base is always `main`. If a feature is too large, split it into independently shippable slices — never by internal phases.

**Merge gate (AI only).** BEFORE assisting with ANY merge of any unit PR:
1. Run `make format`, `make lint`, and `make test` locally — all must pass
2. Verify CI checks are green on the PR
3. **NEVER merge a PR without explicit, unambiguous instruction from the human user.** The only conditions under which you may merge are:
   - The human explicitly says "merge" or "go ahead and merge" (or equivalent unambiguous permission), OR
   - You run `/audit-pr` and the human explicitly says "merge after audit" (or equivalent unambiguous permission)
4. Merging is NOT a default action. You do NOT merge unless told to. If the human says "approve this," "review this," "check this," or any other non-merge instruction — DO NOT merge.
5. When the local checks and CI are both green AND the human has given explicit merge permission, proceed with the merge (ask which merge strategy: `--merge`, `--squash`, or `--rebase`).

## Commit format

```
feat(<area>): <summary>
fix(<area>): <summary>
chore(<area>): <summary>
```

Areas: `core`, `scripts`, `package`, `shell`, `symlinks`, `loader`, `docs`, `installer`.

## Skills

This project uses the agentic workflow skills (`gtrabanco/agentic-workflow`), installed with:

```bash
npx skills add gtrabanco/agentic-workflow
```

They discover this project's docs (the map above) at runtime and drive the feature/issue workflow. When repeated searches or doc lookups recur, create a project-specific skill to capture the knowledge instead of re-deriving it.

## MCP servers

None. This project has no MCP server dependencies.
