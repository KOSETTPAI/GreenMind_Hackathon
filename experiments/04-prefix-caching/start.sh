#!/usr/bin/env bash
# E4. One change: hybrid prefix caching. The documented unit is both flags.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/launch-from-baseline.sh
source "$HERE/../lib/launch-from-baseline.sh"

[[ "$#" -eq 0 ]] || die "E4 takes no arguments."

EXPERIMENT_ID="E4-prefix-caching"
EXPERIMENT_DELTA="--enable-prefix-caching --mamba-cache-mode align"
EXPERIMENT_NEXT="Do not submit unless the startup log says prefix caching is enabled and bash experiments/04-prefix-caching/check-hits.sh exits 0."
launch_from_baseline prefix-caching
