#!/usr/bin/env bash
# Set one constant power cap for a whole graded run. Does not change clocks during the run.
set -euo pipefail

die() {
  echo "$*" >&2
  exit 1
}

WATTS="${1:-}"
case "$WATTS" in
  250|200|175) ;;
  150)
    die "150 W is outside the current run order. The sweep is 250, then 200, then 175."
    ;;
  *)
    die "Usage: CONFIRM_SLO=at-least-90 CONFIRM=1 $0 250|200|175"
    ;;
esac

if [[ -f /.dockerenv ]]; then
  die "Run this on the VM host, outside the vLLM container."
fi
if [[ "${CONFIRM_SLO:-}" != "at-least-90" ]]; then
  die "A power cap waits until the current server config has SLO-met of at least 90/100. V0 is 56/100. Re-run with CONFIRM_SLO=at-least-90 only after that result is in experiments/log.md."
fi

echo "Power limit before this command:"
nvidia-smi -q -d POWER
mapfile -t limits < <(nvidia-smi --query-gpu=power.limit --format=csv,noheader,nounits)
[[ "${#limits[@]}" -eq 1 ]] || die "Expected exactly one GPU. Refusing to set a cap."
current="${limits[0]//$'\r'/}"
current="${current// /}"
current="${current%%.*}"
[[ "$current" =~ ^[0-9]+$ ]] || die "Could not parse the current power limit: ${limits[0]}"
echo "RECORDED_PREVIOUS_LIMIT_W=${current}"
echo "Write that number in experiments/log.md before changing anything."

if [[ "$current" == "$WATTS" ]]; then
  echo "Power limit is already ${WATTS} W. Leave it unchanged until the grader finishes."
  exit 0
fi
if [[ "${CONFIRM:-}" != "1" ]]; then
  echo "Not applied. The server flags stay as they are. Re-run with CONFIRM=1 to set a constant ${WATTS} W cap."
  exit 2
fi

sudo nvidia-smi -pm 1
sudo nvidia-smi -pl "$WATTS"
echo "Power limit after this command:"
nvidia-smi -q -d POWER
echo "Leave ${WATTS} W in place until this graded run finishes. Do not change it during the window."
