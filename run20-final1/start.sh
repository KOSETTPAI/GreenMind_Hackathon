#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "${CONFIRM_FINAL1:-}" == "1" ]] || { echo "[ERROR] final1 waits until val1, val2 and val3 are recorded and the replay has picked a winner. Re-run with CONFIRM_FINAL1=1. If the winner was not val1, copy its profile.args here first." >&2; exit 1; }
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="final1"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
