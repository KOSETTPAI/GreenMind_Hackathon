#!/usr/bin/env bash
# run4 launcher. Same method as scripts/start-vllm.sh (same docker run, same
# environment variables, publish 127.0.0.1:${PORT}:8000), with the vLLM
# arguments taken from a run4 profile. Waits until the server answers, then
# runs the preflight against the same profile. Exit 0 only when it passes.
#
#   ./run4/start.sh                 # R4-full (default): E1 + MTP k=1 + prefix caching + memory 0.90
#   ./run4/start.sh no-prefix       # fallback: drop prefix caching
#   ./run4/start.sh no-mtp          # fallback: drop MTP
#   ./run4/start.sh safe            # fallback: the measured E1 server
#   CONFIRM_K2=1 ./run4/start.sh full-k2
#
# Like scripts/start-vllm.sh, it refuses to replace an existing container:
#   docker rm -f mango-vllm && ./run4/start.sh
# or let it save the old container's inspect and logs first:
#   REPLACE=1 ./run4/start.sh
#
# Environment (same names as scripts/start-vllm.sh):
#   CONTAINER_NAME   default mango-vllm
#   PORT             host port, default 8000
#   VLLM_IMAGE       default vllm/vllm-openai:nightly, or vllm/vllm-openai@sha256:<digest>
#   BIND             host address, default 127.0.0.1 as in scripts/start-vllm.sh.
#                    With REPLACE=1 and BIND unset, the replaced container's bind is kept.
#   MODEL_ID, SERVED_MODEL_NAME, GPU_MEMORY_UTILIZATION, MAX_MODEL_LEN
#                    come from the profile. If exported, they must match it.
# Other:
#   RUN4_TIER        tier when no argument is given (default full)
#   DRY_RUN=1        print the docker command and exit
#   WAIT_SECONDS=900 how long to wait for /v1/models
#   SKIP_PREFLIGHT=1 launch only (not recommended)
#
# Does not change the GPU power limit or clocks. See run4/power.sh.
set -Eeuo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$HERE/.." && pwd)"
CHECKS="$HERE/preflight_checks.py"

TIER="${1:-${RUN4_TIER:-full}}"
CONTAINER="${CONTAINER_NAME:-mango-vllm}"
PORT="${PORT:-8000}"
IMAGE="${VLLM_IMAGE:-vllm/vllm-openai:nightly}"
WAIT_SECONDS="${WAIT_SECONDS:-900}"
RUNS_DIR="${RUNS_DIR:-$HOME/greenmind-runs}"
BASE_URL="http://127.0.0.1:${PORT}/v1"

die() {
  echo "[ERROR] $*" >&2
  exit 1
}

case "$TIER" in
  full) PROFILE_FILE="$HERE/profiles/r4-full.args" ;;
  full-k2)
    [[ "${CONFIRM_K2:-}" == "1" ]] || die "full-k2 waits until R4-full beats E1 and tool calls stay clean. Re-run with CONFIRM_K2=1 after that row is in run4/log.md."
    PROFILE_FILE="$HERE/profiles/r4-full-k2.args"
    ;;
  no-prefix) PROFILE_FILE="$HERE/profiles/r4-no-prefix.args" ;;
  no-mtp) PROFILE_FILE="$HERE/profiles/r4-no-mtp.args" ;;
  safe) PROFILE_FILE="$HERE/profiles/e1.args" ;;
  *) die "Unknown tier '$TIER'. Run with no argument for R4-full, or one of: full no-prefix no-mtp safe full-k2" ;;
esac

[[ "$PORT" =~ ^[0-9]+$ ]] || die "PORT must be a number."
if [[ "$IMAGE" != "vllm/vllm-openai:nightly" && ! "$IMAGE" =~ ^vllm/vllm-openai@sha256:[0-9a-f]{64}$ ]]; then
  die "VLLM_IMAGE must be vllm/vllm-openai:nightly or vllm/vllm-openai@sha256:<digest>."
fi

command -v python3 >/dev/null 2>&1 || die "python3 is required."
ARGS_FILE="$(mktemp)"
trap 'rm -f "$ARGS_FILE"' EXIT
python3 "$CHECKS" launch-args "$PROFILE_FILE" > "$ARGS_FILE" \
  || die "Profile failed the endpoint contract: $PROFILE_FILE"
