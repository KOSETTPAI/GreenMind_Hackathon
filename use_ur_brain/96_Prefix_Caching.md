# 96. Prefix Caching

**Stage:** 6 / 8 | **Priority:** Must know | **Prerequisites:** [KV Cache](77_KV_Cache.md), [Recurrent State](79_Recurrent_State.md)

## In one sentence
Prefix caching reuses the computed cache/state for a prompt prefix that an earlier request already processed, skipping that part of prefill.

## Plain-English explanation
Many requests start the same way: same system prompt, same tool schemas, same RAG documents, same conversation history in multi-turn agents. If the engine kept the computed state for that shared beginning, the next request only needs to prefill the new part → much lower TTFT and less energy.

It helps **only** when prefixes are actually shared, token-for-token from the very start.

## Technical depth
- vLLM: `--enable-prefix-caching` (automatic prefix caching, APC; default-on in recent versions for standard models). Hashes KV blocks by content + all preceding tokens; matching blocks are reused, LRU-evicted when memory is needed.
- **Attention layers:** reuse at block granularity (e.g., every 16 tokens).
- **Recurrent layers (Mamba/DeltaNet):** state exists only at saved positions; prefix caching requires storing state snapshots at block boundaries — supported for some hybrid models in newer vLLM versions, sometimes experimental or auto-disabled. **Verify in logs and by measuring cached tokens.**
- Metrics: prefix cache hit rate in `/metrics`; `usage.prompt_tokens_details.cached_tokens`.
- Costs: hashing/lookup overhead, cache memory held by idle prefixes, possible interference.

## Backend-engineer analogy
Memoizing expensive computations keyed by input prefix — like HTTP caching of a shared upstream response, or a query result cache.

## Why it matters for GreenMind
Agentic multi-turn and RAG workloads with shared system prompts are prime candidates. Roadmap experiment #4.

## Common mistakes
- Enabling it and assuming it works for hybrid layers without measuring hit rate.
- Expecting benefits when prefixes differ (e.g., timestamps at the start of the system prompt).

## Related concepts
[Agentic Workloads](74_Agentic_Workloads_and_Multi_Turn.md) · [RAG](75_RAG.md) · [Hybrid Cache and Architecture-Specific Kernels](86_Hybrid_Cache_and_Architecture_Specific_Kernels.md) · [TTFT](62_TTFT.md)
