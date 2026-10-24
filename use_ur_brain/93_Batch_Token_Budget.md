# 93. Batch Token Budget (`max_num_batched_tokens`)

**Stage:** 6 — Low-risk serving optimizations | **Priority:** Must know | **Prerequisites:** [Continuous Batching](56_Continuous_Batching.md), [Prefill](53_Prefill.md)

## In one sentence
The batch token budget caps how many tokens (decode tokens + prefill chunk tokens) the engine processes in a single step.

## Plain-English explanation
Every step, the scheduler fills a "token bucket": first one token for each running decode sequence, then prompt tokens from waiting requests until the bucket is full.
- **Bigger budget:** prompts get prefilled faster → lower TTFT, higher peak throughput — but each step takes longer → decode streams stutter (higher TPOT/ITL).
- **Smaller budget:** steps stay short → smooth TPOT — but long prompts take many steps → higher TTFT.

## Technical depth
- vLLM flag: `--max-num-batched-tokens N`. Default depends on version and hardware (with chunked prefill on, often a few thousand tokens for online serving).
- Must be ≥ `max_num_seqs` (each running sequence needs one token per step) — and if chunked prefill is off, ≥ `max_model_len`.
- Step time grows roughly linearly with tokens once compute-bound; e.g., a 8k-token step might take ~100+ ms on a 9B model → every decode stream in that step gets that ITL.
- Tune with a sweep (e.g., 2048, 4096, 8192, 16384) under the real mixed workload; plot TTFT p95, TPOT p95, throughput, energy.
- vLLM's docs describe this as the main TTFT/ITL trade-off knob with chunked prefill.

## Backend-engineer analogy
The max batch size / time slice of a work-conserving scheduler — larger slices improve throughput, smaller slices improve responsiveness.

## Why it matters for GreenMind
Item #2 in the roadmap's experiment queue: likely the single highest-value low-risk knob.

## Common mistakes
- Changing it together with other flags.
- Tuning on a single prompt instead of the mixed workload.

## Related concepts
[Chunked Prefill](95_Chunked_Prefill.md) · [Max Active Sequences](94_Max_Active_Sequences.md) · [TTFT](62_TTFT.md) · [TPOT](63_TPOT.md) · [ITL](64_ITL.md)
