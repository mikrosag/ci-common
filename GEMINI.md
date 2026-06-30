# ci-common — Instructions for Gemini

**What this repo is:** Shared reusable GitHub Actions workflows for the `mikrosag` org. This is a library — it has no deploy step of its own. Workflows here are called by `automation`, `homelab`, and `mac-config` via `uses: mikrosag/ci-common/.github/workflows/<name>.yml@main`.

## Workflows provided

| File | Called by | Purpose |
|---|---|---|
| `security-checks.yml` | all repos | gitleaks + semgrep |
| `sca-scan.yml` | all repos | osv-scanner (observability) |
| `dynamic-tests-nix.yml` | automation | pytest in Nix devShell |
| `container-scan.yml` | homelab | trivy (CRITICAL/HIGH fails) |
| `lint-js.yml` | homelab | ESLint |
| `notify-telegram.yml` | all repos | failure notifications |

## Pipeline interaction

```bash
gh run list --repo mikrosag/ci-common --limit 5   # ci-common's own Dependabot updates
gh pr list --repo mikrosag/ci-common
```

ci-common has **no CI of its own** (all workflows are `workflow_call` only) — so PRs here show "no checks reported." That's expected.

## Critical rules

- Changes to a reusable workflow affect every caller immediately on their next run.
- Templates under `templates/` are one-time copies — editing here doesn't update repos that already copied them.
- `inputs`/job names in reusable workflows are a public API — changing them breaks callers.

See [AGENTS.md](AGENTS.md) for full rules.
