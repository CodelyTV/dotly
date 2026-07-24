# progress.md — 334-inline-shellcheck-disable

## P1 — 2026-07-24
- Done: added inline `# shellcheck disable=SC2012` before each `ls -1`/`ls -1t` invocation in both files (3 per file); removed dead file-level disables at line 3 in both files; verification gate passes green
- Remains: P2 — Hardening & PR (final gate, diff review, create PR)
- Gotchas: Issue created as #336 instead of planned #334 (GitHub sequential numbering); SPEC and fix-index updated to reference #336
- Files: `scripts/package/src/wrappers/skills-add-bunx.sh`, `scripts/package/src/wrappers/skills-add-npx.sh`, `docs/fix/334-inline-shellcheck-disable/SPEC.md`, `docs/fix/README.md`
- Next: P2 — Hardening & PR
