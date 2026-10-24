#!/usr/bin/env bash
# E2b. One new flag: --enable-chunked-prefill. No batched-token change.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/launch-from-baseline.sh
source "$HERE/../lib/launch-from-baseline.sh"

[[ "$#" -eq 0 ]] || die "E2b takes no arguments."
if [[ "${CONFIRM_CHUNKED:-}" != "log-says-off" ]]; then
  die "Run E2b only when the previous server log says chunked prefill is off. Re-run with CONFIRM_CHUNKED=log-says-off."
fi

EXPERIMENT_ID="E2b-chunked-prefill"
EXPERIMENT_DELTA="--enable-chunked-prefill (V0 does not set this flag)"
EXPERIMENT_NEXT="If the process exits with an unrecognized-argument error, or the log says chunked prefill stayed off, do not submit."
launch_from_baseline add-bool enable-chunked-prefill
