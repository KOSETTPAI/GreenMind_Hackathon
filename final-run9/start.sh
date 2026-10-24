#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="final-run9"
export GREENMIND_POWER_W="${GREENMIND_POWER_W:-275}"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
