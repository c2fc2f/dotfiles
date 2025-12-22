#!/usr/bin/env bash

set -euo pipefail

# Get the absolute path to the directory of this script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PACKAGE_PATH=$(readlink -f "${SCRIPT_DIR}/../default.nix")

REPO_OWNER="SpotX-Official"
REPO_NAME="SpotX-Bash"

FILE_NAME="spotx.sh"

FILE_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/refs/heads/main/${FILE_NAME}"

echo "Fetching new hash for: $FILE_URL"
HASH_RAW=$(nix-prefetch-url "$FILE_URL")
NEW_HASH=$(nix hash convert sha256:$HASH_RAW)

echo "New hash is: $NEW_HASH"

sed -i -E "s|sha256 = \"[^\"]+\"|sha256 = \"${NEW_HASH}\"|" "$PACKAGE_PATH"

echo "Hash updated in $PACKAGE_PATH"

git add "$PACKAGE_PATH"
git commit -m "chore(workstation/spotify/spotx): update to lastest version" || true
