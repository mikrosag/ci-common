# nix-test template

For a repo that wants reproducible, hermetic dynamic tests via a Nix devShell, instead of relying on whatever's installed on the runner's bare host.

## Setup

1. Copy `flake.nix` into the repo root, add the actual runtime dependencies the code under test needs (mirror whatever's `import`ed at module level — see `automation/flake.nix` for a worked example covering selenium/feedparser/requests/bs4).
2. Write `tests/` with `conftest.py` that adds the source dir to `sys.path` (see `automation/tests/conftest.py`), and `test_*.py` files using `pytest`.
3. **Must `git add` new files before `nix develop` will see them** — Nix flakes only read tracked/staged files in a git repo, not arbitrary untracked files in the working tree. This trips people up on a first run.
4. In `ci.yml`, add:
   ```yaml
   jobs:
     dynamic-tests:
       uses: mikrosag/ci-common/.github/workflows/dynamic-tests-nix.yml@main
   ```
5. Test locally first: `source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && nix develop -c python3 -m pytest tests/ -v` (the `source` line is only needed because the runner/Mac shell doesn't auto-load it in non-interactive shells — see `AGENTS.md` in this repo).

## What to test

Unit-test pure/parseable logic (parsing, formatting, filtering, threshold checks) with all network/disk/subprocess/browser calls mocked or simply not exercised — these are dynamic tests of real code paths, not integration tests against live services. See `automation/tests/` for worked examples.
