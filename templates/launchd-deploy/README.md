# launchd-deploy template

For a new repo that should run as scheduled launchd jobs on this Mac — same pattern as `automation`.

## Setup

1. Layout: `scripts/` for the executables, `launchd/` for one `.plist` per job, `ProgramArguments` pointing at `/Users/frans/git/<repo-name>/scripts/<name>`.
2. Copy `deploy.sh` into `<repo>/deploy/install_launchd.sh`, set `DEPLOY_DIR`.
3. CI: `ci.yml` (on `pull_request`) runs `security-checks.yml` from this repo plus a language-appropriate syntax check (e.g. `py_compile` + `plutil -lint`). `deploy.yml` (on `push` to `main`) re-runs the syntax check then `bash deploy/install_launchd.sh`.
4. Branch protection on `main`: require PR, required status checks = the `ci.yml` job names, no direct pushes. See `automation`'s repo settings as the reference.
5. Add `AGENTS.md` (+ stubs) following `automation`'s pattern.

See `automation/AGENTS.md` and `automation/.github/workflows/` for a working, deployed reference implementation of this exact template.
