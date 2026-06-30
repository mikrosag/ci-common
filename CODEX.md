# ci-common — Instructions for Codex

**What this repo is:** Shared GitHub Actions reusable workflow library for the `mikrosag` org. No deploy step — it's called by other repos via `uses: mikrosag/ci-common/.github/workflows/<name>.yml@main`.

## Key facts

- **No CI of its own** — all workflows are `workflow_call`. PRs show "no checks reported." Expected.
- **Changes are immediately live** for all callers on their next workflow run — treat as shared infrastructure.
- **Templates (`templates/`)** are copied into other repos, not referenced live. Editing here doesn't retroactively update them.

## Pipeline interaction

```bash
gh run list --repo mikrosag/ci-common --limit 5
gh pr list --repo mikrosag/ci-common
```

## Critical rules

- Don't change reusable workflow `inputs` or job names without checking all callers (`automation`, `homelab`, `mac-config`) — those names may be in required-status-checks lists.
- Don't add a `deploy/` step here.

See [AGENTS.md](AGENTS.md) for full rules.
