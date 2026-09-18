#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname -- "${SCRIPT_PATH}")

FLAKE_URL=$(readlink -f "${SCRIPT_DIR}/../../")

echo "Running flake update"
retry -t 3 -d 2 -- nix flake update --flake "${FLAKE_URL}"
echo "Flake update completed"

git add "${FLAKE_URL}/flake.lock"
git commit -m "chore(flake.lock): update dependencies" ||
  true
