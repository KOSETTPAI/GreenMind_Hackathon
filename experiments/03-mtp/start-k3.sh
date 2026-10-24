#!/usr/bin/env bash
# E3c. MTP with three draft tokens. Separate from k=1 and k=2.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/launch-from-baseline.sh
source "$HERE/../lib/launch-from-baseline.sh"

[[ "$#" -eq 0 ]] || die "E3 k=3 takes no arguments."
if [[ "${CONFIRM_K:-}" != "3" ]]; then
  die "k=3 waits until a smaller k raises S and tool calls still parse. Re-run with CONFIRM_K=3 after that row is in experiments/log.md."
fi

EXPERIMENT_ID="E3-mtp-k3"
EXPERIMENT_DELTA="--speculative-config method=mtp num_speculative_tokens=3"
EXPERIMENT_NEXT="Clear HELD_SPECULATIVE_TOKENS before this launch if a smaller k is still listed in experiments/adopted.env."
launch_from_baseline add speculative-config '{"method":"mtp","num_speculative_tokens":3}'
