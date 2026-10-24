#!/usr/bin/env bash
# E2. One new flag: --max-num-batched-tokens. First value to submit is 4096.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/launch-from-baseline.sh
source "$HERE/../lib/launch-from-baseline.sh"

[[ "$#" -eq 1 ]] || die "Usage: $0 2048|4096|8192. The run-order value is 4096. Submit one value, then read History."

EXPERIMENT_ID="E2-batched-tokens-${1}"
EXPERIMENT_DELTA="--max-num-batched-tokens ${1} (V0 does not set this flag)"
EXPERIMENT_NEXT="Read the startup log for the batched-token budget and whether chunked prefill is already on. Then run the chat, stream, tool, and warmup checks."
launch_from_baseline add max-num-batched-tokens "$1"
