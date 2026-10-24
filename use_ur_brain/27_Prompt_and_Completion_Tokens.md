# 27. Prompt and Completion Tokens

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Context Window](26_Context_Window.md)

## In one sentence
Prompt (input) tokens are what you send; completion (output) tokens are what the model generates — and they have very different costs.

## Plain-English explanation
- **Prompt tokens** are processed all at once in [Prefill](53_Prefill.md). Many tokens, highly parallel, good GPU efficiency per token. They mostly affect **TTFT**.
- **Completion tokens** are generated one at a time in [Decode](54_Decode.md). Each one is a sequential step. They affect **TPOT, end-to-end latency, and energy**.

Rough intuition: one output token is much more expensive per token than one input token, though exact ratios depend on batch size and hardware.

## Technical depth
- OpenAI-style responses return `usage: {prompt_tokens, completion_tokens, total_tokens}`; with streaming, usage often requires `stream_options: {"include_usage": true}`.
- The chat template adds hidden prompt tokens (role markers, system prompt, tool schemas) — a tool-heavy request may carry hundreds of template/schema tokens.
- Reasoning models may emit "thinking" tokens that count as completion tokens.
- Per-request cost model: `T ≈ T_queue + T_prefill(n_in) + n_out × TPOT`.

## Backend-engineer analogy
Upload vs streaming download: a big upload is processed in bulk; a long download trickles out chunk by chunk and occupies the connection for longer.

## Why it matters for GreenMind
Your diagnostics should split requests by prompt length and output length. High TTFT points to prefill/queueing; high TPOT points to decode/batching.

## Common mistakes
- Confusing tokens/sec of input processing with output tokens/sec.
- Forgetting template and tool-schema tokens in prompt-length estimates.

## Related concepts
[Usage Accounting](76_Usage_Accounting.md) · [TTFT](62_TTFT.md) · [TPOT](63_TPOT.md) · [Chat Templates](28_Chat_Templates.md)
