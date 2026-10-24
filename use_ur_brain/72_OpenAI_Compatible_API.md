# 72. OpenAI-Compatible API

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Streaming and SSE](60_Streaming_and_SSE.md)

## In one sentence
An OpenAI-compatible API implements the same HTTP request/response schema as OpenAI's API (e.g., `POST /v1/chat/completions`), so standard clients work against your server — but "compatible" rarely means identical in every field and behavior.

## Plain-English explanation
The grader talks to your server like it talks to OpenAI:
```json
POST /v1/chat/completions
{"model": "...", "messages": [...], "stream": true, "tools": [...], "max_tokens": 512, "temperature": 0}
```
vLLM, SGLang, TensorRT-LLM (via its server), and llama.cpp all offer such endpoints, but they differ in edge cases: tool-call streaming, `usage` reporting, error formats, supported parameters, stop handling.

## Technical depth
- Key endpoints: `/v1/chat/completions`, `/v1/completions`, `/v1/models`, `/health`, `/metrics`.
- Fields to verify: `model` name matching (`--served-model-name`), `tools`/`tool_choice`, `stream_options.include_usage`, `stop`, `seed`, `logprobs`, `response_format`, `finish_reason` values (`stop`, `length`, `tool_calls`).
- Errors: HTTP status codes and JSON error bodies for invalid requests/too-long contexts.
- Unknown parameters: some servers reject, others ignore — test the grader's exact payloads.

## Backend-engineer analogy
Implementing an S3-compatible API: basic operations work everywhere, but edge semantics differ by vendor and break clients in subtle ways.

## Why it matters for GreenMind
API correctness is likely a gate. Before swapping engines or adding proxies, verify byte-level behavior on the grader's real request types.

## Common mistakes
- Assuming API compatibility guarantees correct streaming/tool calling.
- Testing only non-streaming plain chat.

## Related concepts
[Tool Calling](73_Tool_Calling.md) · [Streaming and SSE](60_Streaming_and_SSE.md) · [Usage Accounting](76_Usage_Accounting.md) · [Engine Migration Gate](117_Engine_Migration_Gate.md)
