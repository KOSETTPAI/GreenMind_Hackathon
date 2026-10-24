#!/usr/bin/env bash
# E1. One change from scripts/start-vllm.sh: --max-model-len 40960.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/launch-from-baseline.sh
source "$HERE/../lib/launch-from-baseline.sh"

[[ "$#" -eq 0 ]] || die "E1 takes no arguments. The context length is 40960."

EXPERIMENT_ID="E1-max-model-len"
EXPERIMENT_DELTA="--max-model-len 40960 (V0 is 32768)"
EXPERIMENT_NEXT="Before Submit: bash scripts/test-chat.sh && bash scripts/test-stream.sh && bash scripts/test-tool-calling.sh && bash experiments/10-warmup/warmup.sh"
assert_isolated_from_v0
launch_from_baseline replace max-model-len 40960
