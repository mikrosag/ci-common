# ci-common — Instructions for Hermes

**What this repo is:** Shared reusable GitHub Actions workflows for the `mikrosag` org. A library — other repos call into it, it doesn't deploy anything itself.

## Pipeline

- No CI on PRs (all workflows are `workflow_call` only) — "no checks reported" is normal.
- Status: `gh run list --repo mikrosag/ci-common --limit 5`

## Critical rules

- Every change here immediately affects all `mikrosag` callers on their next run.
- Reusable workflow `inputs` and job names are a public API — don't rename without updating callers.
- `templates/` are one-time copies — editing doesn't update repos that already copied them.

See [AGENTS.md](AGENTS.md) for the full picture.
