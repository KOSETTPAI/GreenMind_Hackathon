#!/usr/bin/env bash
# Shared helpers for experiments_thyme scripts. Sourced, not executed.
#
# Defaults mirror scripts/start-vllm.sh exactly, so a config that sets nothing
# reproduces the team's original serving flags. That script is never modified.

thyme_defaults() {
  CONTAINER_NAME="thyme-vllm"
  IMAGE="vllm/vllm-openai:nightly"
  MODEL_ID="CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp"
  SERVED_MODEL_NAME="mango1.5-awq-w4a16"
  # Original script binds to localhost; the grader must be able to reach the
  # endpoint, so set BIND_ADDR=0.0.0.0 (or the VM IP) when organizers confirm.
  BIND_ADDR="127.0.0.1"
  PORT="8000"
  GPU_MEMORY_UTILIZATION="0.85"
  MAX_MODEL_LEN="32768"
  # Flags this approach adds on top of the base flags. Bash array.
  EXTRA_ARGS=()
}

# load_config <file>: apply defaults, then the config file, then derive names.
load_config() {
  local config="$1"
  if [[ ! -f "$config" ]]; then
    echo "Config not found: $config" >&2
    exit 2
  fi
  thyme_defaults
  # shellcheck source=/dev/null
  source "$config"
  CONFIG_NAME="$(basename "$config")"
  CONFIG_NAME="${CONFIG_NAME%.conf}"
}

# Base serving flags, identical to scripts/start-vllm.sh.
build_serve_args() {
  SERVE_ARGS=(
    "$MODEL_ID"
    --host 0.0.0.0
    --port 8000
    --served-model-name "$SERVED_MODEL_NAME"
    --trust-remote-code
    --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION"
    --max-model-len "$MAX_MODEL_LEN"
    --enable-auto-tool-choice
    --tool-call-parser qwen3_coder
    --reasoning-parser qwen3
  )
  # Empty-array-safe expansion (bash < 4.4 treats "${a[@]}" as unbound).
  SERVE_ARGS+=(${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"})
}

# Fail if anything else is using the GPU: one serving process per run.
require_free_gpu() {
  if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "nvidia-smi not found: run this on the A100 VM." >&2
    exit 1
  fi
  local apps
  apps="$(nvidia-smi --query-compute-apps=pid,process_name --format=csv,noheader)"
  if [[ -n "$apps" ]]; then
    echo "GPU is busy; stop the other server first (e.g. docker stop mango-vllm):" >&2
    echo "$apps" >&2
    exit 1
  fi
}
