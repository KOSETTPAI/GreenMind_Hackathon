#!/usr/bin/env bash
# Power cap for the kept server. Does not relaunch vLLM. See README.md.
set -Eeuo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$HERE/../lib/power.sh" "$@"
