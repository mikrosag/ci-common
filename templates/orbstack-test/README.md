# orbstack-test template

For a repo that prefers container-based dynamic testing over a Nix devShell — typically because it already ships as a container (see `templates/orbstack-deploy/`) and reusing the same Docker tooling is simpler than adding Nix.

## Setup

1. Copy `Dockerfile.test` and `.dockerignore` into `<repo>/`, adjust the base image and dependency install step for the actual stack. `Dockerfile.test` does `COPY . .` with no selective copy, so `.dockerignore` is what keeps `.git`, `__pycache__`, `.venv`, etc. out of the image — don't skip copying it.
2. Write `tests/` using `pytest` (or the test framework appropriate to the language).
3. If `requirements.txt` needs a compiler toolchain to build (e.g. packages with C extensions and no prebuilt wheel for the base image), don't add `build-essential`/`gcc` to this single-stage image directly — that bloats every test run permanently. Split into a builder stage that has the compiler and a final stage that only copies the installed packages, same pattern as `templates/orbstack-deploy/` uses for compiled runtime images.
4. In `ci.yml`, add:
   ```yaml
   jobs:
     dynamic-tests:
       uses: mikrosag/ci-common/.github/workflows/dynamic-tests-container.yml@main
   ```
5. Same testing philosophy as `templates/nix-test/`: unit-test logic with externals mocked, don't hit live services from CI.

## Nix vs container — which to pick

- **Nix** (`templates/nix-test/`): better for plain scripts/libraries with no existing Dockerfile, more hermetic dependency pinning (exact versions via flake.lock, not just a base image tag).
- **Container** (this template): better when the repo already has a Dockerfile for deployment (e.g. an `orbstack-deploy` repo) — reuse the same image-building muscle instead of introducing a second toolchain.
