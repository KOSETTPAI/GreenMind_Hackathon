# 61. End-to-End Latency

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Streaming and SSE](60_Streaming_and_SSE.md)

## In one sentence
End-to-end latency is the time from the defined request start (usually arrival/send) to the defined end (last token / response complete).

## Plain-English explanation
It's the total time the user waits for the complete answer. For streamed LLM responses it decomposes as:

`E2E ≈ queue_time + prefill_time + (n_output − 1) × TPOT`

So E2E depends heavily on output length: a 1,000-token answer is slow even on a great server.

## Technical depth
- Components: network → HTTP parsing → template + tokenization → queue wait → prefill → decode steps → detokenization/streaming → network.
- Exact start/end events come from the grader (client send time? server receive time? last chunk? `[DONE]`?).
- E2E is less useful than TTFT/TPOT for SLOs because it confounds server speed with output length — but it matters for throughput and concurrency (Little's Law).
- Always analyze latency **distributions** (p50/p95/p99), not just averages.

## Backend-engineer analogy
Standard request latency — but for a streaming endpoint where response size varies by orders of magnitude.

## Why it matters for GreenMind
E2E latency per request determines how long each request occupies a slot, which drives concurrency, memory pressure, and energy.

## Common mistakes
- Comparing E2E across runs with different output lengths.
- Reporting only averages.

## Related concepts
[TTFT](62_TTFT.md) · [TPOT](63_TPOT.md) · [Percentiles](65_Percentiles_p50_p95_p99.md) · [Queueing](67_Queueing.md)
