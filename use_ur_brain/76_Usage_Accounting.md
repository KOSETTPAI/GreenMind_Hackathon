# 76. Usage Accounting

**Stage:** 3 | **Priority:** Should know | **Prerequisites:** [Prompt and Completion Tokens](27_Prompt_and_Completion_Tokens.md)

## In one sentence
Usage accounting is the reporting of token counts per request (`prompt_tokens`, `completion_tokens`, `total_tokens`), which graders and harnesses use to compute TPOT, throughput, and costs.

## Plain-English explanation
Every response can include:
```json
"usage": {"prompt_tokens": 1234, "completion_tokens": 256, "total_tokens": 1490}
```
The grader may use `completion_tokens` as the denominator for TPOT or for token throughput. If the count is missing or wrong, metrics are wrong.

## Technical depth
- Non-streaming responses include `usage` by default.
- Streaming: usage typically requires `stream_options: {"include_usage": true}`; it arrives in a final chunk.
- vLLM may also report cached prompt tokens (`prompt_tokens_details.cached_tokens`) when prefix caching is enabled.
- If the grader counts tokens itself (re-tokenizing the output), counts may differ slightly from server counts (e.g., special tokens, partial UTF-8).
- Engine swaps or custom proxies can drop or change usage fields.

## Backend-engineer analogy
Metering/billing records — if the meter is off, every derived metric (and invoice) is off.

## Why it matters for GreenMind
TPOT and token throughput depend on correct token counts. Verify usage fields in streaming mode match expectations.

## Common mistakes
- Assuming usage is present in streaming responses by default.
- Comparing token counts from different tokenizers.

## Related concepts
[TPOT](63_TPOT.md) · [Throughput](66_Throughput.md) · [Streaming and SSE](60_Streaming_and_SSE.md) · [OpenAI-Compatible API](72_OpenAI_Compatible_API.md)
