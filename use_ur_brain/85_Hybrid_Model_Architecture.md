# 85. Hybrid Model Architecture

**Stage:** 4 | **Priority:** Must know | **Prerequisites:** [Attention](18_Attention.md), [Gated DeltaNet](84_Gated_DeltaNet.md), [Mamba](80_Mamba_Selective_State_Update.md)

## In one sentence
A hybrid model stacks different layer families — e.g., mostly recurrent/linear-attention layers plus a few full-attention layers — to balance efficiency and exact-recall ability.

## Plain-English explanation
Recurrent layers are cheap and constant-memory but can blur details; full attention layers are expensive but remember precisely. A hybrid uses many cheap layers and sprinkles in a few attention layers (e.g., 3 linear : 1 attention) so the model can still look up exact facts from the context.

## Technical depth
- Layer layout is defined in `config.json` (e.g., a per-layer type list or an interval like "full attention every N layers"). **Inspect it** for MANGO.
- Per-request memory = KV cache (attention layers only, grows with context) + recurrent/conv state (other layers, fixed).
- Each layer type needs its own kernels and cache handling → serving engines need explicit support ("hybrid-aware" cache managers).
- Optimizations apply per layer family:
  | Optimization | Attention layers | Recurrent layers |
  |---|---|---|
  | FlashAttention backends | yes | no |
  | KV cache quantization | yes | no (state precision separate) |
  | Prefix caching | standard | needs state checkpoints |
  | Weight quantization | yes | yes (if kernels support layer) |
  | CUDA graphs | yes | yes (if implementation supports) |
- Speculative decoding with recurrent layers is harder: rejected draft tokens require rolling back state.

## Backend-engineer analogy
A tiered storage system: mostly cheap compact summaries plus a few full indexes. Tooling built for one tier doesn't automatically manage the other.

## Why it matters for GreenMind
Generic Transformer advice may not transfer. Confirm layer types, engine support, and which optimizations touch which layers before investing effort.

## Exercise
From `config.json`, list each layer's type; count attention vs recurrent layers; compute KV bytes/token and recurrent state bytes/sequence.

## Common mistakes
- Assuming every layer uses attention.
- Transferring Transformer kernel optimizations without verifying compatibility.

## Related concepts
[Hybrid Cache and Architecture-Specific Kernels](86_Hybrid_Cache_and_Architecture_Specific_Kernels.md) · [KV Cache](77_KV_Cache.md) · [Recurrent State](79_Recurrent_State.md) · [Engine Migration Gate](117_Engine_Migration_Gate.md)
