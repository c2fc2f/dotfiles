#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname -- "${SCRIPT_PATH}")

FLAKE_URL=$(readlink -f "${SCRIPT_DIR}/../")

LOG_FILE=$(mktemp)

nix flake check "${FLAKE_URL}" --print-build-logs |& tee "${LOG_FILE}"
NIX_STATUS=$?

if [[ ${NIX_STATUS} -ne 0 ]]; then
  rm -f "${LOG_FILE}"
  exit "${NIX_STATUS}"
fi

if { grep -i "warning:" "${LOG_FILE}" || true; } |
  grep -vqi "The check omitted these incompatible systems"; then
  echo -e "\n[!] Evaluation warnings detected. Forcing exit status 1." >&2
  rm -f "${LOG_FILE}"
  exit 1
fi

rm -f "${LOG_FILE}"
