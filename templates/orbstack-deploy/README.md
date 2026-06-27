# orbstack-deploy template

For a new repo that should run as a container on this Mac via OrbStack.

## Setup

1. Repo needs a `Dockerfile` and `docker-compose.yml` at its root.
2. Copy `deploy.sh` into `<repo>/deploy/deploy.sh`, set `DEPLOY_DIR` to `/Users/frans/git/<repo-name>`.
3. Copy the job blocks from `workflow-snippet.yml` into `<repo>/.github/workflows/ci.yml` and `deploy.yml`.
4. Follow the same PR-gated branch protection pattern as `automation` (see its `AGENTS.md`) — `ci.yml` runs on `pull_request`, `deploy.yml` runs on `push` to `main` after merge.
5. Add the repo's own `AGENTS.md` (and stubs) following `automation`'s pattern, referencing this template.

## How it works

Same shape as the `automation` launchd pipeline, different target: `deploy.sh` rsyncs the CI checkout into the canonical clone at `/Users/frans/git/<repo-name>`, then runs `docker compose up -d --build` directly on the Mac via OrbStack. No registry, no separate pull step — the runner *is* the deploy target, same as it is for launchd repos.
