# 81. Linear Attention

**Stage:** 4 | **Priority:** Should know | **Prerequisites:** [Attention](18_Attention.md), [Recurrent State](79_Recurrent_State.md)

## In one sentence
Linear attention removes softmax so attention can be rewritten as a running sum of key-value outer products — a fixed-size matrix state updated each token, giving linear cost in sequence length.

## Plain-English explanation
Normal attention compares the new query with every past key (cost grows with history). Linear attention instead accumulates all past (key × value) information into one matrix "memory." To read, multiply the query by that matrix. Same memory size forever, constant cost per token.

## Technical depth
- Softmax attention: `o_t = Σ_i softmax(q_t·k_i) v_i` — needs all past `k_i, v_i` (KV cache).
- Linear attention (with feature map φ, often identity + normalization):
  `S_t = S_{t−1} + v_t k_tᵀ`, `o_t = S_t q_t`.
  `S_t ∈ R^{d_v × d_k}` is the recurrent state.
- **Problem:** pure additive updates never forget, so the memory fills with interference ("memory overload") → poor recall. Fixes: decay/gating (e.g., RetNet, GLA, Mamba-2) and delta-rule updates (DeltaNet).
- **Prefill:** computed in **chunks** — within a chunk use matmuls (parallel, Tensor Core friendly), between chunks pass state recurrently.

## Backend-engineer analogy
Replacing "scan all rows and compute a weighted join" with "maintain an incrementally updated aggregate matrix and query it in O(1)."

## Why it matters for GreenMind
Gated DeltaNet is a linear-attention variant. Understanding the state matrix explains why its memory is constant per sequence and why prefill uses chunked kernels.

## Common mistakes
- Assuming linear attention has the same recall as softmax attention — that's why hybrids keep some full attention layers.

## Related concepts
[Delta Rule](82_Delta_Rule.md) · [Gating](83_Gating.md) · [Gated DeltaNet](84_Gated_DeltaNet.md) · [State-Space Models](78_State_Space_Models_SSM.md)
