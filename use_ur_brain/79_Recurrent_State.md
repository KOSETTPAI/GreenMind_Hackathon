# 79. Recurrent State

**Stage:** 4 | **Priority:** Must know | **Prerequisites:** [State-Space Models](78_State_Space_Models_SSM.md)

## In one sentence
Recurrent state is the fixed-size per-sequence memory that recurrent/linear layers (Mamba, Gated DeltaNet) carry from one token to the next, replacing a growing KV cache.

## Plain-English explanation
For attention layers, per-request memory grows with every token (KV cache). For recurrent layers, each request has a fixed-size "notebook" that's overwritten each step. 10 tokens or 100,000 tokens → same size.

## Technical depth
- **Contents:** for Mamba-style layers — SSM state (`d_inner × d_state` per layer) + conv state (last few inputs). For Gated DeltaNet — a matrix memory per head (`d_k × d_v`) + conv state.
- **Size** is per sequence, per recurrent layer, independent of context length. It can still be large in absolute terms (e.g., hundreds of KB to a few MB per sequence across all layers) and may be stored in FP32 for stability — compute from `config.json` and engine logs.
- **Lifecycle:** allocated at admission, updated in place each step, freed at completion.
- **Prefix caching implications:** a KV cache can be reused for any prefix length (blocks are per-token), but recurrent state only exists for the *exact* positions where it was saved — so prefix caching for recurrent layers requires checkpointing state at specific boundaries. Engine support varies.
- **Preemption:** recompute-based preemption must re-run prefill to rebuild state.

## Backend-engineer analogy
A fixed-size session object (counters/aggregates) vs an append-only session log. Cheap to keep, but you can't rewind it to an arbitrary earlier point unless you snapshotted it.

## Why it matters for GreenMind
Memory planning for MANGO = (weights) + (KV cache for attention layers, grows with context) + (recurrent state slots, fixed per sequence). Max concurrency may be limited by state slots, not just KV blocks.

## Common mistakes
- Assuming recurrent state is negligible.
- Assuming prefix caching works identically for recurrent layers.

## Related concepts
[KV Cache](77_KV_Cache.md) · [Gated DeltaNet](84_Gated_DeltaNet.md) · [Hybrid Cache and Architecture-Specific Kernels](86_Hybrid_Cache_and_Architecture_Specific_Kernels.md) · [Prefix Caching](96_Prefix_Caching.md)
