#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "${CONFIRM_FINAL3:-}" == "1" ]] || { echo "[ERROR] final3 waits until the cycle-2 Validations are recorded. Re-run with CONFIRM_FINAL3=1. Copy the winning profile here first if it is not cap 64." >&2; exit 1; }
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="final3"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
