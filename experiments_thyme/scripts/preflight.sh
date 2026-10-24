#!/usr/bin/env bash
# Check a config against the installed vLLM image before spending a run on it.
# Starts a throwaway container WITHOUT GPU access, so it is safe while another
# server is running. Checks:
#   1. every --flag in EXTRA_ARGS exists in `vllm serve --help=all`
#   2. the GPU is free and the port is not taken (warnings only)
#   3. MAX_MODEL_LEN covers a 32K prompt + 8192 output tokens (warning only)
#
# Usage: experiments_thyme/scripts/preflight.sh experiments_thyme/configs/A00_stack.conf
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <config.conf>" >&2
  exit 2
fi
load_config "$1"

fail=0
echo "== Config: $CONFIG_NAME (image $IMAGE)"

echo "== vLLM version"
docker run --rm --entrypoint python3 "$IMAGE" -c 'import vllm; print(vllm.__version__)'

echo "== Flag check"
help_text="$(docker run --rm --entrypoint vllm "$IMAGE" serve --help=all 2>/dev/null \
  || docker run --rm --entrypoint vllm "$IMAGE" serve --help)"
for arg in ${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}; do
  [[ "$arg" == --* ]] || continue
  flag="${arg%%=*}"
  if grep -qE -- "${flag}([^a-z0-9-]|\$)" <<<"$help_text"; then
    echo "ok       $flag"
    # Show the help entry so a flag that is already on by default is obvious.
    # `|| true`: head closing the pipe early must not trip set -e/pipefail.
    grep -A4 -E -- "${flag}([^a-z0-9-]|\$)" <<<"$help_text" | sed 's/^/           /' | head -6 || true
  else
    echo "MISSING  $flag  (not in this vLLM version; drop this config)"
    fail=1
  fi
done

echo "== GPU and port"
if command -v nvidia-smi >/dev/null 2>&1; then
  apps="$(nvidia-smi --query-compute-apps=pid,process_name --format=csv,noheader)"
  if [[ -n "$apps" ]]; then
    echo "warn     GPU busy (stop it before launch.sh):"
    echo "$apps" | sed 's/^/           /'
  else
    echo "ok       GPU free"
  fi
  nvidia-smi --query-gpu=power.limit,clocks.applications.graphics --format=csv,noheader \
    | sed 's/^/info     power limit, app clock: /'
  echo "info     config wants power ${POWER_LIMIT_W:-default}, clock ${GPU_CLOCK_MHZ:-unlocked} (apply-gpu-settings.sh sets both)"
else
  echo "warn     nvidia-smi not found (not on the VM?)"
fi
if command -v ss >/dev/null 2>&1 && ss -ltn | grep -qE "[:.]${PORT}[[:space:]]"; then
  echo "warn     port $PORT already in use"
fi

echo "== Context length"
if (( MAX_MODEL_LEN < 40960 )); then
  echo "warn     MAX_MODEL_LEN=$MAX_MODEL_LEN < 40960: a ~32K prompt plus max_tokens 8192 may be rejected."
  echo "         Kept equal to scripts/start-vllm.sh so the comparison stays fair; see README."
fi

if (( fail )); then
  echo "Preflight FAILED"
  exit 1
fi
echo "Preflight passed"
