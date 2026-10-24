# 54. Decode

**Stage:** 3 | **Priority:** Must know | **Prerequisites:** [Prefill](53_Prefill.md), [Memory Bandwidth](34_Memory_Bandwidth.md)

## In one sentence
Decode is the iterative phase after prefill that generates output tokens one step at a time, each step reading the model weights and the per-request state.

## Plain-English explanation
Each decode step produces one new token per active sequence. At small batch sizes, each step mostly waits for weights to stream from memory — the GPU's math units are underused. That's why batching many sequences into the same step is the main throughput lever. Decode time per token determines **TPOT/ITL**.

## Technical depth
- Per step cost ≈ `max(weight_bytes / BW, FLOPs / peak) + state/cache reads + overhead`.
- Batch 1, BF16 9B: ≥ ~11.6 ms/step (bandwidth floor).
- Increasing batch B: weight read amortized over B tokens → throughput rises nearly linearly until compute- or cache-bound; per-request TPOT rises slowly.
- **Attention layers:** each step reads the whole KV cache for that sequence (grows with context).
- **Recurrent layers (Mamba/Gated DeltaNet):** each step reads/updates a fixed-size state — constant cost per token regardless of context length.
- Overhead-bound at small batch without CUDA graphs.

## Backend-engineer analogy
A streaming response loop where each tick requires a full table scan; you make it efficient by serving many clients per scan.

## Why it matters for GreenMind
Chat, reasoning, and coding outputs are decode-heavy. Decode efficiency drives TPOT SLOs, throughput, and most of the energy for long outputs.

## Common mistakes
- Confusing per-request tokens/s with aggregate tokens/s.
- Over-batching until TPOT violates the SLO.

## Related concepts
[Batching](55_Batching.md) · [Continuous Batching](56_Continuous_Batching.md) · [TPOT](63_TPOT.md) · [Speculative Decoding](111_Speculative_Decoding.md) · [Recurrent State](79_Recurrent_State.md)
