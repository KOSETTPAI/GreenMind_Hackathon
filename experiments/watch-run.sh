#!/usr/bin/env bash
# Record host GPU telemetry and vLLM metrics for one graded window.
# Does not change clocks, the power limit, or server flags.
set -euo pipefail

if [[ -f /.dockerenv ]]; then
  echo "Run this on the VM host, outside the vLLM container." >&2
  exit 1
fi

stamp="$(date +%Y%m%d-%H%M%S)"
OUT="${1:-${HOME}/greenmind-watch/${stamp}}"
mkdir -p "$OUT"
echo "Recording to ${OUT}"
echo "Start this before Submit and stop it when the grader finishes."

nvidia-smi dmon -s pucm -d 2 > "${OUT}/nvidia-smi-dmon.log" &
dmon_pid=$!
sleep 0.2
if ! kill -0 "$dmon_pid" 2>/dev/null; then
  echo "nvidia-smi dmon exited immediately. Its log is ${OUT}/nvidia-smi-dmon.log" >&2
  exit 1
fi
cleanup() {
  kill "$dmon_pid" >/dev/null 2>&1 || true
  wait "$dmon_pid" 2>/dev/null || true
}
trap cleanup EXIT
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

while true; do
  {
    echo "----- $(date -Is) -----"
    curl -fsS --max-time 10 http://127.0.0.1:8000/metrics || echo "metrics unavailable"
  } >> "${OUT}/metrics.log"
  sleep 30
done
