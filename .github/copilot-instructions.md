# Instructions for GitHub Copilot

**What this repo is:** Shared reusable GitHub Actions workflows for the `mikrosag` org. Edits here affect every repo's CI pipeline immediately.

## Pipeline (for Copilot in Xcode or any editor)

- **No CI of its own** — all workflows are `workflow_call` only. "No checks reported" on PRs is expected behavior.
- **Check status:** `gh run list --repo mikrosag/ci-common --limit 5`
- **Open PRs:** `gh pr list --repo mikrosag/ci-common`

## Callers

| Repo | Workflows used |
|---|---|
| `automation` | security-checks, sca-scan, dynamic-tests-nix |
| `homelab` | security-checks, sca-scan, container-scan, lint-js |
| `mac-config` | (future — currently no CI) |

## Critical rules

- **Changes to reusable workflows take effect immediately for all callers** — treat every edit as org-wide infrastructure change.
- **`inputs` and job names are a public API** — renaming them breaks any caller that references them by name (e.g., required-status-checks).
- **Templates (`templates/`) are one-time copies** — editing them here doesn't retroactively update repos that already used them.
- **Don't add a `deploy/` step** — this is a library, not a deployable service.

See [AGENTS.md](../AGENTS.md) for full instructions.
