#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}")")"
PACKAGE_PATH=$(readlink -f "${SCRIPT_DIR}/../_package.nix")

FILE_URL="https://www.az-launcher.nz/goto/dl?arch=linux64"

VERSION=$(
  curl -sIL \
    --retry 3 \
    --retry-delay 2 \
    --retry-all-errors \
    "$FILE_URL" | \
    grep -i "^location:" | \
    tail -n 1 | \
    grep -oP 'AZ-Launcher_\K[0-9.]+(?=-linux64)'
)

echo "Fetching new hash for: $FILE_URL"
HASH_RAW=$(retry -t 3 -d 2 -- nix-prefetch-url --unpack "$FILE_URL")
NEW_HASH=$(nix hash convert --hash-algo sha256 --from nix32 $HASH_RAW)

URL="https://www.az-launcher.nz/goto/dl?arch=linux64"

echo "Detected Version: $VERSION"

echo "New hash is: $NEW_HASH"

sed -i -E "s|hash = \"[^\"]+\"|hash = \"${NEW_HASH}\"|" "$PACKAGE_PATH"
sed -i -E "s|version = \"[^\"]+\"|version = \"${VERSION}\"|" "$PACKAGE_PATH"

echo "Hash updated in $PACKAGE_PATH"

git add "$PACKAGE_PATH"
git commit -m "chore(az-launcher): update to v${VERSION}" \
  || true
