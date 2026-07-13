# mcp-server-registry template

For any repo whose CI needs to onboard a new MCP server onto `mcp-gateway` through the fail-closed security gate.

## Setup

1. In the calling repo's `ci.yml`, add a job triggered when a change touches the server's directory or its registry manifest:
   ```yaml
   on:
     pull_request:
       paths:
         - "mcp-servers/**"
         - "registry/*.yaml"

   jobs:
     mcp-security-gate:
       uses: mikrosag/ci-common/.github/workflows/mcp-server-security-gate.yml@main
       with:
         server-path: mcp-servers/<name>
         dockerfile: mcp-servers/<name>/Dockerfile
         compose-file: mcp-servers/<name>/docker-compose.yml
         manifest-path: registry/<name>.yaml
         server-name: <name>
   ```
2. Copy `manifest.example.yaml` (in this template directory) to `homelab/mcp-gateway/registry/<name>.yaml` and fill it in — see that directory's `README.md` for the full schema and what `gateway-sync` does with it.
3. Only after all six gate stages pass (see the workflow's header comment) should `deploy.yml` write/update the manifest and let a later `gateway-sync` run pick it up. This gate does not write anything itself — it only checks.

## What the gate assumes about your server

- It builds as a Docker image (`docker build -f <dockerfile> .` from the calling repo's root) — even a `stdio`-transport server needs a Dockerfile for the container/SBOM/signing stages, though it may never actually run as a container in production if it's deployed natively (see `mcp-system-diag`/`mcp-spotlight-facts` for the native pattern — those still get a Dockerfile purely so this gate has something to scan).
- If it has a `docker-compose.yml`, the gate resolves it with `docker compose config` and checks it against `ci-common/policy/mcp-server-compose.rego` (no literal secrets, non-root, resource limits, read-only rootfs). Pass `compose-file: ""` to skip this for a server with no compose file yet.
- Its registry manifest exists at the path you pass as `manifest-path` before the gate runs — the gate reads it (via `conftest`) but never creates or edits it.
