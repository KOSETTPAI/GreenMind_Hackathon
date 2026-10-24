#!/usr/bin/env bash
# Read the GPU power limit and clocks. Does not change them.
set -euo pipefail

if [[ -f /.dockerenv ]]; then
  echo "Run this on the VM host, outside the vLLM container." >&2
  exit 1
fi

nvidia-smi -q -d POWER,CLOCK
