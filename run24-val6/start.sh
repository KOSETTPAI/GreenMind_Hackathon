#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "${CONFIRM_CYCLE2:-}" == "1" ]] || { echo "[ERROR] Cycle 2. Re-run with CONFIRM_CYCLE2=1 only if final1 p95 TPOT is under 50 ms and TTFT is the remaining miss." >&2; exit 1; }
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="val6"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
