#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "${CONFIRM_SHARED_PREFIX:-}" == "1" ]] || { echo "[ERROR] This flag waits until prefix caching beat cache-off while the hit rate stayed low, and until flag-check passes. Re-run with CONFIRM_SHARED_PREFIX=1." >&2; exit 1; }
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="shared-prefix"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
