# ci-common — Instructions for OpenClaw

**What this repo is:** Shared reusable GitHub Actions workflows used by `automation`, `homelab`, and `mac-config`. Editing here affects the security scanning and notification pipelines that all repos share.

## Pipeline

No CI of its own (workflows are all `workflow_call`). Check via:
```bash
gh run list --repo mikrosag/ci-common --limit 5
gh pr list --repo mikrosag/ci-common
```

There is no pipeline failure notification. A `notify-telegram.yml` workflow used to exist but never delivered a message (org-level secrets don't reach private repos on the Free plan) and was removed 2026-08-10 — Frans does not want Telegram notifications for CI. Check status with the `gh run list` command above; don't re-add a notifier without asking.

## Critical rules

- Edits to reusable workflows take effect immediately for all callers — no staging.
- Don't rename workflow inputs or job names without updating every caller.

See [AGENTS.md](AGENTS.md) for full rules.
