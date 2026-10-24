# 88. Smoke Testing

**Stage:** 5 / 10 | **Priority:** Must know | **Prerequisites:** [OpenAI-Compatible API](72_OpenAI_Compatible_API.md)

## In one sentence
A smoke test is a fast, small check that the server works end-to-end on every request type before running expensive benchmarks.

## Plain-English explanation
Before a 30-minute benchmark, spend 1 minute confirming nothing is obviously broken. A broken tool-call parser or a context limit that's too small will ruin the whole run — catch it first.

## Technical depth
**Minimum smoke suite (run after every config change):**
1. Basic chat (non-streaming) — response sane, `usage` present.
2. Streaming chat — chunks arrive, `[DONE]`, usage with `include_usage`.
3. Tool call (streaming and non-streaming) — valid `tool_calls`, `finish_reason: "tool_calls"`.
4. Multi-turn with a tool result message.
5. Thai prompt — correct characters in streamed output.
6. Long prompt near the grader's max context — no error, reasonable TTFT.
7. Long output (hits `max_tokens`) — `finish_reason: "length"`.
8. Invalid request (too long / bad params) — proper error response.
9. Client disconnect mid-stream — server aborts.

Automate as a script that exits non-zero on failure; compare outputs to stored baseline outputs with greedy decoding for quick diffing.

## Backend-engineer analogy
Post-deploy smoke tests / health checks before routing traffic.

## Why it matters for GreenMind
Many failure modes (template mismatch, parser, quantization breaking JSON) show up instantly in a smoke test and would otherwise waste a full validation run or a limited submission.

## Common mistakes
- Skipping smoke tests "because it's just a flag change."
- Only testing plain chat.

## Related concepts
[Measurement Harness](89_Measurement_Harness.md) · [Tool Calling](73_Tool_Calling.md) · [Submission Discipline](128_Submission_Discipline.md) · [Controlled Experiments](127_Controlled_Experiments.md)
