#!/usr/bin/env bash

set -euo pipefail

# Get the absolute path to the directory of this script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PACKAGE_PATH=$(readlink -f "$SCRIPT_DIR/../default.nix")

REPO_URL="https://github.com/jeffvli/feishin/"
VERSION=$(nix run nixpkgs\#curl -- -s "https://api.github.com/repos/jeffvli/feishin/releases" | nix run nixpkgs\#jq -- -r ".[0].tag_name" | sed 's/v//')

FILE_URL="${REPO_URL}archive/refs/tags/v${VERSION}.tar.gz"

echo $FILE_URL

echo "Fetching new hash for: $FILE_URL"
HASH_RAW=$(nix-prefetch-url --unpack "$FILE_URL")
NEW_HASH=$(nix hash convert sha256:$HASH_RAW)

echo "New hash is: $NEW_HASH"

sed -i -E "s|sha256 = \"[^\"]+\"|sha256 = \"${NEW_HASH}\"|" "$PACKAGE_PATH"
sed -i -E "s|version = \"[^\"]+\"|version = \"${VERSION}\"|" "$PACKAGE_PATH"

echo "Hash updated in $PACKAGE_PATH"

git add "$PACKAGE_PATH"
git commit -m "chore(feishin): update to lastest version" || true
