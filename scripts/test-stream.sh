#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8000/v1}"
MODEL="${MODEL:-mango1.5-awq-w4a16}"

curl -fsS --no-buffer --max-time 120 \
  "$BASE_URL/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [
      {\"role\": \"user\", \"content\": \"Count from 1 to 5.\"}
    ],
    \"max_tokens\": 100,
    \"temperature\": 0,
    \"stream\": true,
    \"stream_options\": {\"include_usage\": true},
    \"chat_template_kwargs\": {\"enable_thinking\": false}
  }"
