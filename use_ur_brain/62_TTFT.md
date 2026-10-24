# 62. TTFT (Time to First Token)

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Prefill](53_Prefill.md), [Streaming and SSE](60_Streaming_and_SSE.md)

## In one sentence
TTFT is the time from request start to the first generated token reaching the client.

## Plain-English explanation
It's "how long until the user sees something." TTFT = waiting in line + reading the prompt (prefill) + producing the first token + overheads.

## Technical depth
- `TTFT = t_first_token − t_request_start` (exact events per grader definition — e.g., does a role-only first chunk count?).
- Decomposition: `TTFT ≈ network + preprocessing (template, tokenize) + queue_wait + prefill (+ chunked prefill interleaving) + first sample + stream flush`.
- **Drivers:** prompt length (RAG/long-context), arrival bursts (queueing), long prefills ahead in the queue, CPU tokenization load, small `max_num_batched_tokens` (prefill split into many chunks).
- **Levers:** prefix caching (skip shared-prefix prefill), larger batch token budget, scheduling policy, reducing queue time via efficiency, CPU worker capacity.
- **Trade-off:** prioritizing prefills improves TTFT but can hurt TPOT of running requests.

## Backend-engineer analogy
Time to first byte (TTFB).

## Exercise
Send a 100-token and a 10,000-token prompt with `max_tokens=1`, at idle and under load. Compare TTFT; estimate prefill throughput (tokens/s).

## Why it matters for GreenMind
Likely one of the request-level SLO conditions. Long-context and RAG categories are most at risk.

## Common mistakes
- Not separating queue time from prefill time.
- Optimizing average TTFT while p95 violates the SLO.

## Related concepts
[TPOT](63_TPOT.md) · [Prefill](53_Prefill.md) · [Chunked Prefill](95_Chunked_Prefill.md) · [Prefix Caching](96_Prefix_Caching.md) · [SLO](11_SLO.md)
