# 83. Gating

**Stage:** 4 | **Priority:** Should know | **Prerequisites:** [Linear Attention](81_Linear_Attention.md)

## In one sentence
A gate is a learned, input-dependent multiplier (usually between 0 and 1) that controls how much information passes through, is kept, or is forgotten.

## Plain-English explanation
Gates are valves. A forget gate near 1 says "keep the memory"; near 0 says "wipe it." An output gate decides how much of a computed value to let out. Gates let the network decide dynamically per token — e.g., reset memory at a topic change.

## Technical depth
- Typical form: `g_t = σ(W_g x_t)` (sigmoid → 0..1), applied elementwise or as a scalar per head.
- **Decay gate in recurrent memory:** `S_t = α_t S_{t−1} + ...` with `α_t ∈ (0,1)` — enables fast forgetting (Gated Linear Attention, Mamba-2, Gated DeltaNet).
- **Output gate:** `o_t = g_t ⊙ f(x_t)` — e.g., the gated RMSNorm/output gating used in many hybrid blocks; also "gated attention" variants that gate the attention output.
- **Gated FFN:** SwiGLU's `SiLU(W_gate x) ⊙ W_up x` is also a gating mechanism.
- Gates add small extra projections but are cheap relative to main matmuls.

## Backend-engineer analogy
Feature flags / circuit breakers computed per request: dynamically decide which data flows through and which is dropped.

## Why it matters for GreenMind
Gated DeltaNet = gating (fast forgetting) + delta rule (precise updates). Knowing the role of each helps you read the paper, the config, and vLLM's kernel names.

## Common mistakes
- None specific for serving; just recognize the term in configs and kernels.

## Related concepts
[Gated DeltaNet](84_Gated_DeltaNet.md) · [Delta Rule](82_Delta_Rule.md) · [Mamba](80_Mamba_Selective_State_Update.md) · [Feed-Forward Network](19_Feed_Forward_Network_MLP.md)
