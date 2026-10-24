#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "${CONFIRM_R19:-}" == "1" ]] || { echo "[ERROR] run19 adds MTP, which cut prefix-cache hits to about 1% on run4 full. Launch it only after run16 is measured, and check the hit rate. Re-run with CONFIRM_R19=1." >&2; exit 1; }
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="r19-cap64-mtp1"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
