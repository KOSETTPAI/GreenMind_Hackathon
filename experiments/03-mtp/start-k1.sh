#!/usr/bin/env bash
# E3. One new flag: MTP speculative decoding with one draft token.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/launch-from-baseline.sh
source "$HERE/../lib/launch-from-baseline.sh"

[[ "$#" -eq 0 ]] || die "E3 k=1 takes no arguments."

EXPERIMENT_ID="E3-mtp-k1"
EXPERIMENT_DELTA="--speculative-config method=mtp num_speculative_tokens=1"
EXPERIMENT_NEXT="Do not submit until tool calls and thinking-on streaming both succeed. Record the acceptance metric from http://127.0.0.1:8000/metrics."
launch_from_baseline add speculative-config '{"method":"mtp","num_speculative_tokens":1}'
