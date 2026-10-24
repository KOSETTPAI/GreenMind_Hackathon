#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "${CONFIRM_CYCLE2:-}" == "1" ]] || { echo "[ERROR] Cycle 2 waits for the final1 History row. Re-run with CONFIRM_CYCLE2=1 only if final1 p95 TPOT is still above 50 ms." >&2; exit 1; }
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="val4"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
