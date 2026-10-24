# 110. FlashAttention

**Stage:** 8 | **Priority:** Should know | **Prerequisites:** [Attention](18_Attention.md), [Kernel Fusion](109_Kernel_Fusion.md)

## In one sentence
FlashAttention is an IO-aware attention algorithm that computes exact attention in tiles held in on-chip memory, never materializing the full attention matrix in HBM — reducing memory traffic and memory use.

## Plain-English explanation
Naive attention builds an `n × n` score matrix in GPU memory — huge for long contexts — then softmaxes it and multiplies by V. FlashAttention processes small blocks of Q, K, V at a time in fast SRAM, using an "online softmax" trick to combine partial results. Same answer, far less memory traffic.

## Technical depth
- FlashAttention-2 (Dao, 2023) is the main version on Ampere/A100. FlashAttention-3 targets Hopper (H100) features — not applicable to A100.
- Decode variants (paged attention / FlashDecoding / FlashInfer) handle one query token against a long paged KV cache, splitting across the sequence for parallelism.
- vLLM picks an attention backend automatically (e.g., FlashAttention, FlashInfer, Triton); selection can be overridden via env var/config depending on version — check logs.
- **Only accelerates attention layers.** In a hybrid model, Mamba/Gated-DeltaNet layers use entirely different kernels.

## Backend-engineer analogy
Streaming aggregation instead of materializing a giant intermediate join table.

## Why it matters for GreenMind
Matters for MANGO's attention layers (especially long-context prefill), but doesn't optimize recurrent layers. Don't expect attention-backend tweaks to fix recurrent-layer bottlenecks.

## Common mistakes
- Assuming FlashAttention optimizes Mamba/DeltaNet layers.
- Applying FlashAttention-3/H100 advice to the A100.

## Related concepts
[Attention](18_Attention.md) · [KV Cache](77_KV_Cache.md) · [Hybrid Model Architecture](85_Hybrid_Model_Architecture.md) · [Softmax](23_Softmax.md)
