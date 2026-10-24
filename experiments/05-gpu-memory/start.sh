#!/usr/bin/env bash
# E5. One change: raise --gpu-memory-utilization from the V0 value 0.85.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/launch-from-baseline.sh
source "$HERE/../lib/launch-from-baseline.sh"

[[ "$#" -eq 1 ]] || die "Usage: CONFIRM_TPOT=under-50ms $0 0.90|0.92|0.95. Start at 0.90."
if [[ "${CONFIRM_TPOT:-}" != "under-50ms" ]]; then
  die "Raise memory only after History shows p95 TPOT under 50 ms. Re-run with CONFIRM_TPOT=under-50ms."
fi

EXPERIMENT_ID="E5-gpu-memory-${1}"
EXPERIMENT_DELTA="--gpu-memory-utilization ${1} (V0 is 0.85)"
EXPERIMENT_NEXT="Start the sweep at 0.90. Clear HELD_GPU_MEMORY_UTILIZATION before trying 0.92 or 0.95. An out-of-memory startup is a revert, not a submission."
launch_from_baseline replace gpu-memory-utilization "$1"
