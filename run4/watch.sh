#!/usr/bin/env bash
# Sample GPU energy and vLLM metrics once a second into a CSV, until Ctrl-C.
# Read-only: queries nvidia-smi and GET /metrics. Use on Validation runs only;
# leave it off during Final to stay clearly inside "no other workloads".
#
#   ./run4/watch.sh                     # writes into ~/greenmind-runs/latest/
#   ./run4/watch.sh path/to/out.csv
# Then: python3 run4/summarize.py ~/greenmind-runs/latest/telemetry.csv --slo-met N --track final|validation
set -Eeuo pipefail

[[ -f /.dockerenv ]] && { echo "Run on the VM host." >&2; exit 1; }
OUT="${1:-$HOME/greenmind-runs/latest/telemetry.csv}"
METRICS_URL="${METRICS_URL:-http://127.0.0.1:8000/metrics}"
mkdir -p "$(dirname "$OUT")"

metric() {
  awk -v m="$1" '
    index($0, m) == 1 {
      c = substr($0, length(m) + 1, 1)
      if (c == "{" || c == " ") { s += $NF; found = 1 }
    }
    END { if (found) printf "%s", s }' <<< "$2"
}

echo "t,energy_mj,power_w,util_pct,sm_clock_mhz,mem_used_mib,running,waiting,kv_cache_usage,preemptions_total,prompt_tokens_total,generation_tokens_total,prefix_queries_total,prefix_hits_total,spec_draft_tokens_total,spec_accepted_tokens_total" > "$OUT"
trap 'echo; echo "Stopped. Wrote $OUT"; exit 0' INT TERM
echo "Sampling every 1 s into $OUT. Ctrl-C when the grader finishes."

while true; do
  t="$(date +%s.%N)"
  if ! gpu="$(nvidia-smi -i 0 --query-gpu=total_energy_consumption,power.draw,utilization.gpu,clocks.sm,memory.used --format=csv,noheader,nounits 2>/dev/null)"; then
    gpu=",$(nvidia-smi -i 0 --query-gpu=power.draw,utilization.gpu,clocks.sm,memory.used --format=csv,noheader,nounits 2>/dev/null || echo ',,,')"
  fi
  gpu="${gpu// /}"
  m="$(curl -s -m 2 "$METRICS_URL" || true)"
  kv="$(metric 'vllm:kv_cache_usage_perc' "$m")"
  [[ -n "$kv" ]] || kv="$(metric 'vllm:gpu_cache_usage_perc' "$m")"
  echo "$t,$gpu,$(metric 'vllm:num_requests_running' "$m"),$(metric 'vllm:num_requests_waiting' "$m"),$kv,$(metric 'vllm:num_preemptions_total' "$m"),$(metric 'vllm:prompt_tokens_total' "$m"),$(metric 'vllm:generation_tokens_total' "$m"),$(metric 'vllm:prefix_cache_queries_total' "$m"),$(metric 'vllm:prefix_cache_hits_total' "$m"),$(metric 'vllm:spec_decode_num_draft_tokens_total' "$m"),$(metric 'vllm:spec_decode_num_accepted_tokens_total' "$m")" >> "$OUT"
  sleep 1
done
