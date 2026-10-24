# 73. Tool Calling

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Chat Templates](28_Chat_Templates.md), [OpenAI-Compatible API](72_OpenAI_Compatible_API.md)

## In one sentence
Tool calling is when the model outputs a structured request to call an external function (name + JSON arguments), returned in the API's `tool_calls` field rather than as prose.

## Plain-English explanation
The client sends tool definitions (JSON Schemas). The model decides to call one and emits special tokens + JSON. The server's **tool-call parser** extracts it into:
```json
"tool_calls": [{"id": "call_1", "type": "function",
  "function": {"name": "get_weather", "arguments": "{\"city\": \"Bangkok\"}"}}]
```
with `finish_reason: "tool_calls"`. The client runs the tool and sends the result back as a `role: "tool"` message.

Correctness = right tool, valid JSON matching the schema, correct API structure — not just "mentions the tool in text."

## Technical depth
- vLLM flags: `--enable-auto-tool-choice --tool-call-parser <parser>` (parser must match the model family's format, e.g., `hermes` or a Qwen-specific parser — check the model card/vLLM docs).
- Streaming tool calls emit incremental argument deltas — grader must reassemble.
- `tool_choice: "required"` or a named tool may use guided/structured decoding (logit masking) → extra overhead.
- Tool schemas inflate prompt tokens; multi-turn tool sessions repeat them → prefix caching opportunity.
- Quantization can degrade JSON validity and argument accuracy more than plain chat quality.

## Backend-engineer analogy
The model is producing an RPC request; the parser is the deserializer. A malformed payload is a failed request, regardless of intent.

## Why it matters for GreenMind
Agentic tool-call requests are part of the workload; malformed tool calls likely fail the useful-request conditions.

## Common mistakes
- Testing tool calls only non-streaming.
- Wrong parser for the model → tool calls appear as plain text.

## Related concepts
[Agentic Workloads](74_Agentic_Workloads_and_Multi_Turn.md) · [Chat Templates](28_Chat_Templates.md) · [Streaming and SSE](60_Streaming_and_SSE.md) · [Logits](22_Logits.md)
