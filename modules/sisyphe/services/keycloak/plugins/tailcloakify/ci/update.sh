#!/usr/bin/env bash

set -euo pipefail

# Get the absolute path to the directory of this script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PACKAGE_PATH=$(readlink -f "${SCRIPT_DIR}/../default.nix")

REPO_OWNER="ALMiG-Kompressoren-GmbH"
REPO_NAME="tailcloakify"

VERSION=$(curl -s "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" | jq -r ".tag_name" | sed s/v//)

FILE_NAME="keycloak-theme-for-kc-22-to-25.jar"

FILE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/v${VERSION}/${FILE_NAME}"

echo "Fetching new hash for: $FILE_URL"
HASH_RAW=$(nix-prefetch-url "$FILE_URL")
NEW_HASH=$(nix hash convert sha256:$HASH_RAW)

echo "New hash is: $NEW_HASH"

sed -i -E "s|sha256 = \"[^\"]+\"|sha256 = \"${NEW_HASH}\"|" "$PACKAGE_PATH"
sed -i -E "s|version = \"[^\"]+\"|version = \"${VERSION}\"|" "$PACKAGE_PATH"

echo "Hash updated in $PACKAGE_PATH"

git add "$PACKAGE_PATH"
git commit -m "chore(keycloak/plugin/tailcloakify): update to v${VERSION}" || true
