#!/usr/bin/env bash
# GreenMind Hackathon preflight. Run on the VM before every benchmark.
#
# Read-only: inspects Docker and sends a few small requests to the running
# server. It never starts, stops, or changes a container, clocks, or power.
# Finish it before clicking Submit; do not run it during a graded window.
#
# Exit 0 = ready, 1 = do not benchmark, 2 = usage error.
#
#   ./run4/preflight.sh                  # profile and bind from run4/start.sh's container labels;
#                                        # otherwise E1 (max-model-len 40960) on 127.0.0.1
#   PROFILE=v0 ./run4/preflight.sh       # scripts/start-vllm.sh defaults (32768)
#   PROFILE=path/to/x.args ./run4/preflight.sh
#   EXPECTED_BIND=0.0.0.0 ./run4/preflight.sh
set -Eeuo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$HERE/.." && pwd)"
CHECKS="$HERE/preflight_checks.py"

CONTAINER="${CONTAINER:-${CONTAINER_NAME:-mango-vllm}}"
MODEL_ID="${MODEL_ID:-mango1.5-awq-w4a16}"
HOST_PORT="${HOST_PORT:-${PORT:-8000}}"
BASE_URL="${BASE_URL:-http://127.0.0.1:${HOST_PORT}/v1}"
EXPECTED_MAX_LEN="${EXPECTED_MAX_LEN:-}"
PREFLIGHT_LOG_DIR="${PREFLIGHT_LOG_DIR:-$HOME/greenmind-preflight}"

# Labels written by run4/start.sh record what the container was launched as.
container_label() {
  command -v docker >/dev/null 2>&1 || return 0
  docker inspect -f "{{index .Config.Labels \"$1\"}}" "$CONTAINER" 2>/dev/null | grep -v '^<no value>$' || true
}
LABEL_TIER="$(container_label greenmind.tier)"
LABEL_BIND="$(container_label greenmind.bind)"

if [[ -n "${PROFILE:-}" ]]; then
  PROFILE_SOURCE="PROFILE environment variable"
else
  case "$LABEL_TIER" in
    full|full-k2|no-prefix|no-mtp) PROFILE="r4-$LABEL_TIER"; PROFILE_SOURCE="container label greenmind.tier=$LABEL_TIER" ;;
    safe) PROFILE="e1"; PROFILE_SOURCE="container label greenmind.tier=safe" ;;
    *) PROFILE="e1"; PROFILE_SOURCE="default (no run4 label)" ;;
  esac
fi
if [[ -n "${EXPECTED_BIND:-}" ]]; then
  BIND_SOURCE="EXPECTED_BIND environment variable"
elif [[ -n "$LABEL_BIND" ]]; then
  EXPECTED_BIND="$LABEL_BIND"
  BIND_SOURCE="container label greenmind.bind"
else
  EXPECTED_BIND="127.0.0.1"
  BIND_SOURCE="scripts/start-vllm.sh default"
fi

