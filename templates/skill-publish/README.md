# skill-publish template

For a repo of Claude Skills (`SKILL.md` + `scripts/` folders, packaged as
`.skill` zips) that wants the same validate → build → register pipeline as
`mikrosag/skills` — the reference implementation, copy from there rather
than starting blank.

## Layout the scripts assume

`mikrosag/skills` is a Claude Code plugin marketplace. Skills sit at
`plugins/<plugin>/skills/<skill>/SKILL.md`, with a `plugin.json` per plugin and
a `.claude-plugin/marketplace.json` catalog. Every script finds skills through
`scripts/skillpaths.py` (`discover()`, `resolve()`); copy it with the scripts
below. A repo that keeps skills flat at its root must change `SKILL_GLOB` in
that one file instead of editing each script. Skill names must be unique
repo-wide.

## Scripts to copy

- `mikrosag/skills/scripts/skillpaths.py` — the one place that knows the layout.
- `mikrosag/skills/scripts/lint_marketplace.py` — marketplace.json, each
  `plugin.json` and `plugins/` agree (names, versions, unique skill names).
  Drop it if the repo is not a marketplace.
- `mikrosag/skills/scripts/lint_skill.py` — frontmatter convention +
  Skill API hard-constraint checks (name/description length & charset).
- `mikrosag/skills/scripts/check_skill_size.py` — size budget ahead of the
  API's 30MB-uncompressed upload cap.
- `mikrosag/skills/scripts/build_all.sh` + `scripts/package_skill.sh` —
  packages every skill folder into `<name>.skill` (zipped so `<name>/SKILL.md`
  is at the archive root, whichever plugin the skill sits in).
- `mikrosag/skills/scripts/publish_skill_api.py` — registers/updates each
  skill in the Anthropic API's Skill Management store
  (`client.skills.create` / `client.skills.versions.create`), tracked by
  name in a committed `scripts/.skill_ids.json`.
- `mikrosag/skills/.github/workflows/ci.yml` and `deploy.yml` — wire the
  above together with `ci-common`'s `security-checks.yml` and
  `sca-scan.yml`. There is no CI notification (declined org-wide,
  2026-08-10). A brand-new skill gets a GitHub Release carrying its `.skill`
  (`scripts/new_skills_in_range.py`); that is the reminder that the API store
  is *not* Claude.ai/Cowork's personal Skills settings, so getting a skill
  into chat is still a manual upload.

## What to change per-repo

- `ANTHROPIC_API_KEY` repo secret — required for the publish step, soft-skips
  (not a failure) if unset.
- Plugin versions: Claude Code updates an installed plugin only when its
  `version` changes, so a PR that edits a skill bumps it in `plugin.json` and
  in the `marketplace.json` entry.
- Whether SCA even applies — if the repo's skills are genuinely stdlib-only
  with no pipeline-tooling dependency of their own, `requirements.txt` can
  be trimmed accordingly (see `mikrosag/skills/requirements.txt`'s comment
  for why it still keeps `anthropic`/`pyyaml` pinned).

## What this template deliberately does NOT cover

There's no supported API to push directly into Claude.ai/Cowork's personal
Skills settings (checked September 2026 — platform.claude.com's Skills API
docs describe it as workspace-scoped for API/`claude --print` use,
explicitly separate from that chat UI). If that changes, this template (and
`mikrosag/skills`) should get a real auto-upload step and this note should
go away.
