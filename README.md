# ci-common

Shared CI/CD infrastructure for repos in the `mikrosag` org. There is one self-hosted GitHub Actions runner (a `LaunchDaemon` on Frans's Mac, registered at the **org** level, default runner group → automatically available to every repo in `mikrosag`, no per-repo runner setup needed).

## What lives here

- `.github/workflows/security-checks.yml` — reusable workflow (`workflow_call`): `gitleaks` secret scanning + `semgrep` SAST. Call it from any repo's `pull_request`-triggered CI:
  ```yaml
  jobs:
    security:
      uses: mikrosag/ci-common/.github/workflows/security-checks.yml@main
  ```
- `templates/launchd-deploy/` — for repos that ship as scheduled launchd jobs on the Mac (the `automation` repo is the reference implementation of this).
- `templates/orbstack-deploy/` — for repos that ship as a container via OrbStack on the Mac.

## Org-wide conventions (apply to every repo, not just this one)

- **Branch protection:** `main` is PR-gated, no direct pushes. CI (`pull_request` trigger) must pass before merge. `deploy.yml` (`push` to `main` trigger) runs only after merge.
- **Runner:** all repos `runs-on: [self-hosted, macOS]` — same physical runner serves the whole org via the default runner group.
- **Deploy logic stays per-repo** (different repos deploy to different places — launchd vs. OrbStack), but should start from the matching template here rather than being designed from scratch.
- **Agent instructions:** every repo should have its own `AGENTS.md` (canonical) with tool-specific stubs (`CLAUDE.md`, `GEMINI.md`, etc.) — see `automation/AGENTS.md` for the pattern. This repo only carries `AGENTS.md` + `CLAUDE.md` since it's infra that's edited rarely; replicate the fuller stub set in repos that get frequent day-to-day edits.

## Versioning

Callers should pin to a tag once this repo stabilizes (e.g. `@v1`) rather than `@main`, so a change here can't silently break every repo's CI at once. Currently early enough that everything points at `@main` — revisit once there's more than one consumer repo.
