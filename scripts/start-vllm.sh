#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-mango-vllm}"
MODEL_ID="${MODEL_ID:-CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp}"
SERVED_MODEL_NAME="${SERVED_MODEL_NAME:-mango1.5-awq-w4a16}"
IMAGE="${VLLM_IMAGE:-vllm/vllm-openai:nightly}"
PORT="${PORT:-8000}"
GPU_MEMORY_UTILIZATION="${GPU_MEMORY_UTILIZATION:-0.85}"
MAX_MODEL_LEN="${MAX_MODEL_LEN:-32768}"

mkdir -p "$HOME/.cache/huggingface"

if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
  echo "Container '$CONTAINER_NAME' already exists."
  echo "Inspect it with: docker logs --tail 100 $CONTAINER_NAME"
  echo "Remove it deliberately before recreating it."
  exit 1
fi

docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  --gpus all \
  --ipc=host \
  -p "127.0.0.1:${PORT}:8000" \
  -v "$HOME/.cache/huggingface:/root/.cache/huggingface" \
  "$IMAGE" \
  "$MODEL_ID" \
  --host 0.0.0.0 \
  --port 8000 \
  --served-model-name "$SERVED_MODEL_NAME" \
  --trust-remote-code \
  --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION" \
  --max-model-len "$MAX_MODEL_LEN" \
  --enable-auto-tool-choice \
  --tool-call-parser qwen3_coder \
  --reasoning-parser qwen3

echo
echo "Container started. Follow initialization with:"
echo "docker logs -f $CONTAINER_NAME"
echo
echo "Local API endpoint: http://127.0.0.1:${PORT}/v1"
