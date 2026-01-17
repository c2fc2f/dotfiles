#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
PACKAGE_PATH=$(readlink -f "${SCRIPT_DIR}/../default.nix")

OWNER="neo4j-labs"
REPO="neosemantics"

VERSION=$(
  curl -sS \
    --retry 3 \
    --retry-delay 2 \
    --retry-all-errors \
    -H "Authorization: Bearer $PERSONAL_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
  | jq -r ".tag_name" \
  | sed 's/v//'
)

FILE="neosemantics-${VERSION}.jar"

BASE_URL="https://github.com/${OWNER}/${REPO}/releases/download"
FILE_URL="${BASE_URL}/${VERSION}/${FILE}"

echo "Fetching new hash for: $FILE_URL"
HASH_RAW=$(nix-prefetch-url "$FILE_URL")
NEW_HASH=$(nix hash convert --hash-algo sha256 --from nix32 $HASH_RAW)

echo "New hash is: $NEW_HASH"

sed -i -E "s|hash = \"[^\"]+\"|hash = \"${NEW_HASH}\"|" "$PACKAGE_PATH"
sed -i -E "s|version = \"[^\"]+\"|version = \"${VERSION}\"|" "$PACKAGE_PATH"

echo "Hash updated in $PACKAGE_PATH"

git add "$PACKAGE_PATH"
git commit -m "chore(neo4j/plugins/neosemantics): update to v${VERSION}" \
  || true
