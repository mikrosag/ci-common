# ci-common

Shared CI/CD infrastructure for repos in the `mikrosag` org. There is one self-hosted GitHub Actions runner (a `LaunchDaemon` on Frans's Mac, registered at the **org** level, default runner group → automatically available to every repo in `mikrosag`, no per-repo runner setup needed).

## What lives here

- `.github/workflows/security-checks.yml` — reusable workflow (`workflow_call`): `gitleaks` secret scanning + `semgrep` SAST. Call it from any repo's `pull_request`-triggered CI:
  ```yaml
  jobs:
    security:
      uses: mikrosag/ci-common/.github/workflows/security-checks.yml@main
  ```
- `.github/workflows/dynamic-tests-nix.yml` — reusable workflow: runs a repo's test suite inside a Nix devShell (`nix develop -c <test-command>`), for reproducible/hermetic dependency pinning. Requires the calling repo to have its own `flake.nix` (see `templates/nix-test/`).
- `.github/workflows/dynamic-tests-container.yml` — reusable workflow: builds `Dockerfile.test` and runs the test suite inside the resulting container via OrbStack/Docker. For repos that already ship as containers (see `templates/orbstack-test/`).
- `templates/launchd-deploy/` — for repos that ship as scheduled launchd jobs on the Mac (the `automation` repo is the reference implementation of this).
- `templates/orbstack-deploy/` — for repos that ship as a container via OrbStack on the Mac.
- `templates/nix-test/`, `templates/orbstack-test/` — scaffolding for the two dynamic-test reusable workflows above.

## Org-wide conventions (apply to every repo, not just this one)

- **Branch protection:** `main` is PR-gated, no direct pushes. CI (`pull_request` trigger) must pass before merge. `deploy.yml` (`push` to `main` trigger) runs only after merge.
- **Runner:** all repos `runs-on: [self-hosted, macOS]` — same physical runner serves the whole org via the default runner group.
- **Dynamic tests run against mocked externals, not live services.** Unit-test pure/parseable logic; mock network, email, browser, subprocess. See `automation/tests/` for worked examples.
- **Nix is installed on the runner Mac but its profile script isn't auto-sourced in non-interactive shells.** Every `run:` step using `nix` must first do `echo "/nix/var/nix/profiles/default/bin" >> "$GITHUB_PATH"` (already handled inside `dynamic-tests-nix.yml` — only relevant if you're writing a new workflow that uses Nix directly).
- **Nix flakes only see git-tracked/staged files.** New `flake.nix` or test files must be `git add`ed before `nix develop` works, even before committing.
- **Deploy logic stays per-repo** (different repos deploy to different places — launchd vs. OrbStack), but should start from the matching template here rather than being designed from scratch.
- **Agent instructions:** every repo should have its own `AGENTS.md` (canonical) with tool-specific stubs (`CLAUDE.md`, `GEMINI.md`, etc.) — see `automation/AGENTS.md` for the pattern. This repo only carries `AGENTS.md` + `CLAUDE.md` since it's infra that's edited rarely; replicate the fuller stub set in repos that get frequent day-to-day edits.

## Versioning

Callers should pin to a tag once this repo stabilizes (e.g. `@v1`) rather than `@main`, so a change here can't silently break every repo's CI at once. Currently early enough that everything points at `@main` — revisit once there's more than one consumer repo.
