#!/usr/bin/env bash
# Reproduce scripts/start-vllm.sh, then apply exactly one experiment delta.
# Source this file. Running it directly does not start a container.
#
# The image entrypoint is already `vllm serve`. Arguments begin with the model
# id, matching the scored baseline. Do not insert another `vllm serve`.
set -euo pipefail

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "Source this file from an experiment start.sh. It does not launch by itself." >&2
  exit 1
fi

_EXPERIMENT_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ADOPTED_ENV="$(cd "${_EXPERIMENT_LIB_DIR}/.." && pwd)/adopted.env"

die() {
  echo "$*" >&2
  exit 1
}

reject_leaked_knobs() {
  local leaked=()
  local name
  for name in \
    GPU_MEMORY_UTILIZATION \
    MAX_MODEL_LEN \
    MAX_NUM_SEQS \
    MAX_NUM_BATCHED_TOKENS \
    ENABLE_CHUNKED_PREFILL \
    SPECULATIVE_CONFIG \
    PREFIX_CACHING \
    EXTRA_VLLM_ARGS
  do
    if [[ -n "${!name+x}" ]]; then
      leaked+=("$name")
    fi
  done
  if ((${#leaked[@]} > 0)); then
    echo "Unset these variables before an experiment launch: ${leaked[*]}" >&2
    echo "scripts/start-vllm.sh reads only a subset of them. Experiment scripts pass one delta as an argument." >&2
    exit 1
  fi

  if [[ "${CONTAINER_NAME:-mango-vllm}" != "mango-vllm" ]]; then
    die "Refusing CONTAINER_NAME=${CONTAINER_NAME}. Keep the single server container named mango-vllm."
  fi
  if [[ "${PORT:-8000}" != "8000" ]]; then
    die "Refusing PORT=${PORT}. The health-checked bind is 127.0.0.1:8000."
  fi
  if [[ "${MODEL_ID:-CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp}" != "CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp" ]]; then
    die "Refusing MODEL_ID=${MODEL_ID}. Keep the scored AWQ checkpoint."
  fi
  if [[ "${SERVED_MODEL_NAME:-mango1.5-awq-w4a16}" != "mango1.5-awq-w4a16" ]]; then
    die "Refusing SERVED_MODEL_NAME=${SERVED_MODEL_NAME}. The grader selects mango1.5-awq-w4a16."
  fi

  IMAGE="${VLLM_IMAGE:-vllm/vllm-openai:nightly}"
  if [[ "$IMAGE" == "vllm/vllm-openai:nightly" ]]; then
    :
  elif [[ "$IMAGE" =~ ^vllm/vllm-openai@sha256:[0-9a-f]{64}$ ]]; then
    :
  else
    die "Refusing VLLM_IMAGE=${IMAGE}. Use vllm/vllm-openai:nightly or a sha256 pin of that image."
  fi
}

read_adopted_env() {
  HELD_MAX_MODEL_LEN=""
  HELD_GPU_MEMORY_UTILIZATION=""
  HELD_MAX_NUM_BATCHED_TOKENS=""
  HELD_CHUNKED_PREFILL=""
  HELD_SPECULATIVE_TOKENS=""
  HELD_PREFIX_CACHING=""
  HELD_MAX_NUM_SEQS=""
  local -A seen=()
  [[ -f "$_ADOPTED_ENV" ]] || die "Missing $_ADOPTED_ENV"
  local line key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//$'\r'/}"
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    [[ "$line" == HELD_[A-Z_]*=* ]] || die "Bad line in adopted.env: $line"
    key="${line%%=*}"
    value="${line#*=}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    [[ -z "${seen[$key]+x}" ]] || die "Duplicate key in adopted.env: $key"
    seen["$key"]=1
    case "$key" in
      HELD_MAX_MODEL_LEN)
        [[ -z "$value" || "$value" == "40960" ]] || die "HELD_MAX_MODEL_LEN must be empty or 40960."
        HELD_MAX_MODEL_LEN="$value"
        ;;
      HELD_GPU_MEMORY_UTILIZATION)
        case "$value" in
          ""|0.90|0.92|0.95) HELD_GPU_MEMORY_UTILIZATION="$value" ;;
          *) die "HELD_GPU_MEMORY_UTILIZATION must be empty, 0.90, 0.92, or 0.95." ;;
        esac
        ;;
      HELD_MAX_NUM_BATCHED_TOKENS)
        case "$value" in
          ""|2048|4096|8192) HELD_MAX_NUM_BATCHED_TOKENS="$value" ;;
          *) die "HELD_MAX_NUM_BATCHED_TOKENS must be empty, 2048, 4096, or 8192." ;;
        esac
        ;;
      HELD_CHUNKED_PREFILL)
        case "$value" in
          ""|0) HELD_CHUNKED_PREFILL="" ;;
          1) HELD_CHUNKED_PREFILL="1" ;;
          *) die "HELD_CHUNKED_PREFILL must be empty, 0, or 1." ;;
        esac
        ;;
      HELD_SPECULATIVE_TOKENS)
        case "$value" in
          ""|0) HELD_SPECULATIVE_TOKENS="" ;;
          1|2|3) HELD_SPECULATIVE_TOKENS="$value" ;;
          *) die "HELD_SPECULATIVE_TOKENS must be empty, 0, 1, 2, or 3." ;;
        esac
        ;;
      HELD_PREFIX_CACHING)
        case "$value" in
          ""|0) HELD_PREFIX_CACHING="" ;;
          1) HELD_PREFIX_CACHING="1" ;;
          *) die "HELD_PREFIX_CACHING must be empty, 0, or 1." ;;
        esac
        ;;
      HELD_MAX_NUM_SEQS)
        case "$value" in
          ""|64|128|192|256) HELD_MAX_NUM_SEQS="$value" ;;
          *) die "HELD_MAX_NUM_SEQS must be empty, 64, 128, 192, or 256." ;;
        esac
        ;;
      *)
        die "Unknown key in adopted.env: $key"
        ;;
    esac
  done < "$_ADOPTED_ENV"

  HELD_ANY=0
  local held_value
  for held_value in \
    "$HELD_MAX_MODEL_LEN" \
    "$HELD_GPU_MEMORY_UTILIZATION" \
    "$HELD_MAX_NUM_BATCHED_TOKENS" \
    "$HELD_CHUNKED_PREFILL" \
    "$HELD_SPECULATIVE_TOKENS" \
    "$HELD_PREFIX_CACHING" \
    "$HELD_MAX_NUM_SEQS"
  do
    [[ -n "$held_value" ]] && HELD_ANY=1
  done

  if [[ "${ADOPT_PREVIOUS:-}" == "1" ]]; then
    [[ "$HELD_ANY" == "1" ]] || die "ADOPT_PREVIOUS=1 requires at least one kept value in experiments/adopted.env."
  elif [[ "$HELD_ANY" == "1" ]]; then
    die "experiments/adopted.env has kept values. Pass ADOPT_PREVIOUS=1 to include them, or clear them for an isolated V0 comparison."
  fi
}

