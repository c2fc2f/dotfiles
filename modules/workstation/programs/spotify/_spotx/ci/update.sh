#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
PACKAGE_PATH=$(readlink -f "${SCRIPT_DIR}/../default.nix")

OWNER="SpotX-Official"
REPO="SpotX-Bash"

FILE="spotx.sh"

BASE_URL="https://raw.githubusercontent.com/${OWNER}/${REPO}/refs/heads"
FILE_URL="${BASE_URL}/main/${FILE}"

echo "Fetching new hash for: $FILE_URL"
HASH_RAW=$(retry -t 3 -d 2 -- nix-prefetch-url "$FILE_URL")
NEW_HASH=$(nix hash convert --hash-algo sha256 --from nix32 $HASH_RAW)

echo "New hash is: $NEW_HASH"

sed -i -E "s|hash = \"[^\"]+\"|hash = \"${NEW_HASH}\"|" "$PACKAGE_PATH"

echo "Hash updated in $PACKAGE_PATH"

git add "$PACKAGE_PATH"
git commit -m "chore(workstation/spotify/spotx): update to lastest version" \
  || true
