# 80. Mamba (Selective State Update)

**Stage:** 4 | **Priority:** Must know (high level) | **Prerequisites:** [State-Space Models](78_State_Space_Models_SSM.md), [Recurrent State](79_Recurrent_State.md)

## In one sentence
Mamba is a selective state-space model whose state-update parameters depend on the current input, letting the layer choose what to remember and what to forget.

## Plain-English explanation
Classic SSMs update their notebook the same way for every token. Mamba looks at each token and decides: "this is important, write it down strongly" or "this is filler, let it fade." That selectivity makes it competitive with attention on language while keeping constant per-token cost in decode.

## Technical depth
- Paper: Gu & Dao, 2023 (arXiv:2312.00752). Mamba-2 (2024) reformulated it as "state-space duality" with more matmul-friendly kernels.
- Selectivity: Δ (step size), B, and C are functions of the input `x_t`:
  `h_t = exp(Δ_t A) h_{t−1} + Δ_t B_t x_t`, `y_t = C_t h_t`.
  Large Δ → reset toward the new input; small Δ → keep the old state.
- **Kernels:** prefill uses a hardware-aware parallel/chunked **selective scan** (fused, keeps state in SRAM); decode uses a single-step state update kernel. Plus a short causal conv1d with its own state.
- Scaling: linear in sequence length for prefill, `O(1)` per decode token.
- Wall-clock speed depends heavily on kernel quality; at short contexts a well-optimized attention layer can be just as fast.

## Backend-engineer analogy
An adaptive, content-aware aggregation — like an exponential moving average whose decay rate is chosen per event based on its importance.

## Why it matters for GreenMind
If MANGO uses Mamba-style layers, their kernels (Triton/CUDA in vLLM) and state management determine a big part of decode performance. Transformer-specific optimizations (FlashAttention, KV quantization) don't touch these layers.

## Common mistakes
- Assuming linear-time architecture guarantees the fastest wall-clock latency.
- Assuming the roadmap's "Mamba" label is exact — verify actual layer types in `config.json`.

## Related concepts
[Gated DeltaNet](84_Gated_DeltaNet.md) · [Hybrid Model Architecture](85_Hybrid_Model_Architecture.md) · [Hybrid Cache and Architecture-Specific Kernels](86_Hybrid_Cache_and_Architecture_Specific_Kernels.md) · [Gating](83_Gating.md)
