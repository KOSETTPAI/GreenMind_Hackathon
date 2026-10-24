#!/usr/bin/env bash
# GPU power limit. Host-side; one constant value for a whole graded run.
# Manual use. The cycle runs set power through GREENMIND_POWER_W in their start.sh.
#
#   ./lib/power.sh show
#   CONFIRM_SLO=at-least-90 ./lib/power.sh set 250     # then 200, then 175
#   ./lib/power.sh restore                             # card default, between runs
#
# Set the cap before Submit and leave it until the grader finishes. Changing it
# during a window is the dynamic case the rules forbid. Clocks are never locked here.
set -Eeuo pipefail

die() {
  echo "[ERROR] $*" >&2
  exit 1
}

[[ -f /.dockerenv ]] && die "Run this on the VM host, outside the vLLM container."
command -v nvidia-smi >/dev/null 2>&1 || die "nvidia-smi not found."
count="$(nvidia-smi --query-gpu=index --format=csv,noheader | grep -c .)"
[[ "$count" == "1" ]] && : || die "Expected exactly one GPU, found $count."

query() { nvidia-smi -i 0 --query-gpu="$1" --format=csv,noheader,nounits | tr -d ' \r' | cut -d. -f1; }

show() {
  echo "power.limit:         $(query power.limit) W"
  echo "power.default_limit: $(query power.default_limit) W"
  echo "power.min/max_limit: $(query power.min_limit)-$(query power.max_limit) W"
  echo "power.draw:          $(nvidia-smi -i 0 --query-gpu=power.draw --format=csv,noheader)"
  echo "persistence_mode:    $(nvidia-smi -i 0 --query-gpu=persistence_mode --format=csv,noheader)"
}

case "${1:-}" in
  show)
    show
    ;;
  set)
    watts="${2:-}"
    case "$watts" in
      250|200|175) ;;
      *) die "Usage: CONFIRM_SLO=at-least-90 $0 set 250|200|175" ;;
    esac
    [[ "${CONFIRM_SLO:-}" == "at-least-90" ]] \
      || die "A cap waits until the kept configuration has SLO-met of at least 90/100. Re-run with CONFIRM_SLO=at-least-90 after that row is in its log."
    (( watts >= $(query power.min_limit) )) || die "$watts W is below this card's minimum."
    echo "Before:"
    show
    sudo nvidia-smi -i 0 -pm 1 >/dev/null
    sudo nvidia-smi -i 0 -pl "$watts"
    echo "After:"
    show
    echo "Keep ${watts} W until the grader finishes. Record it in the run's log.md."
    ;;
  restore)
    default="$(query power.default_limit)"
    sudo nvidia-smi -i 0 -pl "$default"
    show
    echo "Restored the card default (${default} W). Persistence mode was left as is."
    ;;
  *)
    die "Usage: $0 show | set 250|200|175 | restore"
    ;;
esac
