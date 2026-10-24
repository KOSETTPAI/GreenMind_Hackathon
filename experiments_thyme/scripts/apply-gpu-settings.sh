#!/usr/bin/env bash
# Apply a config's GPU power cap and clock lock (approaches 2 and 11), or reset
# them to card defaults when the config leaves them empty. Needs sudo.
#
# Run BEFORE launch.sh, never while a Validation/Final run is in progress: the
# rules allow a fixed power limit or locked clocks only if held constant for the
# whole run. Settings reset on reboot or driver reload; launch.sh re-checks the
# power limit every time.
#
# Usage: experiments_thyme/scripts/apply-gpu-settings.sh experiments_thyme/configs/A02_power_200w.conf
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <config.conf>" >&2
  exit 2
fi
load_config "$1"

default_limit="$(nvidia-smi -i 0 --query-gpu=power.default_limit --format=csv,noheader,nounits)"
min_limit="$(nvidia-smi -i 0 --query-gpu=power.min_limit --format=csv,noheader,nounits)"
max_limit="$(nvidia-smi -i 0 --query-gpu=power.max_limit --format=csv,noheader,nounits)"

if [[ -n "$POWER_LIMIT_W" ]]; then
  if (( POWER_LIMIT_W < ${min_limit%.*} || POWER_LIMIT_W > ${max_limit%.*} )); then
    echo "POWER_LIMIT_W=$POWER_LIMIT_W is outside the card's range ${min_limit}–${max_limit} W." >&2
    exit 1
  fi
  sudo nvidia-smi -i 0 -pl "$POWER_LIMIT_W"
else
  sudo nvidia-smi -i 0 -pl "${default_limit%.*}"
fi

if [[ -n "$GPU_CLOCK_MHZ" ]]; then
  if ! nvidia-smi -i 0 --query-supported-clocks=gr --format=csv,noheader,nounits \
      | tr -d ' ' | grep -qx "$GPU_CLOCK_MHZ"; then
    echo "GPU_CLOCK_MHZ=$GPU_CLOCK_MHZ is not a supported graphics clock. Supported:" >&2
    nvidia-smi -i 0 --query-supported-clocks=gr --format=csv,noheader,nounits | sort -un | tr '\n' ' ' >&2
    echo >&2
    exit 1
  fi
  sudo nvidia-smi -i 0 -lgc "$GPU_CLOCK_MHZ,$GPU_CLOCK_MHZ"
else
  sudo nvidia-smi -i 0 -rgc
fi

echo "Applied for $CONFIG_NAME: power limit ${POWER_LIMIT_W:-default (${default_limit} W)}, clock ${GPU_CLOCK_MHZ:-unlocked}"
nvidia-smi -i 0 --query-gpu=power.limit,power.default_limit,clocks.sm,clocks.max.sm --format=csv