mapfile -d '' VLLM_ARGS < "$ARGS_FILE"
(( ${#VLLM_ARGS[@]} > 0 )) || die "Profile produced no arguments: $PROFILE_FILE"

PROFILE_MODEL="$(python3 "$CHECKS" profile-value "$PROFILE_FILE" model)"
PROFILE_SERVED="$(python3 "$CHECKS" profile-value "$PROFILE_FILE" --served-model-name)"
PROFILE_MEM="$(python3 "$CHECKS" profile-value "$PROFILE_FILE" --gpu-memory-utilization || echo '')"
PROFILE_LEN="$(python3 "$CHECKS" profile-value "$PROFILE_FILE" --max-model-len)"

# scripts/start-vllm.sh variables: a leftover export must not disagree with the profile.
if [[ -n "${MODEL_ID:-}" && "$MODEL_ID" != "$PROFILE_MODEL" && "$MODEL_ID" != "$PROFILE_SERVED" ]]; then
  die "MODEL_ID=$MODEL_ID differs from the profile ($PROFILE_MODEL). Unset it."
fi
if [[ -n "${SERVED_MODEL_NAME:-}" && "$SERVED_MODEL_NAME" != "$PROFILE_SERVED" ]]; then
  die "SERVED_MODEL_NAME=$SERVED_MODEL_NAME differs from the profile ($PROFILE_SERVED). Unset it."
fi
if [[ -n "${GPU_MEMORY_UTILIZATION:-}" ]] && ! awk -v a="$GPU_MEMORY_UTILIZATION" -v b="$PROFILE_MEM" 'BEGIN { exit !(b != "" && a + 0 == b + 0) }'; then
  die "GPU_MEMORY_UTILIZATION=$GPU_MEMORY_UTILIZATION differs from tier $TIER (${PROFILE_MEM:-unset}). Unset it; the profile sets it."
fi
if [[ -n "${MAX_MODEL_LEN:-}" && "$MAX_MODEL_LEN" != "$PROFILE_LEN" ]]; then
  die "MAX_MODEL_LEN=$MAX_MODEL_LEN differs from tier $TIER ($PROFILE_LEN). Unset it; the profile sets it."
fi

# Existing container and bind. Read before printing the command so the dry run shows the real bind.
EXISTING=0
INHERITED_BIND=""
if command -v docker >/dev/null 2>&1 && docker container inspect "$CONTAINER" >/dev/null 2>&1; then
  EXISTING=1
  first="$(docker port "$CONTAINER" 8000/tcp 2>/dev/null | head -1 || true)"
  if [[ -n "$first" ]]; then
    INHERITED_BIND="${first%:*}"
    INHERITED_BIND="${INHERITED_BIND#[}"
    INHERITED_BIND="${INHERITED_BIND%]}"
    [[ "$INHERITED_BIND" == "::" ]] && INHERITED_BIND="0.0.0.0"
  fi
fi
if [[ -n "${BIND:-}" ]]; then
  BIND_SOURCE="BIND environment variable"
elif (( EXISTING )) && [[ -n "$INHERITED_BIND" ]]; then
  BIND="$INHERITED_BIND"
  BIND_SOURCE="kept from the existing $CONTAINER container"
else
  BIND="127.0.0.1"
  BIND_SOURCE="scripts/start-vllm.sh default"
fi
case "$BIND" in
  0.0.0.0|127.0.0.1) ;;
  *) die "Bind '$BIND' ($BIND_SOURCE) must be 0.0.0.0 or 127.0.0.1." ;;
esac

DOCKER_CMD=(
  docker run -d
  --name "$CONTAINER"
  --restart unless-stopped
  --gpus all
  --ipc=host
  -p "${BIND}:${PORT}:8000"
  -v "$HOME/.cache/huggingface:/root/.cache/huggingface"
  --label "greenmind.run=run4"
  --label "greenmind.tier=$TIER"
  --label "greenmind.bind=$BIND"
  "$IMAGE"
  "${VLLM_ARGS[@]}"
)

echo "run4 tier:  $TIER"
echo "Profile:    $PROFILE_FILE"
echo "Container:  $CONTAINER"
echo "Bind:       ${BIND}:${PORT} -> container 8000 ($BIND_SOURCE)"
echo "Endpoint:   $BASE_URL"
echo "Image:      $IMAGE"
echo "Command:"
printf '  %q' "${DOCKER_CMD[@]}"
printf '\n'

if [[ "${DRY_RUN:-}" == "1" ]]; then
  echo "DRY_RUN=1: nothing started."
  exit 0
fi

command -v docker >/dev/null 2>&1 || die "docker is not on PATH."
command -v curl >/dev/null 2>&1 || die "curl is not on PATH."
docker info >/dev/null 2>&1 || die "Cannot talk to the Docker daemon."

if (( EXISTING )) && [[ "${REPLACE:-}" != "1" ]]; then
  echo "Container '$CONTAINER' already exists." >&2
  echo "Inspect it with: docker logs --tail 100 $CONTAINER" >&2
  echo "Remove it deliberately (docker rm -f $CONTAINER), or re-run with REPLACE=1 to save its record first." >&2
  exit 1
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
RUN_DIR="$RUNS_DIR/${STAMP}_r4-${TIER}"
mkdir -p "$RUN_DIR"
cp "$PROFILE_FILE" "$RUN_DIR/profile.args"
printf '%q ' "${DOCKER_CMD[@]}" > "$RUN_DIR/command.txt"
echo >> "$RUN_DIR/command.txt"

if (( EXISTING )); then
  echo "Saving the previous container's record to $RUN_DIR/previous-*"
  docker inspect "$CONTAINER" > "$RUN_DIR/previous-inspect.json" 2>&1 || true
  docker logs "$CONTAINER" > "$RUN_DIR/previous-container.log" 2>&1 || true
  docker rm -f "$CONTAINER" >/dev/null
fi

others="$(docker ps --format '{{.Names}}|{{.Ports}}' | awk -F'|' -v p=":${PORT}->" 'index($2, p) { print $1 }')"
[[ -z "$others" ]] || die "Another container publishes host port $PORT: $others. Stop it first."
if command -v nvidia-smi >/dev/null 2>&1; then
  apps=""
  for _ in $(seq 1 15); do
    apps="$(nvidia-smi --query-compute-apps=pid,process_name --format=csv,noheader 2>/dev/null || true)"
    [[ -z "$apps" ]] && break
    sleep 2
  done
  [[ -z "$apps" ]] || die "The GPU is still busy after 30 s. One serving process only: $(tr '\n' ';' <<< "$apps")"
fi

mkdir -p "$HOME/.cache/huggingface"
"${DOCKER_CMD[@]}" > "$RUN_DIR/container-id.txt"
ln -sfn "$RUN_DIR" "$RUNS_DIR/latest"

{
  echo "tier: $TIER"
  echo "started: $(date -Is)"
  echo "host: $(hostname)"
  echo "bind: ${BIND}:${PORT} ($BIND_SOURCE)"
  echo "git: $(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)$( [[ -n "$(git -C "$REPO_DIR" status --porcelain 2>/dev/null)" ]] && echo ' (dirty)')"
  echo "image: $IMAGE"
  echo "image_id: $(docker inspect -f '{{.Image}}' "$CONTAINER" 2>/dev/null || echo unknown)"
  echo "repo_digests: $(docker image inspect -f '{{json .RepoDigests}}' "$IMAGE" 2>/dev/null || echo unknown)"
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo "gpu: $(nvidia-smi --query-gpu=name,driver_version,power.limit,power.default_limit --format=csv,noheader 2>/dev/null || echo unknown)"
  fi
} > "$RUN_DIR/environment.txt"

echo
echo "Started $CONTAINER. Record: $RUN_DIR"
echo "Waiting up to ${WAIT_SECONDS}s for $BASE_URL/models ..."

deadline=$(( $(date +%s) + WAIT_SECONDS ))
ready=0
state="unknown"
restarts="0"
while (( $(date +%s) < deadline )); do
  state="$(docker inspect -f '{{.State.Status}}' "$CONTAINER" 2>/dev/null || echo missing)"
  restarts="$(docker inspect -f '{{.RestartCount}}' "$CONTAINER" 2>/dev/null || echo 0)"
  if [[ "$state" != "running" && "$state" != "restarting" ]] || (( restarts > 0 )); then
    break
  fi
  if curl -fsS --max-time 5 "$BASE_URL/models" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 5
done

docker logs "$CONTAINER" > "$RUN_DIR/startup.log" 2>&1 || true
echo "vllm_version: $(docker exec "$CONTAINER" python3 -c 'import vllm; print(vllm.__version__)' 2>/dev/null || echo unknown)" >> "$RUN_DIR/environment.txt"

echo
echo "--- Startup facts (from $RUN_DIR/startup.log) ---"
grep -Ei 'maximum concurrency|max_num_batched_tokens|max_num_seqs|chunked prefill|prefix caching|mamba_cache_mode|speculative|num_speculative_tokens|mtp|cuda ?graph|kv cache|out of memory|error|traceback' \
  "$RUN_DIR/startup.log" | tail -40 || echo "(no matching lines)"

if (( ready == 0 )); then
  echo
  echo "[FAIL] Server did not become ready (state: ${state:-unknown}, restarts: ${restarts:-?})."
  echo "Last 60 log lines:"
  tail -60 "$RUN_DIR/startup.log" || true
  echo
  echo "NOT READY. Do not benchmark. Stop it with: docker rm -f $CONTAINER"
  echo "Fallback order: full -> no-prefix -> no-mtp -> safe"
  exit 1
fi

echo
echo "[PASS] $BASE_URL/models answered."
if [[ "${SKIP_PREFLIGHT:-}" == "1" ]]; then
  echo "SKIP_PREFLIGHT=1: run PROFILE=$PROFILE_FILE ./run4/preflight.sh before any benchmark."
  exit 0
fi

echo "Running the preflight with the same profile ..."
pf_rc=0
PROFILE="$PROFILE_FILE" EXPECTED_BIND="$BIND" CONTAINER="$CONTAINER" HOST_PORT="$PORT" \
  BASE_URL="$BASE_URL" MODEL_ID="$PROFILE_SERVED" PREFLIGHT_LOG_DIR="$RUN_DIR/preflight" \
  "$HERE/preflight.sh" || pf_rc=$?

echo
if (( pf_rc == 0 )); then
  echo "READY: tier $TIER passed the preflight. Record: $RUN_DIR"
  echo "Before Submit: python3 run4/warmup.py, then ./run4/watch.sh in a second shell (Validation only)."
  exit 0
fi
echo "NOT READY: preflight failed for tier $TIER. Do not benchmark."
echo "Fallback order: full -> no-prefix -> no-mtp -> safe"
exit 1
