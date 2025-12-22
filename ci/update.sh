#!/usr/bin/env bash

set -euo pipefail

# Get the directory of this script, even if called from elsewhere
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

UPDATES_DIR="$SCRIPT_DIR/updates"
MODULES_DIR="$(readlink -f "$SCRIPT_DIR/../modules")"

execute_script() {
  local script="$1"
  
  if [ ! -x "$script" ]; then
    chmod +x "$script"
  fi
  
  echo "➡️  Executing: $script"
  "$script" 2>&1 | sed 's/^/  /'
}

total_executed=0

echo "[🔁] Running update scripts"
echo ""

echo "📁 Processing scripts in $UPDATES_DIR"
for script in "$UPDATES_DIR"/*.sh; do
  [ -e "$script" ] || continue
  
  execute_script "$script"
  ((total_executed++)) || true
done
echo ""

echo "📁 Processing ci/run.sh scripts in $MODULES_DIR"

while IFS= read -r -d '' script; do
  execute_script "$script"
  ((total_executed++))
done < <(find "$MODULES_DIR" -type f -path "*/ci/update.sh" -print0 2>/dev/null)

echo ""
echo "[✅] All scripts completed successfully."
echo "📊 Summary: $total_executed executed"

git add -A
git commit -m "chore: auto-update scripts output" || true
