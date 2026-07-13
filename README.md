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
- `.github/workflows/sca-scan.yml` — reusable workflow: `osv-scanner` dependency/SCA scan (free, OSS, Google). Call from any repo's CI. **Observability-only (`continue-on-error: true`)** — surfaces findings in every PR's logs but doesn't block merges yet, since severity data is inconsistent across ecosystems and there's no triaged baseline. Needs a manifest (`requirements.txt`, `package.json`, etc.) to scan — a repo with deps declared only in `flake.nix` should also keep a `requirements.txt` mirror (see `automation/requirements.txt`) purely so this has something real to check.
- `.github/workflows/container-scan.yml` — reusable workflow: builds a Dockerfile and scans the image with `trivy`, failing on CRITICAL/HIGH by default. Only relevant for repos that build a container.
- `.github/workflows/lint-js.yml` — reusable workflow: `npm ci` + ESLint, for JavaScript/TypeScript repos (see `templates/lint-js/`).
- `.github/workflows/mcp-server-security-gate.yml` — reusable workflow: the fail-closed admission gate for onboarding a new MCP server onto `mcp-gateway`. Chains `security-checks.yml` + `sca-scan.yml` + `container-scan.yml` with three MCP-specific stages: `mcp-semgrep-rules` (prompt-injection-shaped tool descriptions, unrestricted filesystem paths, unsanitized shell-out, overly broad scopes — see `semgrep-rules/mcp-server.yml`), `sbom-sign` (Syft SBOM + keyless `cosign sign-blob`), and `policy-check` (`conftest` against `policy/mcp-server-compose.rego` + `policy/mcp-server-manifest.rego`, the latter also covering the runtime egress-allowlist requirement). See `templates/mcp-server-registry/` for how to wire a calling repo's `ci.yml`, and `homelab/mcp-gateway/registry/README.md` for the manifest schema and the `gateway-sync` flow this gate feeds into. Requires `cosign`/`syft`/`conftest` on the runner (added to `mac-config`'s pipeline-critical Homebrew list).
- `.github/workflows/notify-telegram.yml` — reusable workflow: posts a message to Frans's Telegram (the existing OpenClaw "HomeClaw" bot) via the Bot API. Call with `secrets: inherit` so the org-level `TELEGRAM_BOT_TOKEN`/`TELEGRAM_CHAT_ID` secrets pass through:
  ```yaml
  notify-failure:
    needs: [other-job]
    if: failure()
    uses: mikrosag/ci-common/.github/workflows/notify-telegram.yml@main
    secrets: inherit
    with:
      message: "🚨 something failed — link to the run"
  ```
- `templates/launchd-deploy/` — for repos that ship as scheduled launchd jobs on the Mac (the `automation` repo is the reference implementation of this).
- `templates/orbstack-deploy/` — for repos that ship as a container via OrbStack on the Mac.
- `templates/nix-test/`, `templates/orbstack-test/` — scaffolding for the two dynamic-test reusable workflows above.
- `templates/lint-js/` — scaffolding for `lint-js.yml`.

## Org-wide conventions (apply to every repo, not just this one)

- **Branch protection:** `main` is PR-gated, no direct pushes. CI (`pull_request` trigger) must pass before merge. `deploy.yml` (`push` to `main` trigger) runs only after merge.
- **Runner:** all repos `runs-on: [self-hosted, macOS]` — same physical runner serves the whole org via the default runner group.
- **Dynamic tests run against mocked externals, not live services.** Unit-test pure/parseable logic; mock network, email, browser, subprocess. See `automation/tests/` for worked examples.
- **Nix is installed on the runner Mac but its profile script isn't auto-sourced in non-interactive shells.** Every `run:` step using `nix` must first do `echo "/nix/var/nix/profiles/default/bin" >> "$GITHUB_PATH"` (already handled inside `dynamic-tests-nix.yml` — only relevant if you're writing a new workflow that uses Nix directly).
- **Nix flakes only see git-tracked/staged files.** New `flake.nix` or test files must be `git add`ed before `nix develop` works, even before committing.
- **Deploy logic stays per-repo** (different repos deploy to different places — launchd vs. OrbStack), but should start from the matching template here rather than being designed from scratch.
- **`ruff`, `osv-scanner`, `trivy` are installed via Homebrew on the runner Mac** (not containerized), same pattern as `gitleaks`/`semgrep`. If any goes missing: `brew install ruff osv-scanner trivy`.
- **Snyk, Aqua (platform), and similar paid SaaS scanners are deliberately not used.** Free/OSS equivalents cover the same ground: `osv-scanner` for SCA, `trivy` for container images, `semgrep`+`gitleaks` for SAST/secrets. Don't add a paid tool without a clear reason it's not covered.
- **`TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` are org-level secrets** (set via `gh secret set ... --org mikrosag`), visible to every repo. This is the existing OpenClaw bot token, reused rather than creating a second bot — don't print these values in logs or commit them anywhere, even in this private repo.
- **Notify on pipeline failure, not on every run.** Wire `notify-telegram.yml` with `if: failure()` so it only fires when something actually breaks — a message on every green run is noise, not signal.
- **Agent instructions:** every repo should have its own `AGENTS.md` (canonical) with tool-specific stubs (`CLAUDE.md`, `GEMINI.md`, etc.) — see `automation/AGENTS.md` for the pattern. This repo only carries `AGENTS.md` + `CLAUDE.md` since it's infra that's edited rarely; replicate the fuller stub set in repos that get frequent day-to-day edits.

## Kanban (GitHub Projects v2) + Notion use-case specs

- **Tracking lives entirely in GitHub:** [`mikrosag Roadmap`](https://github.com/orgs/mikrosag/projects/1) — an org-level GitHub Project v2, linked to `automation` and `ci-common`. Status field: `Backlog → Todo → In Progress → In Review → Done`. This is the only place status/assignment is tracked — there is no Notion mirror of it.
- **Notion holds use-case writeups, referenced one-way, not synced:** the `mikrosag Use Cases` database in Notion (workspace-level, separate from Frans's personal "My Tasks") is for cards that need more than a one-line description — context, constraints, a proposed approach, open questions. Not every card needs one. When a card does, its GitHub issue body gets a `Spec: <notion-url>` line.
- **Card → code flow:** pick an item from the project → if its issue body has a `Spec:` link, read it first → create a branch/PR referencing the issue → CI runs the usual checks → merge → mark the project item `Done` on GitHub (nothing to update in Notion unless the spec itself needs revising).
- **Why not a mirror:** an earlier version of this synced GitHub Project status into matching Notion rows. Dropped it — double bookkeeping on every card move, two places that could disagree, no real value since GitHub already tracks status natively. Notion's value here is long-form writing, not status tracking.
- **One-time setup still pending in the GitHub UI** (no stable API for this): open the project's `⋯` menu → Workflows → enable "Item added to project" (auto-add issues/PRs from linked repos) and "Item closed" (auto-set Status to Done). Quick, one-time, has to be clicked through.

## Versioning

Callers should pin to a tag once this repo stabilizes (e.g. `@v1`) rather than `@main`, so a change here can't silently break every repo's CI at once. Currently early enough that everything points at `@main` — revisit once there's more than one consumer repo.
