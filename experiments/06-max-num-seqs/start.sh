#!/usr/bin/env bash
# E6. One new flag: --max-num-seqs. V0 leaves this at the vLLM default.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/launch-from-baseline.sh
source "$HERE/../lib/launch-from-baseline.sh"

[[ "$#" -eq 1 ]] || die "Usage: CONFIRM_TPOT=under-50ms $0 64|128|192|256"
if [[ "${CONFIRM_TPOT:-}" != "under-50ms" ]]; then
  die "Change max-num-seqs only after History shows p95 TPOT under 50 ms. Re-run with CONFIRM_TPOT=under-50ms."
fi

EXPERIMENT_ID="E6-max-num-seqs-${1}"
EXPERIMENT_DELTA="--max-num-seqs ${1} (V0 does not set this flag)"
EXPERIMENT_NEXT="Record the V0 startup log's default concurrency before the first value. Skip a value that matches that default. Clear HELD_MAX_NUM_SEQS before the next value."
launch_from_baseline add max-num-seqs "$1"
