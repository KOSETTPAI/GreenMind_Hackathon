#!/usr/bin/env bash
# Sample GPU power/utilization and vLLM scheduler metrics once per interval
# into a CSV, until Ctrl-C. Read-only: it queries nvidia-smi and GET /metrics,
# changes no GPU setting, and runs no GPU work. Use it during Validation runs
# to find GPU idle gaps while requests are running.
#
# Usage: experiments_thyme/scripts/telemetry.sh <out.csv> [interval_s] [metrics_url]
# Then:  python3 experiments_thyme/scripts/summarize_telemetry.py <out.csv>
set -euo pipefail

OUT="${1:?usage: $0 <out.csv> [interval_s] [metrics_url]}"
INTERVAL="${2:-1}"
METRICS_URL="${3:-http://127.0.0.1:8000/metrics}"

# Sum all label variants of one Prometheus metric; prints nothing if absent.
metric() {
  awk -v m="$1" '
    index($0, m) == 1 {
      c = substr($0, length(m) + 1, 1)
      if (c == "{" || c == " ") { s += $NF; found = 1 }
    }
    END { if (found) printf "%s", s }' <<<"$2"
}

echo "t,power_w,util_pct,sm_clock_mhz,mem_used_mib,running,waiting,kv_cache_usage,preemptions_total,prompt_tokens_total,generation_tokens_total,spec_draft_tokens_total,spec_accepted_tokens_total" > "$OUT"
trap 'echo; echo "Stopped. Wrote $OUT"; exit 0' INT TERM

echo "Sampling every ${INTERVAL}s into $OUT (Ctrl-C to stop)"
while true; do
  t="$(date +%s.%N)"
  gpu="$(nvidia-smi -i 0 --query-gpu=power.draw,utilization.gpu,clocks.sm,memory.used --format=csv,noheader,nounits | tr -d ' ')"
  m="$(curl -s -m 2 "$METRICS_URL" || true)"
  kv="$(metric 'vllm:kv_cache_usage_perc' "$m")"
  [[ -n "$kv" ]] || kv="$(metric 'vllm:gpu_cache_usage_perc' "$m")"
  echo "$t,$gpu,$(metric 'vllm:num_requests_running' "$m"),$(metric 'vllm:num_requests_waiting' "$m"),$kv,$(metric 'vllm:num_preemptions_total' "$m"),$(metric 'vllm:prompt_tokens_total' "$m"),$(metric 'vllm:generation_tokens_total' "$m"),$(metric 'vllm:spec_decode_num_draft_tokens_total' "$m"),$(metric 'vllm:spec_decode_num_accepted_tokens_total' "$m")" >> "$OUT"
  sleep "$INTERVAL"
done
