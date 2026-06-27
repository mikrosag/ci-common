#!/bin/bash
# Template deploy script for repos that ship as launchd jobs on this Mac.
# Copy into <repo>/deploy/install_launchd.sh and set DEPLOY_DIR.
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="/Users/frans/git/<repo-name>"   # <-- set per repo
LAUNCH_AGENTS="/Users/frans/Library/LaunchAgents"
UID_NUM="$(id -u)"

mkdir -p "$DEPLOY_DIR/scripts" "$DEPLOY_DIR/launchd"
rsync -a --delete "$SOURCE_DIR/scripts/" "$DEPLOY_DIR/scripts/"
rsync -a --delete "$SOURCE_DIR/launchd/" "$DEPLOY_DIR/launchd/"

for plist in "$DEPLOY_DIR"/launchd/*.plist; do
  name="$(basename "$plist")"
  label="$(basename "$plist" .plist)"
  target="$LAUNCH_AGENTS/$name"

  cp "$plist" "$target"

  launchctl bootout "gui/$UID_NUM/$label" 2>/dev/null || true
  launchctl bootstrap "gui/$UID_NUM" "$target"
  launchctl enable "gui/$UID_NUM/$label"

  echo "Deployed $label"
done
