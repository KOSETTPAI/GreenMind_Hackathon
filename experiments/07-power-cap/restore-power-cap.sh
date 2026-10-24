#!/usr/bin/env bash
# Restore the power limit recorded before a cap. Run between graded windows, not during one.
set -euo pipefail

die() {
  echo "$*" >&2
  exit 1
}

WATTS="${1:-}"
[[ "$WATTS" =~ ^[0-9]+$ ]] || die "Usage: CONFIRM=1 $0 RECORDED_WATTS"
if (( WATTS < 300 || WATTS > 450 )); then
  die "Pass the limit recorded before the cap. This script accepts 300 through 450 W. The sweep values 175, 200, and 250 stay on set-power-cap.sh."
fi
if [[ -f /.dockerenv ]]; then
  die "Run this on the VM host, outside the vLLM container."
fi

nvidia-smi -q -d POWER
mapfile -t limits < <(nvidia-smi --query-gpu=power.limit --format=csv,noheader,nounits)
[[ "${#limits[@]}" -eq 1 ]] || die "Expected exactly one GPU. Refusing to restore a cap."
if [[ "${CONFIRM:-}" != "1" ]]; then
  echo "Not applied. Re-run with CONFIRM=1 to restore ${WATTS} W between runs."
  exit 2
fi

sudo nvidia-smi -pl "$WATTS"
nvidia-smi -q -d POWER
echo "Restored ${WATTS} W. Persistence mode was left on."
