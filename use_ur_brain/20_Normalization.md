# 20. Normalization (LayerNorm / RMSNorm)

**Stage:** 1 | **Priority:** Should know | **Prerequisites:** [Embeddings and Hidden States](17_Embeddings_and_Hidden_States.md)

## In one sentence
Normalization layers rescale hidden-state vectors to a stable range so deep stacks of layers behave numerically well.

## Plain-English explanation
After many layers, the numbers in a hidden state could drift very large or very small. Normalization pulls each vector back to a consistent scale before (or after) each sub-block, which keeps training stable and keeps inference numerics predictable.

## Technical depth
- **LayerNorm:** `y = (x − mean(x)) / sqrt(var(x) + ε) × γ + β`.
- **RMSNorm** (common in modern LLMs incl. Qwen family): `y = x / sqrt(mean(x²) + ε) × γ` — cheaper, no mean subtraction.
- Usually "pre-norm": `h = h + Block(Norm(h))`.
- Some hybrid/linear-attention layers also use gated norms inside the block.
- Normalization involves reductions (sum of squares) — sensitive to precision; kernels often compute it in FP32 internally even when weights are BF16.
- Cheap in FLOPs but memory-bound and launch-heavy → a classic candidate for **kernel fusion** (e.g., fused add + RMSNorm).

## Backend-engineer analogy
Like normalizing input values before feeding a downstream service so it doesn't overflow — a small, cheap step that prevents big failures.

## Why it matters for GreenMind
Mostly invisible, but fused norm kernels are one reason optimized engines are faster, and low-precision formats (FP16 vs BF16) can interact with normalization range issues.

## Common mistakes
- Ignoring numerics: FP16's narrow range can overflow in places BF16 handles fine.

## Related concepts
[Residual Connections](21_Residual_Connections.md) · [Kernel Fusion](109_Kernel_Fusion.md) · [FP16](47_FP16.md) · [BF16](46_BF16.md)
