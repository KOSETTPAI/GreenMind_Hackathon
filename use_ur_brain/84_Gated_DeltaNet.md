# 84. Gated DeltaNet

**Stage:** 4 | **Priority:** Must know (high level) | **Prerequisites:** [Delta Rule](82_Delta_Rule.md), [Gating](83_Gating.md)

## In one sentence
Gated DeltaNet is a linear/recurrent attention layer that combines a gate (for fast forgetting) with the delta rule (for precise, targeted memory updates) in a fixed-size matrix state.

## Plain-English explanation
- Gating alone → can forget quickly but writes are imprecise.
- Delta rule alone → precise writes but slow to clear old content.
- Gated DeltaNet → both: decay old memory when needed and surgically update specific associations.
It's designed to get much of attention's recall ability with constant per-token decode cost.

## Technical depth
- Paper: Yang, Kautz, Hatamizadeh, 2024 (arXiv:2412.06464).
- Update: `S_t = α_t S_{t−1} (I − β_t k_t k_tᵀ) + β_t v_t k_tᵀ`, output `o_t = S_t q_t`.
  - `α_t` — gate (decay), `β_t` — write strength, both input-dependent.
- Typically with short causal conv on q/k/v, L2-normalized keys, and an output gate + norm.
- **Kernels:** chunked parallel algorithm for prefill (matmul-heavy within chunks), recurrent single-step kernel for decode. Implementations live in libraries like `flash-linear-attention` (Triton) and are integrated into vLLM for supported models.
- **State per sequence:** `n_heads × d_k × d_v` per layer (+ conv state); constant in context length.
- Recent Qwen-family hybrid models use Gated DeltaNet layers interleaved with full (gated) attention layers.

## Backend-engineer analogy
A fixed-size cache with both TTL-style decay (gate) and targeted key updates (delta rule).

## Why it matters for GreenMind
MANGO's description names Gated DeltaNet. Its serving performance depends on vLLM having efficient Triton/CUDA kernels on A100 for these layers and on hybrid state management — not on attention optimizations.

## Common mistakes
- Applying Transformer-only optimizations and expecting them to speed up DeltaNet layers.
- Assuming an alternative engine supports Gated DeltaNet just because it supports Qwen.

## Related concepts
[Hybrid Model Architecture](85_Hybrid_Model_Architecture.md) · [Recurrent State](79_Recurrent_State.md) · [Hybrid Cache and Architecture-Specific Kernels](86_Hybrid_Cache_and_Architecture_Specific_Kernels.md) · [Linear Attention](81_Linear_Attention.md)
