#!/bin/bash
# Template deploy script for repos that ship as an OrbStack container.
# Copy into <repo>/deploy/deploy.sh and adjust DEPLOY_DIR + compose file name.
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="/Users/frans/git/<repo-name>"   # <-- set per repo

mkdir -p "$DEPLOY_DIR"
rsync -a --delete --exclude '.git' "$SOURCE_DIR/" "$DEPLOY_DIR/"

cd "$DEPLOY_DIR"
docker compose up -d --build
docker compose ps
