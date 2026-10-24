#!/usr/bin/env bash
# Start one experiments_thyme config in its own container (default: thyme-vllm)
# and save a run record (config, exact command, image digest, vLLM version, GPU
# power settings) under experiments_thyme/results/runs/.
#
# Usage: experiments_thyme/scripts/launch.sh experiments_thyme/configs/A00_stack.conf
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THYME_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <config.conf>" >&2
  exit 2
fi
load_config "$1"
build_serve_args

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "Container '$CONTAINER_NAME' already exists. Stop it with:" >&2
  echo "  $SCRIPT_DIR/stop.sh" >&2
  exit 1
fi
require_free_gpu
require_power_limit

mkdir -p "$HOME/.cache/huggingface"

DOCKER_CMD=(
  docker run -d
  --name "$CONTAINER_NAME"
  --label greenmind.experiment=thyme
  --label "greenmind.config=$CONFIG_NAME"
  --gpus all
  --ipc=host
  -p "${BIND_ADDR}:${PORT}:8000"
  -v "$HOME/.cache/huggingface:/root/.cache/huggingface"
  "$IMAGE"
  "${SERVE_ARGS[@]}"
)

RUN_DIR="$THYME_DIR/results/runs/$(date -u +%Y%m%dT%H%M%SZ)_${CONFIG_NAME}"
mkdir -p "$RUN_DIR"
cp "$1" "$RUN_DIR/config.conf"
# A-series configs build on a shared stack; keep the stack state of this run too.
if [[ -f "$(dirname "$1")/_stack.conf" ]]; then
  cp "$(dirname "$1")/_stack.conf" "$RUN_DIR/_stack.conf"
fi
printf '%q ' "${DOCKER_CMD[@]}" > "$RUN_DIR/command.txt"
echo >> "$RUN_DIR/command.txt"

"${DOCKER_CMD[@]}"

{
  echo "config: $CONFIG_NAME"
  echo "requested_power_limit_w: ${POWER_LIMIT_W:-default}"
  echo "requested_gpu_clock_mhz: ${GPU_CLOCK_MHZ:-unlocked}"
  echo "started_utc: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "image: $IMAGE"
  echo "image_digests: $(docker image inspect --format '{{json .RepoDigests}}' "$IMAGE" 2>/dev/null || echo unknown)"
  echo "vllm_version: $(docker exec "$CONTAINER_NAME" python3 -c 'import vllm; print(vllm.__version__)' 2>/dev/null || echo unknown)"
  echo "gpu:"
  nvidia-smi --query-gpu=name,driver_version,persistence_mode,power.limit,clocks.applications.graphics --format=csv
} > "$RUN_DIR/environment.txt"

echo
echo "Started $CONTAINER_NAME with config $CONFIG_NAME"
echo "Run record: $RUN_DIR"
echo "Follow startup:  docker logs -f $CONTAINER_NAME"
echo "Save the startup log once ready (it shows CUDA graph capture, cache size, prefix caching status):"
echo "  docker logs $CONTAINER_NAME > $RUN_DIR/startup.log 2>&1"
echo "Endpoint: http://${BIND_ADDR}:${PORT}/v1"
