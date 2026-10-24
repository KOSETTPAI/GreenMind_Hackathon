# 60. Streaming and SSE (Server-Sent Events)

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Decode](54_Decode.md)

## In one sentence
Streaming sends generated tokens to the client incrementally (as SSE chunks) instead of waiting for the full response, which is what makes TTFT and TPOT observable.

## Plain-English explanation
With `"stream": true`, the server returns an HTTP response with `Content-Type: text/event-stream` and writes lines like:
```
data: {"choices":[{"delta":{"content":"Hel"}}]}
data: {"choices":[{"delta":{"content":"lo"}}]}
data: [DONE]
```
The client sees the first chunk at TTFT and subsequent chunks at roughly ITL intervals.

## Technical depth
- Chunk boundaries don't always align with tokens: detokenization may hold back partial UTF-8 characters (common with Thai) or stop-string candidates.
- **Tool calls stream** as `delta.tool_calls` with incremental JSON arguments; the parser must reassemble them.
- Final usage stats: `stream_options: {"include_usage": true}` adds a last chunk with token counts.
- First chunk might be a role-only delta (`{"role":"assistant"}`) — the grader's TTFT definition decides whether that counts as the "first token."
- Many concurrent streams → CPU cost for detokenization + JSON serialization per token.

## Backend-engineer analogy
Chunked transfer encoding / long-lived streaming responses. Time-to-first-byte vs time-to-last-byte.

## Why it matters for GreenMind
The grader likely measures TTFT/TPOT from streamed chunks, and tool-call correctness includes correct streamed chunk semantics. API compatibility does not guarantee identical streaming behavior across engines.

## Common mistakes
- Testing only non-streaming responses.
- Assuming one chunk = one token.

## Related concepts
[TTFT](62_TTFT.md) · [ITL](64_ITL.md) · [Tool Calling](73_Tool_Calling.md) · [OpenAI-Compatible API](72_OpenAI_Compatible_API.md) · [Usage Accounting](76_Usage_Accounting.md)
