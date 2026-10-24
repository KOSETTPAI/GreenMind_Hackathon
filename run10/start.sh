#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "${CONFIRM_V6:-}" == "1" ]] || { echo "[ERROR] V6 waits until 8192 improved TTFT and p95 TPOT still has room under 50 ms. Re-run with CONFIRM_V6=1 after that row is in run8/log.md." >&2; exit 1; }
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="v6-budget-16384"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
