#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"

FLAKE_URL=$(readlink -f "$SCRIPT_DIR/../../")

echo "Running flake update"
retry -t 3 -d 2 -- nix flake update --flake "$FLAKE_URL"
echo "Flake update completed"

git add "$FLAKE_URL/flake.lock"
git commit -m "chore(flake.lock): update dependencies" \
  || true
