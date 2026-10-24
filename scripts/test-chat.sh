#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8000/v1}"
MODEL="${MODEL:-mango1.5-awq-w4a16}"

curl -fsS --max-time 120 \
  "$BASE_URL/chat/completions" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$MODEL\",
    \"messages\": [
      {\"role\": \"user\", \"content\": \"What is 2 + 2? Answer briefly.\"}
    ],
    \"max_tokens\": 256,
    \"temperature\": 0,
    \"stream\": false,
    \"chat_template_kwargs\": {\"enable_thinking\": false}
  }"

echo
