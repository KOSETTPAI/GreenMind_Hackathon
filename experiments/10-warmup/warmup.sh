#!/usr/bin/env bash
# Compile and graph warmup before Submit. Does not change server flags or the power cap.
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8000/v1}"
MODEL="${MODEL:-mango1.5-awq-w4a16}"

die() {
  echo "$*" >&2
  exit 1
}

command -v curl >/dev/null 2>&1 || die "curl is not on PATH."

post() {
  local name="$1"
  local file="$2"
  echo "== ${name} =="
  curl -fsS --no-buffer --max-time 180 \
    "$BASE_URL/chat/completions" \
    -H "Content-Type: application/json" \
    --data-binary @"$file"
  echo
}

body_dir="$(mktemp -d)"
trap 'rm -rf "$body_dir"' EXIT

cat > "$body_dir/thinking.json" <<EOF
{"model":"${MODEL}","messages":[{"role":"user","content":"What is 2 + 2? Answer briefly."}],"max_tokens":256,"temperature":0,"stream":true,"stream_options":{"include_usage":true},"chat_template_kwargs":{"enable_thinking":true}}
EOF

cat > "$body_dir/thai.json" <<EOF
{"model":"${MODEL}","messages":[{"role":"user","content":"สวัสดี ช่วยตอบสั้นๆ ว่า 2+2 เท่ากับเท่าไร"}],"max_tokens":256,"temperature":0,"stream":true,"stream_options":{"include_usage":true},"chat_template_kwargs":{"enable_thinking":true}}
EOF

cat > "$body_dir/tool.json" <<EOF
{"model":"${MODEL}","messages":[{"role":"user","content":"What is the weather in Bangkok? Use the get_weather tool."}],"tools":[{"type":"function","function":{"name":"get_weather","description":"Get the current weather for a city.","parameters":{"type":"object","properties":{"city":{"type":"string"}},"required":["city"]}}}],"tool_choice":"auto","temperature":0,"max_tokens":2048,"stream":true,"stream_options":{"include_usage":true},"chat_template_kwargs":{"enable_thinking":true}}
EOF

post "thinking stream" "$body_dir/thinking.json"
post "thai stream" "$body_dir/thai.json"
echo "== tool stream =="
curl -fsS --no-buffer --max-time 180 \
  "$BASE_URL/chat/completions" \
  -H "Content-Type: application/json" \
  --data-binary @"$body_dir/tool.json" \
  --output "$body_dir/tool.out"
cat "$body_dir/tool.out"
echo
if ! grep -q 'tool_calls' "$body_dir/tool.out"; then
  die "The thinking-on tool stream did not contain tool_calls. Run bash scripts/test-tool-calling.sh and inspect this output before Submit."
fi

if [[ "${WARMUP_LONG:-}" == "1" ]]; then
  long="$(printf 'context %.0s' {1..20000})"
  cat > "$body_dir/long.json" <<EOF
{"model":"${MODEL}","messages":[{"role":"user","content":"${long}"}],"max_tokens":8,"temperature":0,"stream":true,"stream_options":{"include_usage":true},"chat_template_kwargs":{"enable_thinking":true}}
EOF
  post "long prefill" "$body_dir/long.json"
fi

echo
echo "Warmup requests finished. Submit only if these responses and bash scripts/test-tool-calling.sh look valid."
echo "Run warmup before the grader window. If the energy counter includes this traffic, record that in experiments/log.md and skip WARMUP_LONG."
