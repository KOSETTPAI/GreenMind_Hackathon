#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "${CONFIRM_CYCLE3:-}" == "1" ]] || { echo "[ERROR] Cycle 3 waits for final3. Re-run with CONFIRM_CYCLE3=1 only if the 8192 budget helped TTFT and TPOT still has room." >&2; exit 1; }
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="val9"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