assert_isolated_from_v0() {
  reject_leaked_knobs
  read_adopted_env
  [[ "${ADOPT_PREVIOUS:-}" != "1" ]] || die "This experiment is the isolated comparison with scripts/start-vllm.sh. Unset ADOPT_PREVIOUS."
  [[ "$HELD_ANY" == "0" ]] || die "Clear experiments/adopted.env before this isolated launch."
}

validate_budget() {
  case "$1" in
    2048|4096|8192) ;;
    *) die "Batched-token budget must be 2048, 4096, or 8192." ;;
  esac
}

validate_gpu_mem() {
  case "$1" in
    0.90|0.92|0.95) ;;
    *) die "GPU memory utilization experiment must be 0.90, 0.92, or 0.95." ;;
  esac
}

validate_seqs() {
  case "$1" in
    64|128|192|256) ;;
    *) die "max_num_seqs experiment must be 64, 128, 192, or 256." ;;
  esac
}

launch_from_baseline() {
  local op="${1:-}"
  local name="${2:-}"
  local value="${3:-}"
  [[ "$#" -le 3 ]] || die "One experiment delta only."
  [[ -n "$op" ]] || die "Missing experiment operation."

  reject_leaked_knobs
  read_adopted_env

  local gpu_mem="0.85"
  local max_len="32768"
  local seqs=""
  local budget=""
  local chunked=0
  local spec_k=""
  local prefix=0

  if [[ "${ADOPT_PREVIOUS:-}" == "1" ]]; then
    [[ -n "$HELD_GPU_MEMORY_UTILIZATION" ]] && gpu_mem="$HELD_GPU_MEMORY_UTILIZATION"
    [[ -n "$HELD_MAX_MODEL_LEN" ]] && max_len="$HELD_MAX_MODEL_LEN"
    seqs="$HELD_MAX_NUM_SEQS"
    budget="$HELD_MAX_NUM_BATCHED_TOKENS"
    [[ "$HELD_CHUNKED_PREFILL" == "1" ]] && chunked=1
    spec_k="$HELD_SPECULATIVE_TOKENS"
    [[ "$HELD_PREFIX_CACHING" == "1" ]] && prefix=1
  fi

  case "$op" in
    replace)
      [[ "$#" -eq 3 ]] || die "replace needs a flag name and a value."
      case "$name" in
        max-model-len)
          [[ -z "$HELD_MAX_MODEL_LEN" ]] || die "max-model-len is already a kept value. Pick a different delta."
          [[ "$value" == "40960" ]] || die "The max-model-len experiment sets 40960."
          max_len="$value"
          ;;
        gpu-memory-utilization)
          [[ -z "$HELD_GPU_MEMORY_UTILIZATION" ]] || die "gpu-memory-utilization is already a kept value. Pick a different delta."
          validate_gpu_mem "$value"
          gpu_mem="$value"
          ;;
        *)
          die "Unknown replace flag: $name"
          ;;
      esac
      ;;
    add)
      [[ "$#" -eq 3 ]] || die "add needs a flag name and a value."
      case "$name" in
        max-num-batched-tokens)
          [[ -z "$budget" ]] || die "max-num-batched-tokens is already a kept value. Pick a different delta."
          validate_budget "$value"
          budget="$value"
          ;;
        max-num-seqs)
          [[ -z "$seqs" ]] || die "max-num-seqs is already a kept value. Pick a different delta."
          validate_seqs "$value"
          seqs="$value"
          ;;
        speculative-config)
          [[ -z "$spec_k" ]] || die "MTP is already a kept value. Pick a different delta."
          case "$value" in
            '{"method":"mtp","num_speculative_tokens":1}') spec_k="1" ;;
            '{"method":"mtp","num_speculative_tokens":2}') spec_k="2" ;;
            '{"method":"mtp","num_speculative_tokens":3}') spec_k="3" ;;
            *) die "speculative-config must be the documented mtp JSON with num_speculative_tokens 1, 2, or 3." ;;
          esac
          ;;
        *)
          die "Unknown add flag: $name"
          ;;
      esac
      ;;
    add-bool)
      [[ "$#" -eq 2 ]] || die "add-bool needs a flag name."
      case "$name" in
        enable-chunked-prefill)
          [[ "$chunked" == "0" ]] || die "Chunked prefill is already a kept value. Pick a different delta."
          chunked=1
          ;;
        *)
          die "Unknown boolean flag: $name"
          ;;
      esac
      ;;
    prefix-caching)
      [[ "$#" -eq 1 ]] || die "prefix-caching takes no extra arguments."
      [[ "$prefix" == "0" ]] || die "Prefix caching is already a kept value. Pick a different delta."
      prefix=1
      ;;
    *)
      die "Unknown experiment operation: $op"
      ;;
  esac

  local -a vllm_args=(
    "CMKL/MANGO1.5-Qwen3.5-9B-AWQ-W4A16-mtp"
    --host 0.0.0.0
    --port 8000
    --served-model-name "mango1.5-awq-w4a16"
    --trust-remote-code
    --gpu-memory-utilization "$gpu_mem"
    --max-model-len "$max_len"
    --enable-auto-tool-choice
    --tool-call-parser qwen3_coder
    --reasoning-parser qwen3
  )
  [[ -z "$seqs" ]] || vllm_args+=(--max-num-seqs "$seqs")
  [[ -z "$budget" ]] || vllm_args+=(--max-num-batched-tokens "$budget")
  [[ "$chunked" == "1" ]] && vllm_args+=(--enable-chunked-prefill)
  if [[ -n "$spec_k" ]]; then
    vllm_args+=(--speculative-config "{\"method\":\"mtp\",\"num_speculative_tokens\":${spec_k}}")
  fi
  if [[ "$prefix" == "1" ]]; then
    vllm_args+=(--enable-prefix-caching --mamba-cache-mode align)
  fi

  echo "Experiment: ${EXPERIMENT_ID:-unspecified}"
  echo "Single delta: ${EXPERIMENT_DELTA:-unspecified}"
  if [[ "${ADOPT_PREVIOUS:-}" == "1" ]]; then
    echo "Kept from experiments/adopted.env:"
    [[ -n "$HELD_MAX_MODEL_LEN" ]] && echo "  max-model-len ${HELD_MAX_MODEL_LEN}"
    [[ -n "$HELD_GPU_MEMORY_UTILIZATION" ]] && echo "  gpu-memory-utilization ${HELD_GPU_MEMORY_UTILIZATION}"
    [[ -n "$HELD_MAX_NUM_BATCHED_TOKENS" ]] && echo "  max-num-batched-tokens ${HELD_MAX_NUM_BATCHED_TOKENS}"
    [[ "$HELD_CHUNKED_PREFILL" == "1" ]] && echo "  enable-chunked-prefill"
    [[ -n "$HELD_SPECULATIVE_TOKENS" ]] && echo "  speculative-config mtp k=${HELD_SPECULATIVE_TOKENS}"
    [[ "$HELD_PREFIX_CACHING" == "1" ]] && echo "  prefix caching with mamba-cache-mode align"
    [[ -n "$HELD_MAX_NUM_SEQS" ]] && echo "  max-num-seqs ${HELD_MAX_NUM_SEQS}"
  else
    echo "Kept flags: none. This launch differs from scripts/start-vllm.sh by the single delta above."
  fi
  echo "Image: ${IMAGE}"
  echo "This script does not change the GPU power limit. Check it with:"
  echo "bash ${_EXPERIMENT_LIB_DIR}/../07-power-cap/show-power.sh"
  echo "vLLM arguments:"
  printf '  %q' "${vllm_args[@]}"
  printf '\n'
  if [[ -n "${EXPERIMENT_NEXT:-}" ]]; then
    echo "${EXPERIMENT_NEXT}"
  fi

  if [[ "${DRY_RUN:-}" == "1" ]]; then
    echo "DRY_RUN=1: container was not started."
    return 0
  fi

  command -v docker >/dev/null 2>&1 || die "docker is not on PATH."
  mkdir -p "${HOME}/.cache/huggingface"

  if docker container inspect mango-vllm >/dev/null 2>&1; then
    echo "Container 'mango-vllm' already exists." >&2
    echo "Inspect it with: docker logs --tail 100 mango-vllm" >&2
    echo "Remove it deliberately before recreating it." >&2
    exit 1
  fi

  docker run -d \
    --name mango-vllm \
    --restart unless-stopped \
    --gpus all \
    --ipc=host \
    -p "127.0.0.1:8000:8000" \
    -v "${HOME}/.cache/huggingface:/root/.cache/huggingface" \
    "$IMAGE" \
    "${vllm_args[@]}" \
    || die "docker run failed. If the container exists, read: docker logs --tail 100 mango-vllm"

  echo
  echo "Container started. Follow initialization with:"
  echo "docker logs -f mango-vllm"
  echo
  echo "Local API endpoint: http://127.0.0.1:8000/v1"
  echo "Record the image digest before comparing this run with V0:"
  echo "docker inspect --format '{{.Image}}' mango-vllm"
}
