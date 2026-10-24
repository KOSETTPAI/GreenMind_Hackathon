# 19. Feed-Forward Network (MLP)

**Stage:** 1 | **Priority:** Must know | **Prerequisites:** [Attention](18_Attention.md)

## In one sentence
The feed-forward network (FFN/MLP) is the per-token transformation inside each block — two or three big matrix multiplications with a nonlinearity — and it usually holds most of the model's weights.

## Plain-English explanation
Attention mixes information *between* tokens; the FFN processes each token *on its own*, like a big learned lookup that refines the token's meaning. Because it's applied to every token with large matrices, it's often the biggest share of parameters and FLOPs.

## Technical depth
- Modern LLMs commonly use **SwiGLU**: `FFN(x) = W_down( SiLU(W_gate x) ⊙ (W_up x) )`.
- Intermediate size is typically ~2.5–4× hidden size → three matrices of `d_model × d_ff`.
- FLOPs per token ≈ `2 × params_FFN` (multiply + add per weight).
- In decode with small batch, these are matrix-vector-like products → **memory-bound** (weights read for few tokens). In prefill or large batch, they're matrix-matrix → more **compute-bound**.
- Weight-only quantization (e.g., W4A16) mostly targets these matrices.

## Backend-engineer analogy
If attention is the "join" step, the FFN is the per-row "transform/map" step — embarrassingly parallel across tokens, heavy on compute.

## Why it matters for GreenMind
The FFN dominates the weight bytes read every decode step, so it's the main target for quantization and the main reason batching improves efficiency.

## Common mistakes
- Assuming attention is always the bottleneck; at moderate context lengths the FFN often dominates.

## Related concepts
[Compute-Bound vs Memory-Bound](39_Compute_Bound_vs_Memory_Bound.md) · [Arithmetic Intensity](38_Arithmetic_Intensity.md) · [Weight-Only Quantization](103_Weight_Only_Quantization_W4A16.md) · [Residual Connections](21_Residual_Connections.md)
