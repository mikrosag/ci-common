# ci-common — Instructions for OpenClaw

**What this repo is:** Shared reusable GitHub Actions workflows used by `automation`, `homelab`, and `mac-config`. Editing here affects the security scanning and notification pipelines that all repos share.

## Pipeline

No CI of its own (workflows are all `workflow_call`). Check via:
```bash
gh run list --repo mikrosag/ci-common --limit 5
gh pr list --repo mikrosag/ci-common
```

The `notify-telegram.yml` workflow here is what sends Telegram notifications to Frans when any pipeline fails. The bot token and chat ID are org-level secrets (`TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`).

## Critical rules

- Edits to reusable workflows take effect immediately for all callers — no staging.
- Don't rename workflow inputs or job names without updating every caller.

See [AGENTS.md](AGENTS.md) for full rules.
