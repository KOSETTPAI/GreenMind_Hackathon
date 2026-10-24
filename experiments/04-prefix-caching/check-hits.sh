#!/usr/bin/env bash
# Three requests with one shared prefix. Submit E4 only when a prefix-cache hit counter increases.
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8000/v1}"
METRICS_URL="${METRICS_URL:-http://127.0.0.1:8000/metrics}"
MODEL="${MODEL:-mango1.5-awq-w4a16}"

die() {
  echo "$*" >&2
  exit 1
}

command -v docker >/dev/null 2>&1 || die "docker is not on PATH."
command -v curl >/dev/null 2>&1 || die "curl is not on PATH."
command -v awk >/dev/null 2>&1 || die "awk is not on PATH."

cmd="$(docker inspect --format '{{json .Config.Cmd}}' mango-vllm)" || die "Container mango-vllm is not running."
case "$cmd" in
  *enable-prefix-caching*) ;;
  *) die "mango-vllm is missing --enable-prefix-caching. Do not submit it as the prefix-cache experiment." ;;
esac
case "$cmd" in
  *mamba-cache-mode*align*) ;;
  *) die "mango-vllm is missing --mamba-cache-mode align. Do not submit it as the prefix-cache experiment." ;;
esac

sum_hits() {
  awk '
    $1 ~ /prefix_cache_hits/ && $1 !~ /_bucket/ && $1 !~ /_created/ && $2 ~ /^[0-9]+([.][0-9]+)?$/ {
      s += $2
    }
    END { print s + 0 }
  '
}

metrics="$(curl -fsS --max-time 15 "$METRICS_URL")" || die "Cannot read ${METRICS_URL}."
before="$(printf '%s\n' "$metrics" | sum_hits)"
printf '%s\n' "$metrics" | awk '$0 ~ /prefix_cache/ { print }' || true
echo "Hit counter sum before probe: ${before}"

prefix="$(printf 'greenmind-prefix-block %.0s' {1..1200})"
body_dir="$(mktemp -d)"
trap 'rm -rf "$body_dir"' EXIT

cat > "$body_dir/turn1.json" <<EOF
{"model":"${MODEL}","messages":[{"role":"user","content":"${prefix}Reply with the single word ok."}],"max_tokens":32,"temperature":0,"stream":false,"chat_template_kwargs":{"enable_thinking":false}}
EOF
cat > "$body_dir/turn2.json" <<EOF
{"model":"${MODEL}","messages":[{"role":"user","content":"${prefix}Reply with the single word ok."},{"role":"assistant","content":"ok"},{"role":"user","content":"What is the first word of the repeated phrase?"}],"max_tokens":32,"temperature":0,"stream":false,"chat_template_kwargs":{"enable_thinking":false}}
EOF
cat > "$body_dir/turn3.json" <<EOF
{"model":"${MODEL}","messages":[{"role":"user","content":"${prefix}Reply with the single word ok."},{"role":"assistant","content":"ok"},{"role":"user","content":"What is the first word of the repeated phrase?"},{"role":"assistant","content":"greenmind-prefix-block"},{"role":"user","content":"Repeat that word once."}],"max_tokens":32,"temperature":0,"stream":false,"chat_template_kwargs":{"enable_thinking":false}}
EOF

for turn in turn1 turn2 turn3; do
  echo "== ${turn} =="
  curl -fsS --max-time 180 "$BASE_URL/chat/completions" \
    -H "Content-Type: application/json" \
    --data-binary @"$body_dir/${turn}.json"
  echo
done

metrics="$(curl -fsS --max-time 15 "$METRICS_URL")" || die "Cannot read ${METRICS_URL} after the probe."
after="$(printf '%s\n' "$metrics" | sum_hits)"
echo "Hit counter sum after probe: ${after}"

awk -v before="$before" -v after="$after" 'BEGIN { exit !(after > before) }' \
  || die "No prefix-cache hit increase. Read the startup log. If prefix caching disabled itself, do not submit."

echo "Prefix-cache hit counter increased. Inspect accuracy before Submit. The grader enables thinking, so graded hit rate can differ from this probe."
