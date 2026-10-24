# 95. Chunked Prefill

**Stage:** 6 | **Priority:** Must know | **Prerequisites:** [Prefill](53_Prefill.md), [Batch Token Budget](93_Batch_Token_Budget.md)

## In one sentence
Chunked prefill splits a long prompt's prefill into smaller pieces that are processed across several steps, mixed with other requests' decode tokens.

## Plain-English explanation
Without chunking, a 30,000-token RAG prompt is prefilled in one giant step — every streaming user freezes until it finishes. With chunking, that prompt is processed 2,000–8,000 tokens at a time, and each step still advances everyone else's decode by one token. Users see smooth streaming; the long request's TTFT gets a bit longer.

## Technical depth
- vLLM: `--enable-chunked-prefill` (enabled by default in recent versions/V1 engine); chunk size governed by `--max-num-batched-tokens`.
- Scheduler prioritizes decode tokens first, then fills the remaining budget with prefill chunks.
- Benefits: lower ITL/TPOT spikes, better GPU utilization (mixes compute-bound prefill with memory-bound decode in one step), better p95.
- Costs: slightly higher TTFT for long prompts; for recurrent layers, state is carried between chunks (needs kernel support — the chunked scan handles this naturally, but verify for your model/engine version).
- vLLM docs: chunked prefill "balances prefill and decode workloads."

## Backend-engineer analogy
Breaking a large batch job into time slices so it doesn't starve interactive requests — cooperative multitasking.

## Why it matters for GreenMind
Mixed workload (RAG + long-context + chat) is exactly where unchunked prefills cause TPOT and p95 violations. Check it's on and tune the chunk/budget size.

## Common mistakes
- Assuming it's enabled without checking logs.
- Setting the token budget so small that long-context TTFT breaks its SLO.

## Related concepts
[Batch Token Budget](93_Batch_Token_Budget.md) · [ITL](64_ITL.md) · [RAG](75_RAG.md) · [Scheduler and Request Queue](57_Scheduler_and_Request_Queue.md)