if [[ "$PROFILE" == */* || "$PROFILE" == *.args ]]; then
  PROFILE_FILE="$PROFILE"
else
  PROFILE_FILE="$HERE/profiles/${PROFILE}.args"
fi

usage_error() {
  echo "[USAGE] $*" >&2
  exit 2
}

[[ -f "$PROFILE_FILE" ]] || usage_error "Profile not found: $PROFILE_FILE (available: $(ls "$HERE/profiles" | sed 's/\.args$//' | tr '\n' ' '))"
command -v python3 >/dev/null 2>&1 || usage_error "python3 is required to run the checks."

PROFILE_MAX_LEN="$(python3 "$CHECKS" profile-value "$PROFILE_FILE" --max-model-len)" \
  || usage_error "Profile $PROFILE_FILE has no --max-model-len line."
PROFILE_SERVED="$(python3 "$CHECKS" profile-value "$PROFILE_FILE" --served-model-name)" \
  || usage_error "Profile $PROFILE_FILE has no --served-model-name line."
PROFILE_MODEL="$(python3 "$CHECKS" profile-value "$PROFILE_FILE" model)"

if [[ -n "$EXPECTED_MAX_LEN" && "$EXPECTED_MAX_LEN" != "$PROFILE_MAX_LEN" ]]; then
  usage_error "EXPECTED_MAX_LEN=$EXPECTED_MAX_LEN contradicts profile $PROFILE ($PROFILE_MAX_LEN). Pick the profile for the experiment you launched (v0 = 32768, e1 = 40960) instead of loosening the check."
fi
EXPECTED_MAX_LEN="$PROFILE_MAX_LEN"
if [[ "$MODEL_ID" == "$PROFILE_MODEL" ]]; then
  # scripts/start-vllm.sh uses MODEL_ID for the checkpoint; the API serves the served name.
  MODEL_ID="$PROFILE_SERVED"
fi
if [[ "$MODEL_ID" != "$PROFILE_SERVED" ]]; then
  usage_error "MODEL_ID=$MODEL_ID differs from the profile's --served-model-name $PROFILE_SERVED."
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
RUN_DIR="$PREFLIGHT_LOG_DIR/$STAMP"

FAILURES=0
WARNINGS=0
pass() { printf '[PASS] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*"; FAILURES=$((FAILURES + 1)); }
warn() { printf '[WARN] %s\n' "$*"; WARNINGS=$((WARNINGS + 1)); }
info() { printf '[INFO] %s\n' "$*"; }

# run_check LABEL CHECK ARGS...: maps preflight_checks.py exit codes.
run_check() {
  local label="$1"
  shift
  local rc=0
  python3 "$CHECKS" "$@" || rc=$?
  case "$rc" in
    0) pass "$label" ;;
    3) warn "$label (see details above)" ;;
    *) fail "$label" ;;
  esac
}

finish() {
  echo
  if (( FAILURES == 0 )); then
    echo "RESULT: PREFLIGHT PASSED ($WARNINGS warning(s))"
    echo "Local checks passed. Reachability from outside the VM is NOT verified by this script."
    if [[ "$EXPECTED_BIND" == "127.0.0.1" ]]; then
      echo "The bind is loopback, as in scripts/start-vllm.sh: only clients on this VM reach port $HOST_PORT directly."
    else
      echo "Run run4/check-external.ps1 from a machine outside the VM."
    fi
    return 0
  fi
  echo "RESULT: PREFLIGHT FAILED ($FAILURES check(s)). Do not benchmark."
  echo "Fix the first [FAIL] above, then rerun the whole script."
  return 1
}

stop_early() {
  echo
  echo "Stopping before the API checks: the container is not usable."
  finish || true
  exit 1
}

main() {
  echo "=========================================="
  echo " GreenMind Hackathon: PRE-FLIGHT CHECK"
  echo "=========================================="
  echo "Time:      $(date -Is)"
  echo "Host:      $(hostname)"
  echo "Repo:      $REPO_DIR"
  echo "Container: $CONTAINER"
  echo "Model ID:  $MODEL_ID"
  echo "Endpoint:  $BASE_URL"
  echo "Profile:   $PROFILE_FILE (max-model-len $EXPECTED_MAX_LEN; $PROFILE_SOURCE)"
  echo "Bind:      expected $EXPECTED_BIND:$HOST_PORT ($BIND_SOURCE)"
  echo "Records:   $RUN_DIR"
  echo

  # 1. Repository
  if git -C "$REPO_DIR" rev-parse --show-toplevel >/dev/null 2>&1; then
    pass "Git repository: $(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || echo 'no commits')"
    if [[ -n "$(git -C "$REPO_DIR" status --porcelain 2>/dev/null)" ]]; then
      warn "Working tree has uncommitted changes; record them with the run"
    fi
  else
    fail "Not inside a Git repository: $REPO_DIR"
  fi

  # 2. Tools
  for cmd in docker python3; do
    if command -v "$cmd" >/dev/null 2>&1; then
      pass "Command available: $cmd"
    else
      fail "Missing command: $cmd"
    fi
  done
  command -v curl >/dev/null 2>&1 || warn "curl not found; the runbook's manual commands use it"
  (( FAILURES == 0 )) || stop_early

  # 3. Docker daemon
  if docker info >/dev/null 2>&1; then
    pass "Docker daemon reachable"
  else
    fail "Cannot talk to the Docker daemon (permissions or daemon down)"
    stop_early
  fi

  # 4. Container exists, is running, is not crash-looping
  if ! docker container inspect "$CONTAINER" >/dev/null 2>&1; then
    fail "Container '$CONTAINER' does not exist"
    stop_early
  fi
  local state restarts started image_ref image_id netmode
  state="$(docker inspect -f '{{.State.Status}}' "$CONTAINER" 2>/dev/null || echo unknown)"
  restarts="$(docker inspect -f '{{.RestartCount}}' "$CONTAINER" 2>/dev/null || echo '?')"
  started="$(docker inspect -f '{{.State.StartedAt}}' "$CONTAINER" 2>/dev/null || echo '?')"
  if [[ "$state" == "running" ]]; then
    pass "Container is running (started $started)"
  else
    fail "Container state is '$state', not running"
    stop_early
  fi
  if [[ "$restarts" =~ ^[0-9]+$ ]] && (( restarts > 0 )); then
    warn "Container has restarted $restarts time(s); check the log for a crash loop"
  fi

  # 5. No second container publishing the same host port
  local others
  others="$(docker ps --format '{{.Names}}|{{.Ports}}' | awk -F'|' -v c="$CONTAINER" -v p=":${HOST_PORT}->" '$1 != c && index($2, p) { print $1 }')"
  if [[ -n "$others" ]]; then
    fail "Other container(s) also publish host port $HOST_PORT: $others"
  else
    pass "No other container publishes host port $HOST_PORT"
  fi

  # 6. Port binding
  netmode="$(docker inspect -f '{{.HostConfig.NetworkMode}}' "$CONTAINER" 2>/dev/null || echo '?')"
  if [[ "$netmode" == "host" ]]; then
    warn "Container uses host networking; no port mapping to check. The API checks below still test $BASE_URL"
  else
    local ports
    ports="$(docker port "$CONTAINER" 8000/tcp 2>/dev/null || true)"
    run_check "Port binding (expected $EXPECTED_BIND:$HOST_PORT -> 8000/tcp)" \
      ports "$ports" "$EXPECTED_BIND" "$HOST_PORT"
  fi

  # 7. vLLM arguments exactly match the experiment profile
  local cmd_json entrypoint
  cmd_json="$(docker inspect -f '{{json .Config.Cmd}}' "$CONTAINER" 2>/dev/null || echo 'null')"
  entrypoint="$(docker inspect -f '{{json .Config.Entrypoint}}' "$CONTAINER" 2>/dev/null || echo 'null')"
  info "Entrypoint: $entrypoint"
  info "Command:    $cmd_json"
  run_check "Container arguments (profile $(basename "$PROFILE_FILE"))" \
    args "$PROFILE_FILE" "$cmd_json" "$EXPECTED_MAX_LEN"

  # 8. Image and GPU (informational)
  image_ref="$(docker inspect -f '{{.Config.Image}}' "$CONTAINER" 2>/dev/null || echo '?')"
  image_id="$(docker inspect -f '{{.Image}}' "$CONTAINER" 2>/dev/null || echo '?')"
  info "Image: $image_ref ($image_id)"
  case "$image_ref" in
    vllm/vllm-openai*) ;;
    *) warn "Image is not vllm/vllm-openai; confirm this is intended" ;;
  esac
  if command -v nvidia-smi >/dev/null 2>&1; then
    local apps napps
    apps="$(nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader 2>/dev/null || true)"
    napps="$(grep -c . <<< "$apps" || true)"
    info "GPU compute processes: ${napps:-0}"
    [[ -n "$apps" ]] && sed 's/^/       /' <<< "$apps"
    if (( ${napps:-0} > 1 )); then
      warn "More than one GPU process; the rules allow one serving process during a graded run"
    fi
    info "GPU power limit: $(nvidia-smi --query-gpu=power.limit --format=csv,noheader 2>/dev/null || echo '?')"
  else
    warn "nvidia-smi not found on the host; GPU state not checked"
  fi

  # 9. /models: endpoint answers, serves the expected id and context
  local models_rc=0
  python3 "$CHECKS" models "$BASE_URL" "$MODEL_ID" "$EXPECTED_MAX_LEN" "$PROFILE_MODEL" || models_rc=$?
  case "$models_rc" in
    0) pass "GET /models serves $MODEL_ID with context $EXPECTED_MAX_LEN" ;;
    3) warn "GET /models serves $MODEL_ID (see details above)" ;;
    *)
      fail "GET /models did not serve $MODEL_ID as expected"
      echo "       Skipping inference checks; the model may still be loading: docker logs -f $CONTAINER"
      ;;
  esac

  if (( models_rc == 0 || models_rc == 3 )); then
    # 10. Deterministic non-streaming reply (thinking off)
    run_check "Chat completion returns PREFLIGHT_OK" chat "$BASE_URL" "$MODEL_ID"
    # 11. Streaming with usage (the grader needs streaming to observe TTFT)
    run_check "Streaming response with usage and [DONE]" stream "$BASE_URL" "$MODEL_ID"
    # 12. Streaming tool call with tool_choice=auto
    run_check "Streaming tool call parses (get_weather, JSON arguments)" tool "$BASE_URL" "$MODEL_ID"
    # 13. Grader path: streaming with thinking on
    run_check "Streaming with thinking enabled" thinking "$BASE_URL" "$MODEL_ID"
  fi

  # 14. Save records and show recent logs
  if mkdir -p "$RUN_DIR" 2>/dev/null; then
    docker inspect "$CONTAINER" > "$RUN_DIR/inspect.json" 2>&1 || true
    docker logs --tail 300 "$CONTAINER" > "$RUN_DIR/container-tail.log" 2>&1 || true
    info "Saved inspect.json and container-tail.log in $RUN_DIR"
  fi
  echo
  echo "--- Recent container logs (last 30 lines) ---"
  docker logs --tail 30 "$CONTAINER" 2>&1 || true
  if docker logs --tail 300 "$CONTAINER" 2>&1 | grep -Eqi 'Traceback|CUDA out of memory|OutOfMemoryError|EngineDeadError|RuntimeError'; then
    echo
    warn "Recent log lines contain an error signature; read $RUN_DIR/container-tail.log"
  fi

  finish
}

if mkdir -p "$RUN_DIR" 2>/dev/null; then
  set +e
  { set -e; main; } 2>&1 | tee "$RUN_DIR/preflight.log"
  rc="${PIPESTATUS[0]}"
  exit "$rc"
fi
echo "[WARN] Cannot write $RUN_DIR; running without a saved log." >&2
main
