#!/usr/bin/env bash
# Launch this run. Shared implementation: ../lib/start.sh. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GREENMIND_RUN="$(basename "$HERE")"
export GREENMIND_TIER="r16-cap64"
export GREENMIND_PROFILE="$HERE/profile.args"
exec "$HERE/../lib/start.sh" "$@"
