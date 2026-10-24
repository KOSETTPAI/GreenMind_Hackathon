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
      {
        \"role\": \"user\",
        \"content\": \"What is the weather in Bangkok? Use the get_weather tool.\"
      }
    ],
    \"tools\": [
      {
        \"type\": \"function\",
        \"function\": {
          \"name\": \"get_weather\",
          \"description\": \"Get the current weather for a city.\",
          \"parameters\": {
            \"type\": \"object\",
            \"properties\": {
              \"city\": {\"type\": \"string\"}
            },
            \"required\": [\"city\"]
          }
        }
      }
    ],
    \"tool_choice\": \"auto\",
    \"temperature\": 0,
    \"max_tokens\": 256
  }"

echo
