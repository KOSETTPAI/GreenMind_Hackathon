# 77. KV Cache

**Stage:** 3 / 4 / 8 | **Priority:** Must know | **Prerequisites:** [Attention](18_Attention.md), [Decode](54_Decode.md)

## In one sentence
The KV cache stores the attention keys and values computed for all previous tokens so each decode step only computes K/V for the new token instead of recomputing the whole history.

## Plain-English explanation
Without a cache, generating token 1,001 would mean re-processing tokens 1–1,000. With it, you save each token's K and V once and reuse them. The price: memory that grows with every token, for every concurrent sequence, in every attention layer.

## Technical depth
- **Size per token** = `2 (K,V) × n_attention_layers × n_kv_heads × head_dim × bytes`.
- Example (illustrative): 8 attention layers × 4 KV heads × 256 head_dim × 2 bytes × 2 = 32 KB/token → 32k tokens ≈ 1 GB per sequence. A pure Transformer with 36 attention layers would need ~4.5× more. (Compute yours from `config.json`.)
- **PagedAttention (vLLM):** allocates KV in fixed-size blocks (e.g., 16 tokens) from a global pool, like virtual-memory pages → little fragmentation, enables sharing for prefix caching.
- **Hybrid models:** only the attention layers have a KV cache; Mamba/Gated-DeltaNet layers keep a fixed-size recurrent state instead. vLLM manages both in its hybrid cache manager.
- **KV cache quantization** (`--kv-cache-dtype fp8`) halves cache memory; check accuracy and A100/hybrid support.
- Running out of cache → [Preemption](97_Preemption.md).

## Backend-engineer analogy
Per-session memoization cache: avoid recomputation at the cost of memory proportional to session length.

## Why it matters for GreenMind
Cache capacity sets maximum concurrency and context length. In MANGO's hybrid design the KV cache is smaller than in a pure Transformer, which shifts where memory pressure comes from — verify with actual config.

## Common mistakes
- Assuming every layer has a KV cache.
- Using pure-Transformer KV formulas for the hybrid model.

## Related concepts
[Recurrent State](79_Recurrent_State.md) · [Hybrid Cache and Architecture-Specific Kernels](86_Hybrid_Cache_and_Architecture_Specific_Kernels.md) · [Prefix Caching](96_Prefix_Caching.md) · [Preemption](97_Preemption.md) · [GPU Memory Allocation](101_GPU_Memory_Allocation.md)
