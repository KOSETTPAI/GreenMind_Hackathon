#!/usr/bin/env bash
# E3b. MTP with two draft tokens. Separate from k=1.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/launch-from-baseline.sh
source "$HERE/../lib/launch-from-baseline.sh"

[[ "$#" -eq 0 ]] || die "E3 k=2 takes no arguments."
if [[ "${CONFIRM_K:-}" != "2" ]]; then
  die "k=2 waits until k=1 raises S and tool calls still parse. Re-run with CONFIRM_K=2 after that row is in experiments/log.md."
fi

EXPERIMENT_ID="E3-mtp-k2"
EXPERIMENT_DELTA="--speculative-config method=mtp num_speculative_tokens=2"
EXPERIMENT_NEXT="Clear HELD_SPECULATIVE_TOKENS before this launch if k=1 is still listed in experiments/adopted.env. This run replaces k; it does not stack two MTP settings."
launch_from_baseline add speculative-config '{"method":"mtp","num_speculative_tokens":2}'
