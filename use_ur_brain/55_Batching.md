# 55. Batching

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Decode](54_Decode.md)

## In one sentence
Batching processes multiple requests' tokens in the same forward pass so that expensive weight reads and kernel launches are shared.

## Plain-English explanation
If each decode step must read 18 GB of weights anyway, doing it for 1 request or 64 requests costs nearly the same time. Batching 64 requests gives ~64× the tokens for slightly more time per step. That's the core economics of LLM serving.

The trade-off: bigger batches make each individual step a bit slower (higher TPOT) and can increase waiting time for new requests.

## Technical depth
- **Static batching:** collect N requests, run them together until all finish. Short requests wait for long ones; padding wastes compute. Bad for mixed workloads.
- **Dynamic batching:** form batches from whatever's queued within a time window.
- **Continuous (iteration-level) batching:** see [Continuous Batching](56_Continuous_Batching.md) — the modern standard in vLLM/SGLang/TensorRT-LLM.
- Limits on batch size: KV cache/state memory, `max_num_seqs`, `max_num_batched_tokens`, TPOT SLO.
- Throughput vs latency curve: tokens/s rises with batch size then flattens (compute-bound); TPOT rises gradually then sharply.
- **Energy:** larger batches typically lower joules per token (power rises less than throughput).

## Backend-engineer analogy
Batch inserts vs row-by-row inserts, or request coalescing — amortize fixed per-operation costs.

## Why it matters for GreenMind
Batching is the biggest lever for throughput and energy per request, bounded by SLOs and memory.

## Common mistakes
- Maximizing batch size without watching TPOT/p95.
- Benchmarking with batch 1 and extrapolating.

## Related concepts
[Continuous Batching](56_Continuous_Batching.md) · [Max Active Sequences](94_Max_Active_Sequences.md) · [Batch Token Budget](93_Batch_Token_Budget.md) · [Arithmetic Intensity](38_Arithmetic_Intensity.md)
