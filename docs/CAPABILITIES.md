# Capability inventory

> The maintained list of this project's **cross-cutting subsystems** and
> **roles** — the substrate `design-feature`'s *Integration closure* walks so
> no feature ships without deciding how it touches auth, ACL, navigation, and
> the rest. A model cannot reliably *guess* which subsystems your project has,
> but it can *walk a list* — this file is that list.
>
> **Ownership & lifecycle:** seeded by `init-workspace` (from discovery +
> interview); **extended by `execute-phase`** whenever a phase introduces a new
> subsystem, role, or permission (additive, in the same commit as the code);
> freshness-checked by `product-audit` (inventory ↔ code drift is a Process &
> docs finding); **read by `design-feature`** for every feature's Integration
> closure. Keep every row honest — a subsystem marked `no` is as load-bearing
> as one marked `yes` (it tells the designer what does NOT exist yet).

## Roles

Every role/permission level the project has. `design-feature`'s role matrix
must list EVERY row here with an explicit `allowed`/`denied` per capability.

| Role | Description | Granted where |
|---|---|---|
| `user` | The person running `dot <context> <script>` interactively in their shell | Any machine where dotSloth is installed; the default identity of every `bin/dot` invocation |
| `contributor` | A developer authoring or extending dotSloth itself, or their own dotfiles overrides | Write access to `$DOTFILES_PATH/scripts/` (user dotfiles) and/or the dotSloth repo |
| `maintainer` | A project owner with merge/publish authority over the dotSloth repository | GitHub repository collaborator/owner role on the dotSloth repo; publishes releases, merges PRs |

## Cross-cutting subsystems

One row per subsystem. `Exists` is `yes | no | partial` — never blank. Delete
rows that can never apply to this product (e.g. `Billing` for an internal
tool) and add project-specific ones (the fixed set below is the floor, not the
ceiling).

| Subsystem | Exists | Surfaces / entry points | Notes |
|---|---|---|---|
| Authentication | `no` | — | No login/session/identity system. The only credential is the optional `GITHUB_TOKEN` env var read by `scripts/core/src/github.sh` to authenticate against the public GitHub API; it is a machine credential, not user authentication. |
| ACL / permissions | `no` | — | No per-user or per-role permission checks anywhere in the codebase. Trust model is "whoever can run `dot` owns the machine". |
| Navigation (menus, dashboard) | `partial` | `bin/dot` context dispatch, `dot <context> <script> --help`, `dot` usage output | Command dispatch + help is the only "navigation"; no GUI/dashboard. Contexts enumerated from `scripts/` at runtime by `scripts/core/src/dot.sh`. |
| Notifications (email, push, in-app) | `no` | — | No messaging channels. CLI progress/log output only (`scripts/core/src/log.sh`, `output.sh`). |
| Search | `no` | — | No search index or search UI. |
| Audit log / activity trail | `no` | — | No persistent audit trail. `docs/LOGS.md` is a human-written session journal, not an app activity log. |
| Settings / preferences | `partial` | Shell env vars (`SLOTH_PATH`, `DOTFILES_PATH`, `GITHUB_TOKEN`, …), `dotfiles_template/` dotfiles, `scripts/mac/defaults` macOS defaults | Configuration is env-var + dotfile driven; no central settings store. macOS `defaults` writes are one-shot context commands. |
| Background jobs / scheduling | `no` | — | No cron/launchd/queue/worker scheduling. All work is synchronous CLI execution (`sloth_update.sh` performs updates on explicit invocation only). |
| File / media storage | `partial` | `symlinks/` symlink definitions, `dot symlinks` apply/restore, `scripts/core/src/github.sh` GitHub API request caching | No upload flow or bucket; "storage" is local file/symlink management plus a small on-disk API response cache. |
| i18n / localization | `no` | — | English-only output; no locale files or switcher. |
| Feature flags | `no` | — | No flag store or conditional feature gating. |
| Billing / payments | `no` | — | N/A — open-source dotfiles framework; no paid tier. |
| Public API / integrations | `partial` | `scripts/core/src/github.sh` GitHub REST API client (`GITHUB_API_URL`, `github::curl`), `scripts/package/src/` package-manager wrappers (brew, mas, nix, macports, …) | Outbound integration with GitHub (releases, tags, trees) and system package managers; no inbound public API or webhooks. |
