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
  # Set any of these three to "" to leave the flag out (vLLM default).
  GPU_MEMORY_UTILIZATION="0.85"
  MAX_MODEL_LEN="32768"
  REASONING_PARSER="qwen3"
  # GPU settings, applied by apply-gpu-settings.sh before launch, never during
  # a run. Empty = card default power limit / clocks not locked.
  POWER_LIMIT_W=""
  GPU_CLOCK_MHZ=""
  # Flags a config adds on top of the base flags. Bash array.
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

# Base serving flags; with the defaults, identical to scripts/start-vllm.sh.
build_serve_args() {
  SERVE_ARGS=(
    "$MODEL_ID"
    --host 0.0.0.0
    --port 8000
    --served-model-name "$SERVED_MODEL_NAME"
    --trust-remote-code
  )
  [[ -z "$GPU_MEMORY_UTILIZATION" ]] || SERVE_ARGS+=(--gpu-memory-utilization "$GPU_MEMORY_UTILIZATION")
  [[ -z "$MAX_MODEL_LEN" ]] || SERVE_ARGS+=(--max-model-len "$MAX_MODEL_LEN")
  # Tool calling is required by the grader in every config.
  SERVE_ARGS+=(--enable-auto-tool-choice --tool-call-parser qwen3_coder)
  [[ -z "$REASONING_PARSER" ]] || SERVE_ARGS+=(--reasoning-parser "$REASONING_PARSER")
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

# Fail if the GPU power limit is not what the config asks for, so a cap left
# over from an earlier run can't silently change a measurement. (Locked clocks
# can't be read back reliably; apply-gpu-settings.sh always sets or resets them.)
require_power_limit() {
  local current default want
  current="$(nvidia-smi -i 0 --query-gpu=power.limit --format=csv,noheader,nounits)"
  default="$(nvidia-smi -i 0 --query-gpu=power.default_limit --format=csv,noheader,nounits)"
  want="${POWER_LIMIT_W:-${default%.*}}"
  if [[ "${current%.*}" != "$want" ]]; then
    echo "GPU power limit is ${current} W but $CONFIG_NAME wants ${want} W." >&2
    echo "Run first: $(dirname "${BASH_SOURCE[0]}")/apply-gpu-settings.sh <same config>" >&2
    exit 1
  fi
}
