#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "${CONFIRM_R18:-}" == "1" ]] || { echo "[ERROR] run18 combines two changes. Launch it after run16 has a Final or replay result. Re-run with CONFIRM_R18=1." >&2; exit 1; }
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="r18-cap64-lpt2048"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
