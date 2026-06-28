# ci-common — instructions for AI coding agents

This repo holds shared CI/CD infrastructure for the `mikrosag` GitHub org: a reusable security-checks workflow, and deploy templates for launchd and OrbStack targets. It is infra that's edited rarely — see `README.md` for what's here and the org-wide conventions every `mikrosag` repo follows.

## Hard rules

- This repo has no deploy step of its own — it's a library other repos call into. Don't add a `deploy/` step here.
- Changes to `.github/workflows/security-checks.yml` affect every repo that calls it via `uses: mikrosag/ci-common/.github/workflows/security-checks.yml@main`. Treat edits here as changing shared infrastructure, not a single repo's config — check `README.md`'s versioning note before changing the reusable workflow's interface (inputs/job names), since callers may reference job names in their branch protection required-status-checks list.
- Templates under `templates/` are copied into other repos, not referenced live — editing a template here does not retroactively update repos that already copied it.
- **Working a kanban card?** Pick it up from the [`mikrosag Roadmap`](https://github.com/orgs/mikrosag/projects/1) GitHub Project. Check the issue body for a `Spec: <notion-url>` line — if present, read it before implementing, it has context the issue body doesn't. Move the project item's Status to `In Progress` when you start, `Done` when your PR merges. **There is no Notion mirror to update** — GitHub is the only place status lives. Only touch the Notion `mikrosag Use Cases` database if the spec itself needs revising. See `README.md`'s Kanban section for the full convention.
